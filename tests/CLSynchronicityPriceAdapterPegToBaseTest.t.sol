// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';

import {CLSynchronicityPriceAdapterPegToBase} from '../src/contracts/CLSynchronicityPriceAdapterPegToBase.sol';
import {IChainlinkAggregator} from '../src/interfaces/IChainlinkAggregator.sol';

contract CLSynchronicityPriceAdapterPegToBaseTest is Test {
  address public constant ETH_USD_AGGREGATOR =
    0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
  address public constant STETH_ETH_AGGREGATOR =
    0x86392dC19c0b719886221c78AB11eb8Cf5c52812;

  address public constant BTC_USD_AGGREGATOR =
    0xF4030086522a5bEEa4988F8cA5B36dbC97BeE88c;
  address public constant WBTC_BTC_AGGREGATOR =
    0xfdFD9C85aD200c506Cf9e21F1FD8dd01932FBB23;

  uint256 public constant startBlock = 15588955;
  uint256[8] internal forks;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ethereum'), startBlock);

    // uint256 blockNum = 15589000;

    // for (uint256 i; i < forks.length; i++) {
    //   forks[i] = vm.createFork(vm.rpcUrl('ethereum'), blockNum);
    //   blockNum += 100;
    // }
  }

  function testLatestAnswer() public {
    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
        ETH_USD_AGGREGATOR,
        STETH_ETH_AGGREGATOR,
        18
      );

    int256 price = adapter.latestAnswer();

    assertApproxEqAbs(
      uint256(price),
      1295000000000000000000, // value calculated manually for selected block
      1000000000000000000
    );
  }

  function testLatestAnswerWbtc() public {
    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
        BTC_USD_AGGREGATOR,
        WBTC_BTC_AGGREGATOR,
        8
      );

    int256 price = adapter.latestAnswer();

    assertApproxEqAbs(
      uint256(price),
      1923700000000, // value calculated manually for selected block
      10 ** 8
    );
  }

  function testLatestAnswerWbtcRelativelyBtcFeed() public {
    IChainlinkAggregator aggregator = IChainlinkAggregator(BTC_USD_AGGREGATOR);

    for (uint256 i; i < 10; i++) {
      CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
          BTC_USD_AGGREGATOR,
          WBTC_BTC_AGGREGATOR,
          8
        );

      int256 price = adapter.latestAnswer();
      int256 btcPrice = aggregator.latestAnswer();

      assertApproxEqRel(price, btcPrice, 0.0003e18); // 0.03%

      vm.rollFork(startBlock + 500 * (i + 1));
    }
  }

  function testPegToBaseOracleReturnsNegative() public {
    address mockAggregator1 = address(0);
    address mockAggregator2 = address(1);

    _setMockPrice(mockAggregator1, -1, 4);
    _setMockPrice(mockAggregator2, 10000, 4);

    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
        mockAggregator1,
        mockAggregator2,
        4
      );

    int256 price = adapter.latestAnswer();

    assertEq(price, 0);
  }

  function testAssetToPegOracleReturnsZero() public {
    address mockAggregator1 = address(0);
    address mockAggregator2 = address(1);

    _setMockPrice(mockAggregator1, 10000, 4);
    _setMockPrice(mockAggregator2, 0, 4);

    CLSynchronicityPriceAdapterPegToBase adapter = new CLSynchronicityPriceAdapterPegToBase(
        mockAggregator1,
        mockAggregator2,
        4
      );

    int256 price = adapter.latestAnswer();

    assertEq(price, 0);
  }

  function _setMockPrice(
    address mockAggregator,
    int256 mockPrice,
    uint256 decimals
  ) internal {
    bytes memory latestAnswerCall = abi.encodeWithSignature('latestAnswer()');
    bytes memory decimalsCall = abi.encodeWithSignature('decimals()');

    vm.mockCall(mockAggregator, latestAnswerCall, abi.encode(mockPrice));
    vm.mockCall(mockAggregator, decimalsCall, abi.encode(decimals));
  }
}
