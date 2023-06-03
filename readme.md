# Move Crowdfund

Buidl on Sui, flow crowdfunding tool backed by Moveflow protocol.

As Public Goods, Move Crowdfund is a critical part to construct the Github-based ecosystem. With it, we can raise crowd funding for Github Repo or Github Organization.

Employment of Moveflow and flow payment protocol on Move makes whole crowdfunding process more flexible and much cooler.

## Move Crowdfund dApp

> https://move-crowdfund.vercel.app/

## Move Crowdfund Smart Contract

Contract Introduction seem in:

> https://github.com/NonceGeek/Move-Crowdfund/tree/main/contracts

## Backend

A Lightweight Backend impl using tai_shang_micro_faas, seem in:

> https://github.com/NonceGeek/Move-Crowdfund/tree/main/backend

## Create one dapp with scaffold-sui

```shell
npx create-move-app sui-demo --chain sui
```

## Develop with source code

1. git clone <https://github.com/NonceGeek/Move-Crowdfund.git>
2. cd scaffold-move
3. yarn
4. cat .env.local.example

    NEXT_PUBLIC_DAPP_PACKAGE  address of your sui module
    NEXT_PUBLIC_DAPP_MODULE sample module name
5. yarn dev
6. yarn build # build for production.

## Finally

This product is mainly maintenance under [NonceGeek DAO](https://noncegeek.com/#/).
