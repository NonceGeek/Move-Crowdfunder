import { NavItem } from "./NavItem";
import { SuiConnect } from "./SuiConnect";
import { PackageLink } from "../utils/links";
import {
  SUI_PACKAGE
} from "../config/constants";

export function NavBar() {
  return (
    <nav className="navbar py-4 px-4 bg-base-100">
      <div className="flex-1">
        <a href="/">
          Move & Crownfund
        </a>
        <ul className="menu menu-horizontal p-0 ml-5">
          <NavItem href="/" title="Crownfund List" />
          <NavItem href="/create" title="Create Crownfund" />
          <li className="font-sans font-semibold text-lg">
            <a href={PackageLink(SUI_PACKAGE)} target="_blank" rel="noreferrer">Contract on Explorer</a>
          </li>
        </ul>
      </div>
      <SuiConnect />
    </nav>
  );
}
