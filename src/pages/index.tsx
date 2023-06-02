import { JsonRpcProvider, devnetConnection, mainnetConnection, testnetConnection, TransactionBlock } from "@mysten/sui.js";
import { SuiMainnetChain, SuiTestnetChain, useWallet } from "@suiet/wallet-kit";
import { useEffect, useState } from "react";
import { SHARE_FUND_INFO } from "../config/constants";
import { AddressLink, CallTarget, ObjectLink } from "../utils/links";


const Home = () => {
  const [displayModal, toggleDisplay] = useState(false);
  const [openFunds, updateOpenFunds] = useState<Array<any>>([]);
  const [transaction, updateTransaction] = useState<any>({});
  const [donateCoinId, updateDonateCoinId] = useState("");
  const [donateCoinType, updateDonateCoinType] = useState("");
  const [donateFundId, updateDonateFundId] = useState("");
  const [donateValue, updateDonateValue] = useState(100);



  const { connected, chain, address, signAndExecuteTransactionBlock } = useWallet();
  let connection = devnetConnection;
  if (chain === SuiTestnetChain) {
    connection = testnetConnection;
  } else if (chain === SuiMainnetChain) {
    connection = mainnetConnection;
  }
  const provider = new JsonRpcProvider(connection);

  const fetchCrownFund = async () => {
    const fundInfo = await provider.getObject({
      id: SHARE_FUND_INFO,
      options: {
        showType: true,
        showContent: true,
        showDisplay: false,
      }
    });
    console.log(`fund_info ${fundInfo}`);
    const fundData = fundInfo.data?.content as any;
    const openIds = fundData.fields.total.fields.contents as Array<string>;
    console.log(`open_ids ${openIds}`);
    const openFunds = await provider.multiGetObjects({
      ids: openIds, options: {
        showContent: true
      }
    });
    console.log(openFunds);
    updateOpenFunds(openFunds);
  }

  useEffect(() => {
    (async () => {
      if (connected) {
        fetchCrownFund()
      }
    })()
  }, [connected, transaction])

  const doDonatePrepare = async (fund: any) => {
    console.log(fund);
    const coinType: string = fund.data.content.type;
    coinType.indexOf("");
    const pattern = /::crowdfund::CrowdFund<([^>]+)>/;
    const matches = coinType.match(pattern);
    if (matches && matches?.length > 0) {
      updateDonateFundId(fund.data.objectId);
      const match = matches[1];
      console.log(`fetch donate coins for ${match} `);
      updateDonateCoinType(match);
      const donateCoins = await provider.getOwnedObjects({
        owner: address as string,
        filter: {
          StructType: `0x2::coin::Coin<${match}>`
        },
        options: {
          showContent: true,
        }
      });
      console.log(`donate coins ${donateCoins.data.length}`);
      console.log(donateCoins.data);

      if (donateCoins.data.length > 0) {
        updateDonateCoinId(donateCoins.data[0].data?.objectId as string);
        toggleDisplay(true);
      } else {
        alert(`sorry you don't have enough coins for ${match}`);
      }
    }
  };

  const doCloseFund = async (fund: any) => {
    console.log("you will close one crownfund ... ");
    const tx = new TransactionBlock();
    const coinType: string = fund.data.content.type;
    coinType.indexOf("");
    const pattern = /::crowdfund::CrowdFund<([^>]+)>/;
    const matches = coinType.match(pattern);
    if (matches && matches?.length > 0) {
      const match = matches[1];
      console.log(`fetch donate coins for ${match} `);
      const params = {
        target: CallTarget("close_crowdfund") as any,
        typeArguments: [
          match
        ],
        arguments: [
          tx.pure(SHARE_FUND_INFO),
          tx.pure(fund.data.objectId)
        ],
      };
      console.log(params);
      tx.moveCall(params);
      const result = await signAndExecuteTransactionBlock({
        transactionBlock: tx,
      });
      console.log(result);
      updateTransaction(result);
      alert(result);
    }
  }


  const doDonate = async () => {
    console.log("you will create one crownfund ... ");
    const tx = new TransactionBlock();
    console.log();
    const params = {
      target: CallTarget("crowdfund") as any,
      typeArguments: [
        donateCoinType
      ],
      arguments: [
        tx.pure(donateFundId),
        tx.pure(donateCoinId),
        tx.pure(donateValue)
      ],
    };
    console.log(params);
    tx.moveCall(params);
    const result = await signAndExecuteTransactionBlock({
      transactionBlock: tx,
    });
    console.log(result);
    alert(result);
    updateTransaction(result);
  }

  const doWithdraw = async (fund: any) => {
    console.log("you will Withdraw one crownfund ... ");
    const tx = new TransactionBlock();
    const coinType: string = fund.data.content.type;
    coinType.indexOf("");
    const pattern = /::crowdfund::CrowdFund<([^>]+)>/;
    const matches = coinType.match(pattern);
    if (matches && matches?.length > 0) {
      const match = matches[1];
      console.log(`fetch donate coins for ${match} `);
      const params = {
        target: CallTarget("withdraw_crowdfund") as any,
        typeArguments: [
          match
        ],
        arguments: [
          tx.pure(fund.data.objectId)
        ],
      };
      console.log(params);
      tx.moveCall(params);
      const result = await signAndExecuteTransactionBlock({
        transactionBlock: tx,
      });
      console.log(result);
      updateTransaction(result);
      alert(result);
    }
  }


  return (
    <>

      <div className={displayModal ? "modal modal-middle modal-open" : "modal modal-middle "}>
        <div className="modal-box">
          <label onClick={() => { toggleDisplay(false) }} className="btn btn-sm btn-circle absolute right-2 top-2">✕</label>
          <h3 className="font-bold text-lg">Confirm donate info : </h3>
          <input
            placeholder="coin objectId"
            className="mt-8 p-4 input input-bordered input-primary w-full"
            value={donateCoinId}
            onChange={e => updateDonateCoinId(e.target.value)}
          />
          <input
            placeholder="Recipient"
            className="mt-8 p-4 input input-bordered input-primary w-full"
            value={donateValue}
            type="number"
            onChange={(e) =>
              updateDonateValue(parseInt(e.target.value))
            }
          />
          <div className="modal-action">
            <label htmlFor="my-modal-6" className="btn" onClick={() => {
              toggleDisplay(!displayModal);
              doDonate();
            }}>Done!</label>
          </div>
        </div>
      </div>

      {
        openFunds.map((item: any) => {
          return (
            <div className="card lg:card-side bg-base-100 shadow-xl mt-1" key={item.data.objectId}>
              <div className="card-body">
                <p>
                  Explorer: <a href={ObjectLink(item.data.objectId)} className="link link-hover link-primary"> {item.data.objectId}</a>
                </p>
                <p className="ml-2">
                  <a className="link link-hover link-info" href={item.data.content.fields.github_repo_link}>{item.data.content.fields.github_repo_link}</a>
                </p>
                <p className="ml-2">
                  status:  {item.data.content.fields.open ? 'open' : 'closed'}
                </p>
                <p className="ml-2">
                  owner:  <a href={AddressLink(item.data.content.fields.owner)} className="link link-hover link-primary"> {item.data.content.fields.owner}</a>
                </p>
                <p className="ml-2">
                  coinType:  {item.data.content.type}
                </p>
                <p className="ml-2">
                  Balance: {item.data.content.fields.balance} / {item.data.content.fields.upper_bound}
                </p>
                <div className="card-actions">
                  <button className="ml-2 btn btn-outline btn-ghost" onClick={e => doWithdraw(item)}>Withdraw</button>
                  {item.data.content.fields.open ? (
                    <div>
                      <button className="ml-2 btn btn-outline btn-ghost" onClick={e => doDonatePrepare(item)}>Donate</button>
                      <button className="ml-2 btn btn-outline btn-error" onClick={e => doCloseFund(item)}>Close</button>
                    </div>
                  ) : null}
                </div>

              </div>
            </div>
          );
        })
      }
    </>
  );
};

export default Home;