// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';

import {CLwstETHSynchronicityPriceAdapter} from '../src/contracts/CLwstETHSynchronicityPriceAdapter.sol';
import {IChainlinkAggregator} from '../src/interfaces/IChainlinkAggregator.sol';
import {IStETH} from '../src/interfaces/IStETH.sol';

contract WstETHPriceAdapterFormulaTest is Test {
  address public constant ETH_USD_AGGREGATOR =
    address(0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419);
  address public constant StETH_ETH_AGGREGATOR =
    address(0x86392dC19c0b719886221c78AB11eb8Cf5c52812);
  address public constant STETH =
    address(0xae7ab96520DE3A18E5e111B5EaAb095312D7fE84);

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ethereum'), 16091725);
  }

  function testLatestAnswer() public {
    CLwstETHSynchronicityPriceAdapter adapter = new CLwstETHSynchronicityPriceAdapter(
        ETH_USD_AGGREGATOR,
        StETH_ETH_AGGREGATOR,
        8,
        STETH
      );

    int256 price = adapter.latestAnswer();

    // 1275 * 0.989 * 1.0988 ~ 1386
    assertApproxEqAbs(uint256(price), 138600000000, 100000000);
  }
}
