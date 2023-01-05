// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {CLSynchronicityPriceAdapterPegToBase} from '../src/contracts/CLSynchronicityPriceAdapterPegToBase.sol';

contract DeployWstETH is Script {
  address public constant BTC_USD_AGGREGATOR =
    0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c;
  address public constant WBTC_BTC_AGGREGATOR =
    0xfdFD9C85aD200c506Cf9e21F1FD8dd01932FBB23;

  function run() external {
    vm.startBroadcast();

    new CLSynchronicityPriceAdapterPegToBase(
      BTC_USD_AGGREGATOR,
      WBTC_BTC_AGGREGATOR,
      8
    );

    vm.stopBroadcast();
  }
}
