// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "./LandToken.sol";

contract KenyaLandMarketplace is AccessControl, ReentrancyGuard {
    bytes32 public constant MARKETPLACE_ADMIN_ROLE =
        keccak256("MARKETPLACE_ADMIN_ROLE");
    bytes32 public constant LAND_REGISTRAR_ROLE =
        keccak256("LAND_REGISTRAR_ROLE");

    struct Auction {
        address seller;
        uint256 tokenId;
        uint256 startTime;
        uint256 endTime;
        uint256 startingPrice;
        uint256 currentBid;
        address currentBidder;
        bool isActive;
        bool requiresRegistrarApproval;
        bool isApproved;
    }

    struct Escrow {
        address buyer;
        address seller;
        uint256 tokenId;
        uint256 amount;
        uint256 deadline;
        bool isActive;
        bool requiresRegistrarApproval;
        bool isApproved;
    }

    struct FractionalShare {
        uint256 tokenId;
        uint256 totalShares;
        uint256 availableShares;
        uint256 pricePerShare;
        bool requiresRegistrarApproval;
        bool isApproved;
        mapping(address => uint256) sharesOwned;
    }

    struct LeaseAgreement {
        address lessor;
        address lessee;
        uint256 tokenId;
        uint256 startDate;
        uint256 endDate;
        uint256 monthlyRent;
        uint256 securityDeposit;
        bool isActive;
        bool requiresRegistrarApproval;
        bool isApproved;
    }

    LandToken public landToken;
    IERC20 public paymentToken;

    mapping(uint256 => Auction) private _auctions;
    mapping(uint256 => Escrow) private _escrows;
    mapping(uint256 => FractionalShare) private _fractionalShares;
    mapping(uint256 => LeaseAgreement) private _leaseAgreements;
    mapping(uint256 => bool) public isFractionalized;
    mapping(uint256 => bool) public isLeased;

    uint256 public constant MIN_AUCTION_DURATION = 1 days;
    uint256 public constant MAX_AUCTION_DURATION = 30 days;
    uint256 public constant ESCROW_DURATION = 7 days;
    uint256 public constant MIN_LEASE_DURATION = 30 days;
    uint256 public constant MAX_LEASE_DURATION = 99 * 365 days;

    event AuctionCreated(uint256 indexed tokenId, uint256 startingPrice);
    event BidPlaced(uint256 indexed tokenId, address bidder, uint256 amount);
    event AuctionEnded(uint256 indexed tokenId, address winner, uint256 amount);
    event AuctionApproved(uint256 indexed tokenId);
    event EscrowCreated(
        uint256 indexed tokenId,
        address buyer,
        address seller,
        uint256 amount
    );
    event EscrowReleased(uint256 indexed tokenId);
    event EscrowCancelled(uint256 indexed tokenId);
    event EscrowApproved(uint256 indexed tokenId);
    event LandFractionalized(
        uint256 indexed tokenId,
        uint256 totalShares,
        uint256 pricePerShare
    );
    event SharesPurchased(
        uint256 indexed tokenId,
        address buyer,
        uint256 shares
    );
    event FractionalizationApproved(uint256 indexed tokenId);
    event LeaseCreated(
        uint256 indexed tokenId,
        address lessor,
        address lessee,
        uint256 monthlyRent
    );
    event LeaseTerminated(uint256 indexed tokenId);
    event LeaseApproved(uint256 indexed tokenId);

    constructor(address _landToken, address _paymentToken) {
        _grantRole(DEFAULT_ADMIN_ROLE, msg.sender);
        _grantRole(MARKETPLACE_ADMIN_ROLE, msg.sender);
        _grantRole(LAND_REGISTRAR_ROLE, msg.sender);
        landToken = LandToken(_landToken);
        paymentToken = IERC20(_paymentToken);
    }

    function getAuction(
        uint256 tokenId
    ) external view returns (Auction memory) {
        return _auctions[tokenId];
    }

    function getEscrow(uint256 tokenId) external view returns (Escrow memory) {
        return _escrows[tokenId];
    }

    function getFractionalShareInfo(
        uint256 tokenId
    )
        external
        view
        returns (
            uint256 totalShares,
            uint256 availableShares,
            uint256 pricePerShare,
            bool requiresRegistrarApproval,
            bool isApproved
        )
    {
        FractionalShare storage share = _fractionalShares[tokenId];
        return (
            share.totalShares,
            share.availableShares,
            share.pricePerShare,
            share.requiresRegistrarApproval,
            share.isApproved
        );
    }

    function getLeaseAgreement(
        uint256 tokenId
    ) external view returns (LeaseAgreement memory) {
        return _leaseAgreements[tokenId];
    }

    function createAuction(
        uint256 tokenId,
        uint256 startingPrice,
        uint256 duration,
        bool requireRegistrarApproval
    ) external {
        require(landToken.ownerOf(tokenId) == msg.sender, "Not token owner");
        require(
            duration >= MIN_AUCTION_DURATION &&
                duration <= MAX_AUCTION_DURATION,
            "Invalid duration"
        );
        require(!_auctions[tokenId].isActive, "Auction already exists");

        landToken.transferFrom(msg.sender, address(this), tokenId);

        _auctions[tokenId] = Auction({
            seller: msg.sender,
            tokenId: tokenId,
            startTime: block.timestamp,
            endTime: block.timestamp + duration,
            startingPrice: startingPrice,
            currentBid: 0,
            currentBidder: address(0),
            isActive: true,
            requiresRegistrarApproval: requireRegistrarApproval,
            isApproved: !requireRegistrarApproval
        });

        emit AuctionCreated(tokenId, startingPrice);
    }

    function approveAuction(
        uint256 tokenId
    ) external onlyRole(LAND_REGISTRAR_ROLE) {
        require(_auctions[tokenId].isActive, "Auction not active");
        require(
            _auctions[tokenId].requiresRegistrarApproval,
            "Approval not required"
        );
        require(!_auctions[tokenId].isApproved, "Already approved");

        _auctions[tokenId].isApproved = true;
        emit AuctionApproved(tokenId);
    }

    function placeBid(uint256 tokenId, uint256 amount) external nonReentrant {
        Auction storage auction = _auctions[tokenId];
        require(auction.isActive, "Auction not active");
        require(auction.isApproved, "Auction not approved");
        require(block.timestamp < auction.endTime, "Auction ended");
        require(amount > auction.currentBid, "Bid too low");

        if (auction.currentBidder != address(0)) {
            paymentToken.transfer(auction.currentBidder, auction.currentBid);
        }

        paymentToken.transferFrom(msg.sender, address(this), amount);
        auction.currentBid = amount;
        auction.currentBidder = msg.sender;

        emit BidPlaced(tokenId, msg.sender, amount);
    }

    function endAuction(uint256 tokenId) external nonReentrant {
        Auction storage auction = _auctions[tokenId];
        require(auction.isActive, "Auction not active");
        require(
            block.timestamp >= auction.endTime || msg.sender == auction.seller,
            "Auction not ended"
        );

        if (auction.currentBidder != address(0)) {
            landToken.transferFrom(
                address(this),
                auction.currentBidder,
                tokenId
            );
            paymentToken.transfer(auction.seller, auction.currentBid);
        } else {
            landToken.transferFrom(address(this), auction.seller, tokenId);
        }

        auction.isActive = false;
        emit AuctionEnded(tokenId, auction.currentBidder, auction.currentBid);
    }

    function createEscrow(
        uint256 tokenId,
        address buyer,
        uint256 amount,
        bool requireRegistrarApproval
    ) external {
        require(landToken.ownerOf(tokenId) == msg.sender, "Not token owner");
        require(!_escrows[tokenId].isActive, "Escrow already exists");

        landToken.transferFrom(msg.sender, address(this), tokenId);
        paymentToken.transferFrom(buyer, address(this), amount);

        _escrows[tokenId] = Escrow({
            buyer: buyer,
            seller: msg.sender,
            tokenId: tokenId,
            amount: amount,
            deadline: block.timestamp + ESCROW_DURATION,
            isActive: true,
            requiresRegistrarApproval: requireRegistrarApproval,
            isApproved: !requireRegistrarApproval
        });

        emit EscrowCreated(tokenId, buyer, msg.sender, amount);
    }

    function approveEscrow(
        uint256 tokenId
    ) external onlyRole(LAND_REGISTRAR_ROLE) {
        require(_escrows[tokenId].isActive, "Escrow not active");
        require(
            _escrows[tokenId].requiresRegistrarApproval,
            "Approval not required"
        );
        require(!_escrows[tokenId].isApproved, "Already approved");

        _escrows[tokenId].isApproved = true;
        emit EscrowApproved(tokenId);
    }

    function releaseEscrow(uint256 tokenId) external nonReentrant {
        Escrow storage escrow = _escrows[tokenId];
        require(escrow.isActive, "Escrow not active");
        require(escrow.isApproved, "Escrow not approved");
        require(msg.sender == escrow.buyer, "Not buyer");

        landToken.transferFrom(address(this), escrow.buyer, tokenId);
        paymentToken.transfer(escrow.seller, escrow.amount);
        escrow.isActive = false;

        emit EscrowReleased(tokenId);
    }

    function cancelEscrow(uint256 tokenId) external nonReentrant {
        Escrow storage escrow = _escrows[tokenId];
        require(escrow.isActive, "Escrow not active");
        require(msg.sender == escrow.seller, "Not seller");
        require(block.timestamp >= escrow.deadline, "Deadline not reached");

        landToken.transferFrom(address(this), escrow.seller, tokenId);
        paymentToken.transfer(escrow.buyer, escrow.amount);
        escrow.isActive = false;

        emit EscrowCancelled(tokenId);
    }

    function fractionalizeLand(
        uint256 tokenId,
        uint256 totalShares,
        uint256 pricePerShare,
        bool requireRegistrarApproval
    ) external {
        require(landToken.ownerOf(tokenId) == msg.sender, "Not token owner");
        require(!isFractionalized[tokenId], "Already fractionalized");
        require(totalShares > 0, "Invalid shares");

        landToken.transferFrom(msg.sender, address(this), tokenId);

        FractionalShare storage share = _fractionalShares[tokenId];
        share.tokenId = tokenId;
        share.totalShares = totalShares;
        share.availableShares = totalShares;
        share.pricePerShare = pricePerShare;
        share.requiresRegistrarApproval = requireRegistrarApproval;
        share.isApproved = !requireRegistrarApproval;
        isFractionalized[tokenId] = true;

        emit LandFractionalized(tokenId, totalShares, pricePerShare);
    }

    function approveFractionalization(
        uint256 tokenId
    ) external onlyRole(LAND_REGISTRAR_ROLE) {
        require(isFractionalized[tokenId], "Not fractionalized");
        require(
            _fractionalShares[tokenId].requiresRegistrarApproval,
            "Approval not required"
        );
        require(!_fractionalShares[tokenId].isApproved, "Already approved");

        _fractionalShares[tokenId].isApproved = true;
        emit FractionalizationApproved(tokenId);
    }

    function purchaseShares(
        uint256 tokenId,
        uint256 numberOfShares
    ) external nonReentrant {
        require(isFractionalized[tokenId], "Not fractionalized");
        FractionalShare storage share = _fractionalShares[tokenId];
        require(share.isApproved, "Not approved");
        require(share.availableShares >= numberOfShares, "Not enough shares");

        uint256 totalPrice = numberOfShares * share.pricePerShare;
        paymentToken.transferFrom(msg.sender, address(this), totalPrice);

        share.availableShares -= numberOfShares;
        share.sharesOwned[msg.sender] += numberOfShares;

        emit SharesPurchased(tokenId, msg.sender, numberOfShares);
    }

    function createLease(
        uint256 tokenId,
        address lessee,
        uint256 duration,
        uint256 monthlyRent,
        uint256 securityDeposit,
        bool requireRegistrarApproval
    ) external {
        require(landToken.ownerOf(tokenId) == msg.sender, "Not token owner");
        require(!isLeased[tokenId], "Already leased");
        require(
            duration >= MIN_LEASE_DURATION && duration <= MAX_LEASE_DURATION,
            "Invalid duration"
        );

        paymentToken.transferFrom(lessee, address(this), securityDeposit);

        _leaseAgreements[tokenId] = LeaseAgreement({
            lessor: msg.sender,
            lessee: lessee,
            tokenId: tokenId,
            startDate: block.timestamp,
            endDate: block.timestamp + duration,
            monthlyRent: monthlyRent,
            securityDeposit: securityDeposit,
            isActive: true,
            requiresRegistrarApproval: requireRegistrarApproval,
            isApproved: !requireRegistrarApproval
        });

        isLeased[tokenId] = true;
        emit LeaseCreated(tokenId, msg.sender, lessee, monthlyRent);
    }

    function approveLease(
        uint256 tokenId
    ) external onlyRole(LAND_REGISTRAR_ROLE) {
        require(isLeased[tokenId], "Not leased");
        require(
            _leaseAgreements[tokenId].requiresRegistrarApproval,
            "Approval not required"
        );
        require(!_leaseAgreements[tokenId].isApproved, "Already approved");

        _leaseAgreements[tokenId].isApproved = true;
        emit LeaseApproved(tokenId);
    }

    function terminateLease(uint256 tokenId) external nonReentrant {
        LeaseAgreement storage lease = _leaseAgreements[tokenId];
        require(lease.isActive, "Lease not active");
        require(lease.isApproved, "Lease not approved");
        require(
            msg.sender == lease.lessor || msg.sender == lease.lessee,
            "Not authorized"
        );

        if (msg.sender == lease.lessee) {
            require(block.timestamp >= lease.endDate, "Lease not expired");
        }

        paymentToken.transfer(lease.lessee, lease.securityDeposit);
        lease.isActive = false;
        isLeased[tokenId] = false;

        emit LeaseTerminated(tokenId);
    }

    function getSharesOwned(
        uint256 tokenId,
        address owner
    ) external view returns (uint256) {
        return _fractionalShares[tokenId].sharesOwned[owner];
    }
}
