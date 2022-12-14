// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import {Test} from 'forge-std/Test.sol';

import {CLSynchronicityPriceAdapterPegToBase} from '../src/contracts/CLSynchronicityPriceAdapterPegToBase.sol';

contract CLSynchronicityPriceAdapterPegToBaseTest is Test {
  address public constant ETH_USD_AGGREGATOR =
    0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;
  address public constant STETH_ETH_AGGREGATOR =
    0x86392dC19c0b719886221c78AB11eb8Cf5c52812;

  function setUp() public {
    vm.createSelectFork(vm.rpcUrl('ethereum'), 15588955);
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
