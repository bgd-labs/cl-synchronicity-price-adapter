// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

interface ICLSynchronicityPriceAdapter {
  function latestAnswer() external view returns (int256);

  error DecimalsMultiplierIsZero();
  error DecimalsAboveLimit();
}