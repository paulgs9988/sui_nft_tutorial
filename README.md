# Sui NFT with Balance

A Move smart contract demonstrating how to create NFTs on Sui that can hold SUI tokens. This project shows key differences between EVM and Sui development, particularly around object ownership and capabilities.

## Overview

This contract implements:
- NFT creation with metadata and image support via Walrus Protocol
- Built-in balance holding capability (NFTs can hold SUI tokens)
- Display configuration for proper wallet/explorer rendering
- Balance management functions (deposit/withdraw)

## Key Concepts for EVM Developers

### Object-Centric vs Account-Centric
Unlike EVM where everything is stored in contract storage, Sui uses an object-centric model:
- Each NFT is a distinct object with its own address
- Objects can own other objects (like our NFT holding SUI)
- Objects have unique IDs rather than simple token IDs

### Move vs Solidity
- No events system (use `display`)
- No mapping types (use object relations)
- Explicit capability pattern instead of `onlyOwner`
- Resources can only be moved, never copied (unless explicitly marked)

## Getting Started

### Prerequisites
```bash
# Install Sui
cargo install --locked --git https://github.com/MystenLabs/sui.git --branch devnet sui

# Check installation
sui --version
```

# Project Setup
## Create new package
```bash
sui move new nft_creator
cd nft_creator
```

-Copy contract into sources/simple_nft.move
-Copy Move.toml contents 

# Publishing
## Build and publish
```bash
sui client publish --gas-budget 100000000
```

## Save package ID
```bash
export PACKAGE_ID=<package_id_from_publish_output>
```

# Mint NFT
## Mint new NFT
```bash
sui client call --package $PACKAGE_ID --module simple_nft --function mint_nft \
--args \
"NFT Name" \
"NFT Description" \
"YOUR_WALRUS_BLOB_ID" \
"YOUR_WALRUS_OBJECT_ID" \
--gas-budget 10000000
```

## Save NFT ID from output
```bash
export NFT_ID=<nft_id_from_mint_output>
```

# Managing Balance
## Get list of coin objects
```bash
sui client gas
```

## Add 0.1 SUI to NFT (100000000 MIST)
```bash
sui client call --package $PACKAGE_ID --module simple_nft --function add_balance \
--args $NFT_ID $COIN_ID 100000000 \
--gas-budget 10000000
```

## Withdraw 0.1 SUI from NFT
```bash
sui client call --package $PACKAGE_ID --module simple_nft --function withdraw_balance \
--args $NFT_ID 100000000 \
--gas-budget 10000000
```

# Contract Structure

## SimpleNFT Object
```
struct SimpleNFT has key, store {
    id: UID,
    name: String,
    description: String,
    walrus_blob_id: String,
    walrus_sui_object: String,
    balance: Balance<SUI>
}
```
## Key Functions
### Minting
```
public entry fun mint_nft(
    name: String,
    description: String,
    walrus_blob_id: String,
    walrus_sui_object: String,
    ctx: &mut TxContext
)
```
### Balance Management
```
// Add SUI to NFT
public entry fun add_balance(
    self: &mut SimpleNFT,
    payment: &mut Coin<SUI>,
    amount: u64,
)

// Withdraw SUI from NFT
public entry fun withdraw_balance(
    self: &mut SimpleNFT,
    amount: u64,
    ctx: &mut TxContext
)
```

# Key Differences from EVM NFTs

## Object Creation

EVM: Mapping of ID to owner
Sui: Each NFT is a distinct object


## Balance Holding

EVM: Typically requires separate contract
Sui: Built into object capabilities


## Metadata

EVM: Usually points to IPFS/external URL
Sui: Uses Display for standardized rendering


## Ownership

EVM: Tracked in contract storage
Sui: Part of object model

# Acknowledgements
-Sui Framework Docs
-Move Language Docs
-Walrus Protocol Docs