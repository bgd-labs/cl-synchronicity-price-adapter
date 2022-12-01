// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IChainlinkAggregator} from '../interfaces/IChainlinkAggregator.sol';
import {ICLSynchronicityPriceAdapter} from '../interfaces/ICLSynchronicityPriceAdapter.sol';
import {IStETH} from '../interfaces/IStETH.sol';

/**
 * @title CLwstETHSynchronicityPriceAdapter
 * @author BGD Labs
 * @notice Price adapter to calculate price of (wstETH / USD) pair by using
 * @notice Chainlink Data Feeds for (wstETH / ETH) and (ETH / USd) pairs and (wstETH / stETH) ratio.
 */
contract CLwstETHSynchronicityPriceAdapter is ICLSynchronicityPriceAdapter {
  /**
   * @notice Price feed for (USD / ETH) pair
   */
  IChainlinkAggregator public immutable ETH_TO_USD;

  /**
   * @notice Price feed for (stETH / ETH) pair
   */
  IChainlinkAggregator public immutable STETH_TO_ETH;

  /**
   * @notice stETH token contract
   */
  IStETH public immutable STETH;

  /**
   * @notice Number of decimals in the output of this price adapter
   */
  uint8 public immutable DECIMALS;

  /**
   * @notice First multiplier used in formula for calculating price to
   * @notice achive desired number of resulting decimals.
   */
  int256 public immutable DECIMALS_MULTIPLIER_1;

  /**
   * @notice Second multiplier used in formula for calculating price to
   * @notice achive desired number of resulting decimals.
   */
  int256 public immutable DECIMALS_MULTIPLIER_2;

  /**
   * @notice Number of decimals for wstETH / ETH ratio
   */
  uint8 public constant RATIO_DECIMALS = 18;

  /**
   * @notice Maximum number of resulting and feed decimals
   */
  uint8 public constant MAX_DECIMALS = 18;

  constructor(
    address ethToUsdAggregatorAddress,
    address stEthToEthAggregatorAddress,
    uint8 decimals,
    address stETHAddress
  ) {
    ETH_TO_USD = IChainlinkAggregator(ethToUsdAggregatorAddress);
    STETH_TO_ETH = IChainlinkAggregator(stEthToEthAggregatorAddress);
    STETH = IStETH(stETHAddress);

    if (decimals > MAX_DECIMALS) revert DecimalsAboveLimit();
    if (ETH_TO_USD.decimals() > MAX_DECIMALS) revert DecimalsAboveLimit();
    if (STETH_TO_ETH.decimals() > MAX_DECIMALS) revert DecimalsAboveLimit();

    DECIMALS = decimals;

    DECIMALS_MULTIPLIER_1 = int256(10 ** decimals);
    DECIMALS_MULTIPLIER_2 = int256(
      10 ** (STETH_TO_ETH.decimals() + ETH_TO_USD.decimals() + RATIO_DECIMALS)
    );
  }

  function latestAnswer() external view override returns (int256) {
    int256 stethToEthPrice = STETH_TO_ETH.latestAnswer();
    int256 ethToUsdPrice = ETH_TO_USD.latestAnswer();

    int256 ratio = int256(STETH.getPooledEthByShares(10 ** RATIO_DECIMALS));

    return
      (ethToUsdPrice *
        stethToEthPrice *
        int256(ratio) *
        DECIMALS_MULTIPLIER_1) / (DECIMALS_MULTIPLIER_2);
  }
}
