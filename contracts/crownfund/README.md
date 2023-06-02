## Contract on Chain

* **Devnet:** https://suiexplorer.com/object/0x2c297642770b19c384247da8f2493a5e4c99c1b26812d08f388dd65ce19883f1?network=devnet 

## Main Functions 

实现如下函数：

- [x] create_corwdfund_upperbound(tx_sender, github_repo_link, money_type, money_required) 有金额上限

- [x] create_corwdfund_unbound(tx_sender, github_repo_link) 无金额上限

- [x] close_corwdfund(unique_id) 关闭已有众筹

- [x] list_corwdfund() 列出所有的众筹 链下查询

- [x] list_corwdfund_opened() 列出所有的还在开放的众筹 链下查询

- [ ] check_corwdfund(unique_id) 列出该众筹的信息  链下查询 不在合约上实现，通过Sui CLI或SDK查询

- [x] withdraw_corwdfund(tx_sender, unique_id) 提款

- [x] corwdfund(unique_id) 向指定众筹进行打款

