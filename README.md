# AAVE V2 Collector Contract Consolidation

This repository contains the payload to consolidate long-tail assets in the collector into USDC, as well as redeeming AMM tokens per this proposal:
https://governance.aave.com/t/arfc-ethereum-v2-collector-contract-consolidation/10909

# Specification

The proposal does the following, separated in two parts:

- Asset Withdrawal -

Withdraws AMM tokens in the following markets:

DAI
USDC
USDT
WBTC
WETH

Converts it from the AMM version to the regular token.

It does so in

```
AMMWithdrawer.sol

function redeem() external {}
```

- Asset Consolidation -

The asset consolidation portion of this payload lets users exchange their USDC for some of the long-tail assets available in the Aave V2 Collector Contract. The assets are the following:

    ARAI
    AAMPL
    AFRAX
    FRAX
    AUST
    SUSD
    ASUSD
    TUSD
    ATUSD
    AMANA
    MANA
    ABUSD
    BUSD
    ZRX
    AZRX
    AENS
    ADPI

```
AaveV2CollectorContractConsolidation.sol

function purchase(address _token, uint256 _amountOut) external {}
```

This function lets the user specify which token they want to get out and how much they want to get out and will then use the sender's USDC to do so.
(Needs to approve the contract to spend USDC first)

Note: UST oracle no longer listed in the Chainlink site, but the contract can still be found [here](https://etherscan.io/address/0xa20623070413d42a5C01Db2c8111640DD7A5A03a).
AAVE UST page can also be found [here](https://app.aave.com/reserve-overview/?underlyingAsset=0xa693b19d2931d498c5b318df961919bb4aee87a5&marketName=proto_mainnet)

## Installation

It requires [Foundry](https://github.com/gakonst/foundry) installed to run. You can find instructions here [Foundry installation](https://github.com/gakonst/foundry#installation).

### GitHub template

It's easiest to start a new project by clicking the ["Use this template"](https://github.com/llama-community/aave-governance-forge-template).

Then clone the templated repository locally and `cd` into it and run the following commands:

```sh
$ npm install
$ forge install
$ forge update
$ git submodule update --init --recursive
```

### Manual installation

If you want to create your project manually, run the following commands:

```sh
$ forge init --template https://github.com/llama-community/aave-governance-forge-template <my-repo>
$ cd <my-repo>
$ npm install
$ forge install
$ forge update
$ git submodule update --init --recursive
```

## Setup

Duplicate `.env.example` and rename to `.env`:

- Add a valid mainnet URL for an Ethereum JSON-RPC client for the `RPC_MAINNET_URL` variable.
- Add a valid Private Key for the `PRIVATE_KEY` variable.
- Add a valid Etherscan API Key for the `ETHERSCAN_API_KEY` variable.

### Commands

- `make build` - build the project
- `make test [optional](V={1,2,3,4,5})` - run tests (with different debug levels if provided)
- `make match MATCH=<TEST_FUNCTION_NAME> [optional](V=<{1,2,3,4,5}>)` - run matched tests (with different debug levels if provided)

### Deploy and Verify

- `make deploy-payload` - deploy and verify payload on mainnet
- `make deploy-proposal`- deploy proposal on mainnet

To confirm the deploy was successful, re-run your test suite but use the newly created contract address.
