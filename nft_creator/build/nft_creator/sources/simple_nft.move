module nft_creator::simple_nft {
    use sui::tx_context::{Self, TxContext}; //For transaction context and sender info
    use sui::object::{Self, UID};   //For creating uniqe object IDs
    use sui::transfer;  //For transferring objects between addresses
    use sui::package;   //For package publishing
    use sui::display;   //For NFT metadata display
    use sui::balance::{Self, Balance};  //For handling sui token balances
    use sui::sui::SUI;  //For the sui token type
    use sui::coin::{Self, Coin};    //For cryptocurrency operations
    use std::string::{Self, String};    //For string operations

    struct SimpleNFT has key, store {
        id: UID,
        name: String,
        description: String,
        walrus_blob_id: String,
        walrus_sui_object: String,
        balance: Balance<SUI>
    }

    struct SIMPLE_NFT has drop{}    //Witness type for one-time initialization

    const ENO_EMPTY_NAME: u64 = 0;     // Error code for empty name
    const ENO_EMPTY_BLOB_ID: u64 = 1;  // Error code for empty blob ID

    fun init(witness: SIMPLE_NFT, ctx: &mut TxContext) {
        let keys = vector[
            string::utf8(b"name"),
            string::utf8(b"description"),
            string::utf8(b"image_url"),
        ];
        
        let values = vector[
            string::utf8(b"{name}"),
            string::utf8(b"{description}"),
            string::utf8(b"https://aggregator.walrus-testnet.walrus.space/v1/{walrus_blob_id}")
        ];
        
        let publisher = package::claim(witness, ctx);
        let display = display::new_with_fields<SimpleNFT>(
            &publisher, keys, values, ctx
        );
        display::update_version(&mut display);
        
        transfer::public_transfer(publisher, tx_context::sender(ctx));
        transfer::public_transfer(display, tx_context::sender(ctx));
    }

    public entry fun mint_nft(
        name: String,
        description: String,
        walrus_blob_id: String,
        walrus_sui_object: String,
        ctx: &mut TxContext
    ) {
        assert!(!string::is_empty(&name), ENO_EMPTY_NAME);
        assert!(!string::is_empty(&walrus_blob_id), ENO_EMPTY_BLOB_ID);

        let nft = SimpleNFT {
            id: object::new(ctx),
            name,
            description,
            walrus_blob_id,
            walrus_sui_object,
            balance: balance::zero()
        };

        transfer::transfer(nft, tx_context::sender(ctx));
    }

    public entry fun add_balance(
        self: &mut SimpleNFT,     // Mutable reference to the NFT we're adding balance to
        payment: &mut Coin<SUI>,  // Mutable reference to a SUI coin object we're taking from
        amount: u64,              // Amount of SUI (in MIST) to add
    ) {
        // Get mutable reference to the coin's balance
        let coin_balance = coin::balance_mut(payment);
        
        // Split off the specified amount from the payment coin
        let paid = balance::split(coin_balance, amount);
        
        // Join the split amount into the NFT's balance
        balance::join(&mut self.balance, paid);
    }

    public entry fun withdraw_balance(
        self: &mut SimpleNFT,     // Mutable reference to the NFT we're withdrawing from
        amount: u64,              // Amount to withdraw (in MIST)
        ctx: &mut TxContext       // Transaction context for creating new coin
    ) {
        // Split specified amount from NFT's balance and create new coin
        let withdrawn = coin::from_balance(
            balance::split(&mut self.balance, amount), 
            ctx
        );
        
        // Transfer the new coin to the transaction sender
        transfer::public_transfer(withdrawn, tx_context::sender(ctx));
    }
}