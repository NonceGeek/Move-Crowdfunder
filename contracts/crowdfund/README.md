## Contract on Chain

* **Testnet:** https://suiexplorer.com/object/0xc58d0096c328295048aaf3da84247d5814929005a5ab11dbef4286128e0832a6?network=testnet 

## Main Functions 

实现如下函数：

- [x] create_crowdfund_upperbound(tx_sender, github_repo_link, money_type, money_required) 有金额上限

- [x] create_crowdfund_unbound(tx_sender, github_repo_link) 无金额上限

- [x] close_crowdfund(unique_id) 关闭已有众筹

- [x] list_crowdfund() 列出所有的众筹 链下查询

- [x] list_crowdfund_opened() 列出所有的还在开放的众筹 链下查询

- [ ] check_crowdfund(unique_id) 列出该众筹的信息  链下查询 不在合约上实现，通过Sui CLI或SDK查询

- [x] withdraw_crowdfund(tx_sender, unique_id) 提款

- [x] crowdfund(unique_id) 向指定众筹进行打款

