// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import {IChainlinkAggregator} from '../interfaces/IChainlinkAggregator.sol';
import {ICLSynchronicityPriceAdapter} from '../interfaces/ICLSynchronicityPriceAdapter.sol';

/**
 * @title CLSynchronicityPriceAdapter
 * @author BGD Labs
 * @notice Price adapter to calculate price of (Asset / Base) pair by using
 * @notice Chainlink Data Feeds for (Asset / Peg) and (Base / Peg) pairs.
 */
contract CLSynchronicityPriceAdapter is ICLSynchronicityPriceAdapter   {
    /**
     * @notice Price feed for (Base / Peg) pair
     */
    IChainlinkAggregator public immutable BASE_TO_PEG;

    /**
     * @notice Price feed for (Asset / Peg) pair
     */
    IChainlinkAggregator public immutable ASSET_TO_PEG;

    /**
     * @notice Number of decimals in the output of this price adapter
     */
    uint8 public immutable DECIMALS;

    /** 
     * @notice Multiplier used in formula for calculating price to 
     * @notice achive desired number of resulting decimals.
     */
    int256 public immutable DECIMALS_MULTIPLIER;

    /**
     * @notice Maximum number of resulting and feed decimals
     */
    uint8 public constant MAX_DECIMALS = 18;
    
    constructor(
        address baseToPegAggregatorAddress,
        address asseToPegAggregatorAddress,
        uint8 decimals
    ) {
        BASE_TO_PEG = IChainlinkAggregator(baseToPegAggregatorAddress);
        ASSET_TO_PEG = IChainlinkAggregator(asseToPegAggregatorAddress);

        if (decimals > MAX_DECIMALS) revert DecimalsAboveLimit();
        if (BASE_TO_PEG.decimals() > MAX_DECIMALS) revert DecimalsAboveLimit();
        if (ASSET_TO_PEG.decimals() > MAX_DECIMALS) revert DecimalsAboveLimit();

        DECIMALS = decimals;

        DECIMALS_MULTIPLIER = 
          _calcDecimalsMultiplier(
            ASSET_TO_PEG.decimals(),
            BASE_TO_PEG.decimals(),
            DECIMALS
          );

        if (DECIMALS_MULTIPLIER == 0) revert DecimalsMultiplierIsZero();
    }

    function latestAnswer() override external view returns (int256) {
        int256 assetToPegPrice = ASSET_TO_PEG.latestAnswer();
        int256 baseToPegPrice = BASE_TO_PEG.latestAnswer();
        
        return (assetToPegPrice * DECIMALS_MULTIPLIER) / baseToPegPrice;
    }

    function _calcDecimalsMultiplier(
        uint8 assetToPegDecimals, 
        uint8 baseToPegDecimals,
        uint8 resultDecimals
    ) internal pure returns(int256) {
        int256 multiplier = int256(10 ** resultDecimals);
        if (assetToPegDecimals < baseToPegDecimals) {
            multiplier *= int256(10 ** (baseToPegDecimals - assetToPegDecimals));
        } else {
            multiplier /= int256(10 ** (assetToPegDecimals - baseToPegDecimals));
        }
        return multiplier;
    }
}