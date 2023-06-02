
// Copyright 2022  Authors. Licensed under Apache-2.0 License.
module moveflow::stream {

    use sui::coin::Coin;
    use std::string::String;
    use sui::tx_context::TxContext;
    use sui::clock::Clock;
    use sui::transfer;

    struct GlobalConfig has key {
    }

    struct StreamInfo<phantom CoinType> has key {
    }

    public entry fun create<CoinType>(
        global_config: &mut GlobalConfig,
        payment: Coin<CoinType>,
        name: String,
        remark: String,
        recipient: address,
        deposit_amount: u64,
        start_time: u64,
        stop_time: u64,
        interval: u64,
        closeable: bool,
        modifiable: bool,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        transfer::public_transfer(payment, recipient);
        name;
        remark;
        recipient;
        deposit_amount;
        start_time;
        stop_time;
        interval;
        closeable;
        modifiable;
        clock;
        ctx;
        global_config;
    }

    public entry fun withdraw<CoinType>(
        stream: &mut StreamInfo<CoinType>,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        stream;
        clock;
        ctx;
    }

    public fun get_withdrawn_amount<CoinType>(stream: &StreamInfo<CoinType>): u64{
        stream;
        0u64
    }
}
