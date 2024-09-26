module MyModule::PredictionMarket {

    use aptos_framework::signer;
    use aptos_framework::coin;
    use std::option;
    use aptos_framework::aptos_coin::AptosCoin;

    /// Struct representing a prediction market event.
    struct PredictionEvent has store, key {
        total_yes: u64,    // Total tokens placed on "Yes"
        total_no: u64,     // Total tokens placed on "No"
        resolved: bool,    // Whether the event outcome has been resolved
        outcome: option::Option<bool>, // Outcome of the event (None until resolved)
    }

    /// Function to create a prediction event.
    public fun create_event(creator: &signer) {
        let event = PredictionEvent {
            total_yes: 0,
            total_no: 0,
            resolved: false,
            outcome: option::none(),
        };
        move_to(creator, event);
    }

    /// Function to place a prediction on an event ("Yes" or "No").
    public fun place_prediction(user: &signer, event_owner: address, prediction: bool, amount: u64) acquires PredictionEvent {
        let event = borrow_global_mut<PredictionEvent>(event_owner);

        // User places a prediction (Yes = true, No = false)
        let payment = coin::withdraw<AptosCoin>(user, amount);
        coin::deposit<AptosCoin>(event_owner, payment);

        if (prediction) {
            event.total_yes = event.total_yes + amount;
        } else {
            event.total_no = event.total_no + amount;
        }
    }
}
