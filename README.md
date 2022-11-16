# Price adapter for stablecoins
Repository containing the necessary smart contracts to propose using price adapter for stablecoins on the **Aave v2 Ethereum** and **Aave Arc** markets.

The Aave v2 market on Ethereum uses ETH based oracles to calculate the collateral value, debt value and health factor of a user. This, coupled with the delay at which different price feeds update, introduces unnecessary volatility in positions that involve stablecoins used both as collateral and as debt. The proposal is to replace the current ETH based oracles for stablecoins by using USD pairs instead, and normalizing the USD price using the ETH oracle. This reduces the volatility between stablecoins as all the stablecoin price feeds will update atomically when the ETH price changes.

### AaveOracle 

Affected smart contract is `AaveOracle`, where currently all asset sources are set to [Chainlink Data Feeds](https://docs.chain.link/docs/ethereum-addresses/) for pairs $Asset / ETH$.

Proposal is to deploy `CLSynchronicityPriceAdapter` for all stablecoin assets, which will calculate the price of `Asset / ETH` by querying Chainlink Data Feeds for pairs `Asset / USD` and `ETH / USD`, using the formula:
$$Price(Asset / ETH) = {DataFeed(Asset / USD) \over DataFeed(ETH / USD)}$$

Proposal is to change asset source for all stablecoin assets to be `CLSynchronicityPriceAdapter` which calculates price by querying Chainlink Data Feeds for pairs `Asset / USD` and `ETH / USD`. 

### Other Aave markets

Same idea can be used for other Aave markets where `USD` is base currency to peg group of ETH-correlated assets to the value of `ETH`.


## Implementations

### Price Adapter
[CLSynchronicityPriceAdapter](/src/contracts/CLSynchronicityPriceAdapter.sol)

- Price adapter smart contract where `ChainlinkAggregator` addresses for `Asset / USD` and `ETH / USD` are set.
- Using this two feeds, it calculates the price for pair `Asset / ETH`. 
- Returning price is calculated with 18 decimals.
- If `Asset / USD` feed decimals is bigger than the sum of resulting decimals and `ETH / USD` feed decimals, then constructor will revert with `DecimalsMultiplierIsZero` error.

### Governance Payloads

[ProposalPayloadStablecoinsPriceAdapter](/src/contracts/ProposalPayloadStablecoinsPriceAdapter.sol)

- Proposal payload for the Aave v2 Ethereum market. 
- For all Aave v2 Ethereum stablecoin assets deploys `CLSynchronicityPriceAdapter` and sets it as an asset source by calling `setAssetSources` function on the `AaveOracle` contract.

[ArcProposalPayloadStablecoinsPriceAdapter](/src/contracts/ArcProposalPayloadStablecoinsPriceAdapter.sol)

- Proposal payload for the Aave Arc market. 
- For all Aave Arc stablecoin assets deploys `CLSynchronicityPriceAdapter` and sets it as an asset source by calling `setAssetSources` function on the `AaveOracle` contract.

## Aave v2 Ethereum stablecoin assets and USD price feeds
List of affected Aave v2 Ethereum stablecoin assets and used Chainlink Data Feeds for `Asset / USD` pair.
| Asset | Asset address | Chainlink Data Feed address |
| --- | --- | --- |
| USDT | 0xdAC17F958D2ee523a2206206994597C13D831ec7 | 0x3E7d1eAB13ad0104d2750B8863b489D65364e32D |
| BUSD | 0x4Fabb145d64652a948d72533023f6E7A623C7C53 | 0x833D8Eb16D306ed1FbB5D7A2E019e106B960965A |
| DAI | 0x6B175474E89094C44Da98b954EedeAC495271d0F | 0xAed0c38402a5d19df6E4c03F4E2DceD6e29c1ee9 |
| SUSD | 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51 | 0xad35Bd71b9aFE6e4bDc266B345c198eaDEf9Ad94 |
| tUSD | 0x0000000000085d4780B73119b644AE5ecd22b376 | 0xec746eCF986E2927Abd291a2A1716c940100f8Ba |
| USDC | 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 | 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6 |
| GUSD | 0x056Fd409E1d7A124BD7017459dFEa2F387b6d5Cd | 0xa89f5d2365ce98B3cD68012b6f503ab1416245Fc |
| USDP | 0x8E870D67F660D95d5be530380D0eC0bd388289E1 | 0x09023c0DA49Aaf8fc3fA3ADF34C6A7016D38D5e3 |
| FRAX | 0x853d955aCEf822Db058eb8505911ED77F175b99e | 0xB9E1E3A9feFf48998E45Fa90847ed4D467E8BcfD |
| LUSD | 0x5f98805A4E8be255a32880FDeC7F6728C6568bA0 | 0x3D7aE7E594f2f2091Ad8798313450130d0Aba3a0 |

## Aave v2 ARC stablecoin assets and USD price feeds
List of affected Aave v2 Arc stablecoin assets and used Chainlink Data Feeds for `Asset / USD` pair.

| Asset | Asset address | Chainlink Data Feed address |
| --- | --- | --- |
| USDC | 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48 | 0x8fFfFfd4AfB6115b954Bd326cbe7B4BA576818f6 |


## Security

### Foundry Tests

[CLSynchronicityPriceAdapterFormulaTest](./src/test/CLSynchronicityPriceAdapterFormulaTest.sol)

- Validates that formula used in price adapter is correct.
- For `TESTS_NUM` number of tests, makes mock aggregator with price of asset in `i-th` test set to $Price(ETH / USD) \over i$. Validates that price returned from the `CLSynchronicityPriceAdapter` is $1 ETHER /over i$.

[PriceChangeTest](./src/test/PriceChangeTest.sol)

- Validates that price difference between price feed for pair `Asset / ETH` and price from the adapter is less than `2%`.

[ProposalPayloadStablecoinsPriceAdapterTest](./src/test/ProposalPayloadStablecoinsPriceAdapterTest.sol)

- Validates that after proposal in Aave v2 Ethereum market is accepted, all asset sources for stablecoin assets are changed.

[ArcProposalPayloadStablecoinsPriceAdapterTest](./src/test/ArcProposalPayloadStablecoinsPriceAdapterTest.sol)

- Validates that after proposal in Aave v2 Ethereum market is accepted, all asset sources for stablecoin assets are changed.


### Audits

_TBD_

## Setup

### Install

To install and execute the project locally, you need:

- `npm install` : To install prettier for linting.
- `forge install` : This project is made using [Foundry](https://book.getfoundry.sh/) so to run it you will need to install it, and then install its dependencies.

### Setup environment

```sh
cp .env.example .env
```

### Build

```sh
forge build
```

### Test

```sh
forge test
```

### Copyright

2022 BGD Labs
