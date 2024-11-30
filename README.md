# Bitcoin-Backed NFT Platform

## Overview

The Bitcoin-Backed NFT Platform is a sophisticated smart contract implemented on the Stacks blockchain, providing a comprehensive solution for managing NFTs tied to real-world assets. This platform enables users to mint, transfer, stake, and burn NFTs while incorporating a governance token mechanism for staking rewards.

## Features

### 1. NFT Minting

- Create unique NFTs with:
  - Unique Token ID
  - Asset Type
  - Asset Value
- Robust input validation to ensure data integrity

### 2. NFT Transfers

- Securely transfer NFTs between users
- Comprehensive checks to prevent unauthorized transfers
- Prevents transfer of staked NFTs

### 3. NFT Staking

- Stake NFTs to earn governance tokens
- Rewards calculated based on:
  - Asset value
  - Staking duration
- Flexible staking mechanism with detailed tracking

### 4. NFT Unstaking

- Claim rewards for staked NFTs
- Automatic reward calculation
- Reset staking information upon unstaking

### 5. NFT Burning

- Remove NFTs from circulation
- Strict ownership and staking status verification

### 6. Governance Token System

- Accumulate tokens through NFT staking
- Redeem accumulated tokens
- Flexible token management

## Contract Architecture

### Key Components

- Non-Fungible Token (NFT) Definition
- Error Handling Mechanisms
- Input Validation Functions
- Storage Maps for:
  - NFT Metadata
  - NFT Staking Information
  - Governance Token Balances

### Storage Maps

- `nft-metadata`: Stores comprehensive NFT details
- `nft-staking`: Tracks active NFT staking information
- `governance-tokens`: Manages user governance token balances

## Error Handling

The contract includes detailed error constants to provide clear feedback:

- `ERR-UNAUTHORIZED`: Prevents unauthorized actions
- `ERR-NOT-FOUND`: Handles non-existent token queries
- `ERR-ALREADY-MINTED`: Prevents duplicate minting
- `ERR-INVALID-TRANSFER`: Ensures transfer validity
- `ERR-STAKING-ERROR`: Manages staking-related issues
- `ERR-INSUFFICIENT-BALANCE`: Checks token redemption eligibility
- `ERR-INVALID-INPUT`: Validates input parameters

## Public Functions

1. `mint-nft`: Create new NFTs
2. `transfer-nft`: Transfer NFT ownership
3. `stake-nft`: Stake an NFT
4. `unstake-nft`: Unstake and claim rewards
5. `burn-nft`: Remove NFT from circulation
6. `redeem-governance-tokens`: Claim accumulated governance tokens

## Read-Only Functions

1. `get-nft-metadata`: Retrieve NFT details
2. `get-governance-tokens`: Check user's governance token balance

## Security Measures

- Input validation for all critical parameters
- Ownership verification for all sensitive operations
- Preventing double-spending and unauthorized transfers
- Comprehensive error checking

## Deployment

The contract is deployed on the Stacks blockchain with the following characteristics:

- Non-Fungible Token Type: `bitcoin-backed-nft`
- Token ID: 32-byte buffer
- Asset Type: UTF-8 string (max 50 characters)
- Asset Value: Unsigned integer

## Usage Example

```clarity
;; Mint an NFT
(contract-call? .bitcoin-backed-nft mint-nft 0x123456 u"RealEstate" u100000)

;; Stake the NFT
(contract-call? .bitcoin-backed-nft stake-nft 0x123456)

;; Unstake and claim rewards
(contract-call? .bitcoin-backed-nft unstake-nft 0x123456)
```

## Limitations

- Maximum asset value: Less than 1,000,000
- Token ID must be non-zero and less than 33 bytes
- Asset type must be 1-50 characters long

## Potential Improvements

- Add more complex reward calculation mechanisms
- Implement partial unstaking
- Create more granular governance token usage

## Contributing

Contributions are welcome! Please submit pull requests or open issues to propose changes or report bugs.
