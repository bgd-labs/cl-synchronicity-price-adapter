from brownie import reverts

"""
Tests for `CLSynchronicityPriceAdapter.sol`
"""

# Test `constructor()`
def test_deployment(accounts, CLSynchronicityPriceAdapter, ChainlinkAggregatorMock):
    ## Setup
    base_price = 2123 * 10**8 # 2,123 USD : 1 ETH
    base_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, base_price, 1)
    asset_price = 101 * 10**6 # 1.01 USDC : 1 USD
    asset_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, asset_price, 1)

    ## Action
    price_adapter_decimals = 18
    price_adapter = accounts[0].deploy(CLSynchronicityPriceAdapter, base_to_peg, asset_to_peg, price_adapter_decimals)

    ## Verification
    assert price_adapter.DECIMALS() == price_adapter_decimals
    assert price_adapter.DECIMALS_MULTIPLIER() == 10 ** price_adapter_decimals # both raw CL feeds have 8 decimals
    assert price_adapter.BASE_TO_PEG() == base_to_peg
    assert price_adapter.ASSET_TO_PEG() == asset_to_peg


# Test `_calcDecimalsMultiplier()` when it overflows the `int256` casting
def test_calc_decimals_overflow(accounts, custom_error, CLSynchronicityPriceAdapter, ChainlinkAggregatorMock):
    ## Setup
    base_price = 2123 * 10**8 # 2,123 USD : 1 ETH
    base_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, base_price, 1)
    asset_price = 101 * 10**6 # 1.01 USDC : 1 USD
    asset_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, asset_price, 1)

    ## Action
    price_adapter_decimals = 77
    with reverts(custom_error("DecimalsAboveLimit")):
        price_adapter = accounts[0].deploy(CLSynchronicityPriceAdapter, base_to_peg, asset_to_peg, price_adapter_decimals)


# Test `constructor()` when multiplier is zero
def test_calc_decimals_zero_multiplier(accounts, custom_error, CLSynchronicityPriceAdapter, ChainlinkAggregatorMock):
    base_decimals = 8
    base_price = 2123 * 10**base_decimals # 2,123 USD : 1 ETH
    base_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, base_price, 1)
    base_to_peg.setDecimals(base_decimals)

    asset_decimals = 12
    asset_price = 10**asset_decimals * 101 // 100 # 1.01 USDC : 1 USD
    asset_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, asset_price, 1)
    asset_to_peg.setDecimals(asset_decimals)

    ## Action
    price_adapter_decimals = 3 # asset is 12 and base is 8 so multiplier rounds to zero
    with reverts(custom_error("DecimalsMultiplierIsZero")):
        price_adapter = accounts[0].deploy(CLSynchronicityPriceAdapter, base_to_peg, asset_to_peg, price_adapter_decimals)


# Test `latestAnswer()`
def test_latest_answer(accounts, CLSynchronicityPriceAdapter, ChainlinkAggregatorMock):
    ## Setup
    base_price = 2123 * 10**8 # 2,123 USD : 1 ETH
    base_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, base_price, 1)

    asset_price = 101 * 10**6 # 1.01 USDC : 1 USD
    asset_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, asset_price, 1)

    price_adapter_decimals = 18
    price_adapter = accounts[0].deploy(CLSynchronicityPriceAdapter, base_to_peg, asset_to_peg, price_adapter_decimals)

    ## Action
    answer = price_adapter.latestAnswer()

    ## Verification
    multiplier = 10**price_adapter_decimals
    assert answer == asset_price * multiplier // base_price
    assert answer == 475_741_874_705_605


# Test `latestAnswer` with varying decimals for underlying feeds (base decimals higher)
def test_latest_answer_different_decimals(accounts, CLSynchronicityPriceAdapter, ChainlinkAggregatorMock):
    ## Setup
    base_decimals = 12
    base_price = 1_000_000 * 10**base_decimals # 1,000,000 USD : 1 ETH
    base_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, base_price, 1)
    base_to_peg.setDecimals(base_decimals)

    asset_decimals = 6
    asset_price = 10**asset_decimals * 99 // 100 # 0.99 USDC : 1 USD
    asset_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, asset_price, 1)
    asset_to_peg.setDecimals(asset_decimals)

    price_adapter_decimals = 18
    price_adapter = accounts[0].deploy(CLSynchronicityPriceAdapter, base_to_peg, asset_to_peg, price_adapter_decimals)

    ## Pre-Verification
    assert price_adapter.DECIMALS() == price_adapter_decimals
    assert price_adapter.DECIMALS_MULTIPLIER() == 10 ** (price_adapter_decimals + base_decimals - asset_decimals)
    assert price_adapter.BASE_TO_PEG() == base_to_peg
    assert price_adapter.ASSET_TO_PEG() == asset_to_peg

    ## Action
    answer = price_adapter.latestAnswer()

    ## Verification
    multiplier = 10**(18 - 6 + 12)
    assert answer == asset_price * multiplier // base_price


# Test `latestAnswer` with varying decimals for underlying feeds (base decimals lower)
def test_latest_answer_different_decimals_inverse(accounts, CLSynchronicityPriceAdapter, ChainlinkAggregatorMock):
    ## Setup
    base_decimals = 8
    base_price = 1_000_000 * 10**base_decimals # 1,000,000 USD : 1 ETH
    base_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, base_price, 1)
    base_to_peg.setDecimals(base_decimals)

    asset_decimals = 11
    asset_price = 10**asset_decimals * 99 // 100 # 0.99 USDC : 1 USD
    asset_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, asset_price, 1)
    asset_to_peg.setDecimals(asset_decimals)

    price_adapter_decimals = 18
    price_adapter = accounts[0].deploy(CLSynchronicityPriceAdapter, base_to_peg, asset_to_peg, price_adapter_decimals)

    ## Pre-Verification
    assert price_adapter.DECIMALS() == price_adapter_decimals
    assert price_adapter.DECIMALS_MULTIPLIER() == 10 ** (price_adapter_decimals + base_decimals - asset_decimals)
    assert price_adapter.BASE_TO_PEG() == base_to_peg
    assert price_adapter.ASSET_TO_PEG() == asset_to_peg

    ## Action
    answer = price_adapter.latestAnswer()

    ## Verification
    multiplier = 10**(18 - 11 + 8)
    assert answer == asset_price * multiplier // base_price


# Test `latestAnswer()` division by zero
def test_latest_answer_division_by_zero(accounts, CLSynchronicityPriceAdapter, ChainlinkAggregatorMock):
    ## Setup
    base_price = 0 # will cause division by zero issue
    base_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, base_price, 1)

    asset_price = 101 * 10**6 # 1.01 USDC : 1 USD
    asset_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, asset_price, 1)

    price_adapter_decimals = 18
    price_adapter = accounts[0].deploy(CLSynchronicityPriceAdapter, base_to_peg, asset_to_peg, price_adapter_decimals)

    ## Action
    with reverts():
        answer = price_adapter.latestAnswer()


# Test `latestAnswer()` multiplication overflow
def test_latest_answer_multiplication_overflow(accounts, CLSynchronicityPriceAdapter, ChainlinkAggregatorMock):
    ## Setup
    base_price = 2123 * 10**8 # 2,123 USD : 1 ETH
    base_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, base_price, 1)

    asset_price = 101 * 10**65 # will cause a multiplication overflow
    asset_to_peg = accounts[0].deploy(ChainlinkAggregatorMock, asset_price, 1)

    price_adapter_decimals = 18
    price_adapter = accounts[0].deploy(CLSynchronicityPriceAdapter, base_to_peg, asset_to_peg, price_adapter_decimals)

    ## Action
    with reverts():
        answer = price_adapter.latestAnswer()