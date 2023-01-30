// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {CLSynchronicityPriceAdapterPegToBase} from '../src/contracts/CLSynchronicityPriceAdapterPegToBase.sol';
import {BaseAggregators} from '../src/lib/BaseAggregators.sol';

contract DeploycbETH is Script {
  function run() external {
    vm.startBroadcast();

    new CLSynchronicityPriceAdapterPegToBase(
      BaseAggregators.ETH_USD_AGGREGATOR,
      BaseAggregators.CBETH_ETH_AGGREGATOR,
      8,
      'cbETH/ETH/USD'
    );

    vm.stopBroadcast();
  }
}