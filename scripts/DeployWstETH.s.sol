// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Script} from 'forge-std/Script.sol';
import {CLwstETHSynchronicityPriceAdapter} from '../src/contracts/CLwstETHSynchronicityPriceAdapter.sol';

contract DeployWstETH is Script {
  address public constant ETH_USD_AGGREGATOR =
    0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
  address public constant STETH_ETH_AGGREGATOR =
    0x86392dC19c0b719886221c78AB11eb8Cf5c52812;
  address public constant STETH = 0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84;

  function run() external {
    vm.startBroadcast();

    new CLwstETHSynchronicityPriceAdapter(
      ETH_USD_AGGREGATOR,
      STETH_ETH_AGGREGATOR,
      18,
      STETH
    );

    vm.stopBroadcast();
  }
}
