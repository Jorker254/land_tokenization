#!/bin/bash

# Install Foundry (if not already installed)
if ! command -v anvil &> /dev/null; then
    echo "Installing Foundry..."
    curl -L https://foundry.paradigm.xyz | bash
    source ~/.bashrc
    foundryup
fi

# Start Anvil in the background
echo "Starting Anvil..."
anvil &

# Install frontend dependencies
echo "Installing frontend dependencies..."
cd frontend
npm install

# Start the frontend application
echo "Starting frontend application..."
npm start 