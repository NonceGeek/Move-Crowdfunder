module crowdfund::crowdfund {
    use sui::transfer;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use sui::vec_set::{Self, VecSet};
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};
    use sui::event::emit;
    use sui::clock::Clock;
    use std::string::utf8;

    use moveflow::stream::{Self, GlobalConfig, StreamInfo};

    const MAXU64: u64 = 18446744073709551615u64;

    // Errors
    const ENotOwner: u64 = 0;
    const EFundClose: u64 = 1;

    struct CrowdFund<phantom T> has key, store {
        id: UID,
        open: bool,
        owner: address,
        github_repo_link: Url,
        balance: Balance<T>,
        flow_balance: u64,
        upper_bound: u64,
    }

    struct FundInfo has key {
        id: UID,
        open: VecSet<ID>,
        total: VecSet<ID>,
    }

    // Events
    struct CrowdFundCreated has copy, drop {
        id: ID,
    }

    struct CrowdFundClosed has copy, drop {
        id: ID,
    }

    struct CrowdFundWithdraw has copy, drop {
        id: ID,
        owner: address,
        amount: u64,
    }

    struct CrowdFundSponsor has copy, drop {
        id: ID,
        sender: address,
        amount: u64,
    }

    fun init(ctx: &mut TxContext) {
        transfer::share_object(FundInfo {
            id: object::new(ctx),
            open: vec_set::empty(),
            total: vec_set::empty(),
        });
    }

    public entry fun create_crowdfund_unbound<T: drop>(fund_info: &mut FundInfo, github_repo_link: vector<u8>, ctx: &mut TxContext) {
        let crowd_fund: CrowdFund<T> = new_crowdfund<T>(github_repo_link, MAXU64, ctx);
        let fund_id: ID = object::id(&crowd_fund);
        vec_set::insert(&mut fund_info.open, fund_id);
        vec_set::insert(&mut fund_info.total, fund_id);
        emit(CrowdFundCreated { id: fund_id });
        transfer::public_share_object(crowd_fund);
    }

    public entry fun create_crowdfund_upperbound<T: drop>(fund_info: &mut FundInfo, github_repo_link: vector<u8>, upper_bound: u64, ctx: &mut TxContext) {
        let crowd_fund: CrowdFund<T> = new_crowdfund<T>(github_repo_link, upper_bound, ctx);
        let fund_id: ID = object::id(&crowd_fund);
        vec_set::insert(&mut fund_info.open, fund_id);
        vec_set::insert(&mut fund_info.total, fund_id);
        emit(CrowdFundCreated { id: fund_id });
        transfer::public_share_object(crowd_fund);
    }

    public entry fun close_crowdfund<T: drop>(fund_info: &mut FundInfo, crowd_fund: &mut CrowdFund<T>, ctx: &mut TxContext) {
        assert!(crowd_fund.owner == tx_context::sender(ctx), ENotOwner);
        withdraw_crowdfund<T>(crowd_fund, ctx);
        crowd_fund.open = false;
        let fund_id: ID = object::id(crowd_fund);
        vec_set::remove(&mut fund_info.open, &fund_id);
        emit(CrowdFundClosed { id: fund_id });
    }

    public entry fun withdraw_crowdfund<T: drop>(crowd_fund: &mut CrowdFund<T>, ctx: &mut TxContext) {
        assert!(crowd_fund.owner == tx_context::sender(ctx), ENotOwner);
        emit(CrowdFundWithdraw {
            id: object::id(crowd_fund),
            owner: tx_context::sender(ctx),
            amount: balance::value(&crowd_fund.balance),
        });
        let return_coin: Coin<T> = coin::from_balance(balance::withdraw_all(&mut crowd_fund.balance), ctx);
        let withdaw_value: u64 = coin::value<T>(&return_coin);
        crowd_fund.upper_bound = crowd_fund.upper_bound - withdaw_value;
        transfer::public_transfer(return_coin, tx_context::sender(ctx));
    }

    public entry fun crowdfund<T: drop>(crowd_fund: &mut CrowdFund<T>, donate_money: &mut Coin<T>, amount: u64, ctx: &mut TxContext) {
        assert!(crowd_fund.open, EFundClose);
        let fundraised: u64 = balance::value<T>(&crowd_fund.balance);
        let to_donate: u64 = if (fundraised + crowd_fund.flow_balance + amount > crowd_fund.upper_bound)
            fundraised + crowd_fund.flow_balance + amount - crowd_fund.upper_bound
        else
            amount;
        let to_donate_coin: Coin<T> = coin::split(donate_money, to_donate, ctx);
        emit(CrowdFundSponsor {
            id: object::id(crowd_fund),
            sender: tx_context::sender(ctx),
            amount: to_donate,
        });
        coin::put<T>(&mut crowd_fund.balance, to_donate_coin);
    }

    public fun list_crowdfund(fund_info: &FundInfo): VecSet<ID> {
        fund_info.total
    }

    public fun list_crowdfund_opened(fund_info: &FundInfo): VecSet<ID> {
        fund_info.open
    }

    fun new_crowdfund<T: drop>(github_repo_link: vector<u8>, upper_bound: u64, ctx: &mut TxContext): CrowdFund<T> {
        CrowdFund<T> {
            id: object::new(ctx),
            open: true,
            owner: tx_context::sender(ctx),
            github_repo_link: url::new_unsafe_from_bytes(github_repo_link),
            balance: balance::zero<T>(),
            flow_balance: 0u64,
            upper_bound,
        }
    }

    public entry fun crowdfund_flow<T: drop>(
        crowd_fund: &mut CrowdFund<T>,
        donate_money: &mut Coin<T>,
        amount: u64,
        start_time: u64,
        stop_time: u64,
        global_config: &mut GlobalConfig,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        assert!(crowd_fund.open, EFundClose);
        let fundraised: u64 = balance::value<T>(&crowd_fund.balance);
        let to_donate: u64 = if (fundraised + crowd_fund.flow_balance + amount > crowd_fund.upper_bound)
            fundraised + crowd_fund.flow_balance + amount - crowd_fund.upper_bound
        else
            amount;
        let to_donate_coin: Coin<T> = coin::split(donate_money, to_donate, ctx);

        emit(CrowdFundSponsor {
            id: object::id(crowd_fund),
            sender: tx_context::sender(ctx),
            amount: to_donate,
        });

        crowd_fund.flow_balance = crowd_fund.flow_balance + to_donate;

        stream::create<T>(
            global_config,
            to_donate_coin,
            utf8(object::uid_to_bytes(&crowd_fund.id)),
            utf8(b"crowdfund"),
            crowd_fund.owner,
            to_donate,
            start_time,
            stop_time,
            1,
            false,
            false,
            clock,
            ctx,
        );
    }

    public entry fun crowdfund_flow_withdraw<T: drop>(
        crowd_fund: &mut CrowdFund<T>,
        stream: &mut StreamInfo<T>,
        clock: &Clock,
        ctx: &mut TxContext
    ) {
        assert!(crowd_fund.owner == tx_context::sender(ctx), ENotOwner);
        let withdaw_value = stream::get_withdrawn_amount(stream);

        stream::withdraw(stream, clock, ctx);

        withdaw_value = stream::get_withdrawn_amount(stream) - withdaw_value;
        crowd_fund.flow_balance =  crowd_fund.flow_balance - withdaw_value;
        crowd_fund.upper_bound = crowd_fund.upper_bound - withdaw_value;

        emit(CrowdFundWithdraw {
            id: object::id(crowd_fund),
            owner: tx_context::sender(ctx),
            amount: 0,
        });
    }
}