import { TransactionBlock } from "@mysten/sui.js";
import { useWallet } from "@suiet/wallet-kit";
import { useState } from "react";
import { CallTarget } from "../utils/links";
import { SHARE_FUND_INFO } from "../config/constants"

export default function CreateFund() {
    const [result, updateResult] = useState("");
    const { signAndExecuteTransactionBlock } = useWallet();
    const [coinType, updateCoinType] = useState("0x2::sui::SUI");
    const [githubLink, updateGithubLink] = useState("https://github.com/v1xingyue/");
    const [maxValue, updateMaxValue] = useState(100);

    console.log(SHARE_FUND_INFO);

    const createCrownFund = async () => {
        console.log("you will create one crownfund ... ");
        const tx = new TransactionBlock();
        console.log();
        const params = {
            target: CallTarget("create_crowdfund_upperbound") as any,
            typeArguments: [
                coinType
            ],
            arguments: [
                tx.pure(SHARE_FUND_INFO),
                tx.pure(githubLink),
                tx.pure(maxValue)
            ],
        };
        console.log(params);
        tx.moveCall(params);
        const result = await signAndExecuteTransactionBlock({
            transactionBlock: tx,
        });
        console.log(result);
        updateResult(JSON.stringify(result, null, 2));
    }

    return (
        <>
            <div className="card-body">
                <div className="card-title"> create CrownFund : </div>
                <input
                    placeholder="coin type"
                    className="mt-2 p-4 input input-bordered input-primary w-full"
                    value={coinType}
                    onChange={(e) =>
                        updateCoinType(e.target.value)
                    }
                />
                <input
                    placeholder="github link"
                    className="mt-2 p-4 input input-bordered input-primary w-full"
                    value={githubLink}
                    onChange={
                        (e) => {
                            updateGithubLink(e.target.value);
                        }
                    }
                />
                <input
                    placeholder="max value"
                    type="number"
                    className="mt-2 p-4 input input-bordered input-primary w-full"
                    value={maxValue}
                    onChange={
                        (e) => {
                            const max = parseInt(e.target.value);
                            updateMaxValue(max);
                        }
                    }
                />
                <button onClick={createCrownFund} className="btn btn-info">Create</button>
                <pre>
                    {result}
                </pre>
            </div>
        </>
    )

}