module MyModule::EnergyTrading {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing an energy listing by a producer.
    struct EnergyListing has store, key {
        energy_amount: u64,    // Energy available (in kilowatt-hours)
        price_per_unit: u64,   // Price per kilowatt-hour in coins
    }

    /// Function for producers to list their excess energy for sale.
    public fun list_energy(producer: &signer, energy_amount: u64, price_per_unit: u64) {
        let listing = EnergyListing {
            energy_amount,
            price_per_unit,
        };
        move_to(producer, listing);
    }

    /// Function for consumers to purchase energy from a producer.
    public fun purchase_energy(consumer: &signer, producer_address: address, energy_amount: u64) acquires EnergyListing {
        let producer_listing = borrow_global_mut<EnergyListing>(producer_address);
        assert!(producer_listing.energy_amount >= energy_amount, 1);

        let total_price = energy_amount * producer_listing.price_per_unit;

        // Transfer payment from consumer to producer
        let payment = coin::withdraw<AptosCoin>(consumer, total_price);
        coin::deposit<AptosCoin>(producer_address, payment);

        // Update the producer's available energy
        producer_listing.energy_amount = producer_listing.energy_amount - energy_amount;
    }
}
