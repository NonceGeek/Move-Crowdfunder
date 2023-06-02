
import { NETWORK, SUI_PACKAGE, SUI_MODULE } from "../config/constants";

const ExplorerBase = "https://explorer.sui.io";

export function TransacitonLink(digest: string, module: string) {
    return `${ExplorerBase}/txblock/${digest}?module=${module}&network=${NETWORK}`
}

export function ObjectLink(objectId: string) {
    return `${ExplorerBase}/object/${objectId}?network=${NETWORK}`;
}

export function PackageLink(packageId: string) {
    return `${ExplorerBase}/object/${packageId}?network=${NETWORK}`;
}

export function CallTarget(funName: string) {
    return `${SUI_PACKAGE}::${SUI_MODULE}::${funName}`;
}

export function AddressLink(address: string) {
    return `${ExplorerBase}/address/${address}?network=${NETWORK}`;
}