module crownfund::crownfund {
    use sui::transfer;
    use sui::balance::{Self, Balance};
    use sui::coin::{Self, Coin};
    use sui::object::{Self, UID, ID};
    use sui::vec_set::{Self, VecSet};
    use sui::tx_context::{Self, TxContext};
    use sui::url::{Self, Url};
    use sui::event::emit;

    const MAXU64: u64 = 18446744073709551615u64;

    // Errors
    const ENotOwner: u64 = 0;
    const EFundClose: u64 = 1;

    struct CrownFund<phantom T> has key, store {
        id: UID,
        open: bool,
        owner: address,
        github_repo_link: Url,
        balance: Balance<T>,
        upper_bound: u64,
    }

    struct FundInfo has key {
        id: UID,
        open: VecSet<ID>,
        total: VecSet<ID>,
    }

    // Events
    struct CrownFundCreated has copy, drop {
        id: ID,
    }

    struct CrownFundClosed has copy, drop {
        id: ID,
    }

    struct CrownFundWithdraw has copy, drop {
        id: ID,
        owner: address,
        amount: u64,
    }

    struct CrownFundSponsor has copy, drop {
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

    public entry fun create_crownfund_unbound<T: drop>(fund_info: &mut FundInfo, github_repo_link: vector<u8>, ctx: &mut TxContext) {
        let crown_fund: CrownFund<T> = new_crownfund<T>(github_repo_link, MAXU64, ctx);
        let fund_id: ID = object::id(&crown_fund);
        vec_set::insert(&mut fund_info.open, fund_id);
        vec_set::insert(&mut fund_info.total, fund_id);
        emit(CrownFundCreated { id: fund_id });
        transfer::public_share_object(crown_fund);
    }

    public entry fun create_crownfund_upperbound<T: drop>(fund_info: &mut FundInfo, github_repo_link: vector<u8>, upper_bound: u64, ctx: &mut TxContext) {
        let crown_fund: CrownFund<T> = new_crownfund<T>(github_repo_link, upper_bound, ctx);
        let fund_id: ID = object::id(&crown_fund);
        vec_set::insert(&mut fund_info.open, fund_id);
        vec_set::insert(&mut fund_info.total, fund_id);
        emit(CrownFundCreated { id: fund_id });
        transfer::public_share_object(crown_fund);
    }

    public entry fun close_crownfund<T: drop>(fund_info: &mut FundInfo, crown_fund: &mut CrownFund<T>, ctx: &mut TxContext) {
        assert!(crown_fund.owner == tx_context::sender(ctx), ENotOwner);
        crown_fund.open = false;
        let fund_id: ID = object::id(crown_fund);
        vec_set::remove(&mut fund_info.open, &fund_id);
        emit(CrownFundClosed { id: fund_id });
    }

    public entry fun withdraw_crownfund<T: drop>(crown_fund: &mut CrownFund<T>, ctx: &mut TxContext) {
        assert!(crown_fund.owner == tx_context::sender(ctx), ENotOwner);
        emit(CrownFundWithdraw {
            id: object::id(crown_fund),
            owner: tx_context::sender(ctx),
            amount: balance::value(&crown_fund.balance),
        });
        let return_coin: Coin<T> = coin::from_balance(balance::withdraw_all(&mut crown_fund.balance), ctx);
        transfer::public_transfer(return_coin, tx_context::sender(ctx));
    }

    public entry fun crownfund<T: drop>(crown_fund: &mut CrownFund<T>, donate_money: &mut Coin<T>, amount: u64, ctx: &mut TxContext) {
        assert!(crown_fund.open, EFundClose);
        let fundraised: u64 = balance::value<T>(&crown_fund.balance);
        let to_donate: u64 = if (fundraised + amount > crown_fund.upper_bound) fundraised + amount - crown_fund.upper_bound else amount;
        let to_donate_coin: Coin<T> = coin::split(donate_money, to_donate, ctx);
        emit(CrownFundSponsor {
            id: object::id(crown_fund),
            sender: tx_context::sender(ctx),
            amount: to_donate,
        });
        coin::put<T>(&mut crown_fund.balance, to_donate_coin);
    }

    public fun list_crownfund(fund_info: &FundInfo): VecSet<ID> {
        fund_info.total
    }

    public fun list_crownfund_opened(fund_info: &FundInfo): VecSet<ID> {
        fund_info.open
    }

    fun new_crownfund<T: drop>(github_repo_link: vector<u8>, upper_bound: u64, ctx: &mut TxContext): CrownFund<T> {
        CrownFund<T> {
            id: object::new(ctx),
            open: true,
            owner: tx_context::sender(ctx),
            github_repo_link: url::new_unsafe_from_bytes(github_repo_link),
            balance: balance::zero<T>(),
            upper_bound,
        }
    }

}