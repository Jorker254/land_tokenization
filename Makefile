-include .env

.PHONY: anvil deploy interact clean test

anvil:
	anvil

deploy:
	forge script script/Deploy.s.sol:Deploy --rpc-url http://localhost:8545 --broadcast -vvvv

interact:
	forge script script/Interact.s.sol:Interact --rpc-url http://localhost:8545 --broadcast -vvvv

test:
	forge test -vv

clean:
	forge clean