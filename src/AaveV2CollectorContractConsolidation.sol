// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {AaveV2Ethereum} from "@aave-address-book/AaveV2Ethereum.sol";
import {AggregatorV3Interface} from "./external/AggregatorV3Interface.sol";
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";
import "@forge-std/console.sol";

/// @title AaveV2CollectorContractConsolidation
/// @author Llama
/// @notice Contract to swap excess assets for USDC at a discount
contract AaveV2CollectorContractConsolidation {
    using SafeERC20 for ERC20;

    uint256 public immutable USDC_DECIMALS;
    uint256 public immutable ETH_USD_ORACLE_DECIMALS;
    ERC20 public constant USDC = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public constant ETH_USD_FEED = 0x5f4eC3Df9cbd43714FE2740f5E3616155c5b8419;

    address public constant ARAI = 0xc9BC48c72154ef3e5425641a3c747242112a46AF;
    address public constant AAMPL = 0x1E6bb68Acec8fefBD87D192bE09bb274170a0548;
    address public constant AFRAX = 0xd4937682df3C8aEF4FE912A96A74121C0829E664;
    address public constant FRAX = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    address public constant AUST = 0xc2e2152647F4C26028482Efaf64b2Aa28779EFC4;
    address public constant SUSD = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
    address public constant ASUSD = 0x6C5024Cd4F8A59110119C56f8933403A539555EB;
    address public constant TUSD = 0x0000000000085d4780B73119b644AE5ecd22b376;
    address public constant ATUSD = 0x101cc05f4A51C0319f570d5E146a8C625198e636;
    address public constant AMANA = 0xa685a61171bb30d4072B338c80Cb7b2c865c873E;
    address public constant MANA = 0x0F5D2fB29fb7d3CFeE444a200298f468908cC942;
    address public constant ABUSD = 0xA361718326c15715591c299427c62086F69923D9;
    address public constant BUSD = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
    address public constant ZRX = 0xE41d2489571d322189246DaFA5ebDe1F4699F498;
    address public constant AZRX = 0xDf7FF54aAcAcbFf42dfe29DD6144A69b629f8C9e;
    address public constant ARENFIL = 0x514cd6756CCBe28772d4Cb81bC3156BA9d1744aa;
    address public constant AENS = 0x9a14e23A58edf4EFDcB360f68cd1b95ce2081a2F;
    address public constant ADPI = 0x6F634c6135D2EBD550000ac92F494F9CB8183dAe;

    event Swap(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    /// Not enough token left to swap
    error NotEnoughTokens();
    /// Oracle price is 0 or lower
    error InvalidOracleAnswer();
    /// Need to request more than 0 tokens out
    error OnlyNonZeroAmount();
    /// Token is not available for swap
    error UnsupportedToken();

    struct Asset {
        uint256 quantity;
        uint48 premium;
        address oracle;
        uint8 decimals;
        uint8 oracleDecimals;
        bool ethFeedOnly;
    }

    mapping(address => Asset) public assets;

    constructor() {
        assets[ARAI] = Asset(6740239e16, 100, 0x483d36F6a1d063d580c7a24F9A42B346f3a69fbb, ERC20(ARAI).decimals(), 8, false); // Custom Feed
        assets[AAMPL] = Asset(15891248e16, 300, 0xe20CA8D7546932360e37E9D72c1a47334af57706, ERC20(AAMPL).decimals(), 18, false); // Monitored Feed
        assets[ADPI] = Asset(1359e16, 300, 0xD2A593BF7594aCE1faD597adb697b5645d5edDB2, ERC20(ADPI).decimals(), 8, false); // Monitored Feed
        assets[AUST] = Asset(89239797e16, 200, address(0), ERC20(AUST).decimals(), 0, false); // NO FEED
        assets[ARENFIL] = Asset(41067e16, 300, address(0), ERC20(ARENFIL).decimals(), 0, false); // NO FEED
        assets[SUSD] = Asset(9040e16, 75, 0x8e0b7e6062272B5eF4524250bFFF8e5Bd3497757, ERC20(SUSD).decimals(), 18, true); // Only ETH
        assets[ASUSD] = Asset(1148320e16, 75, 0x8e0b7e6062272B5eF4524250bFFF8e5Bd3497757, ERC20(ASUSD).decimals(), 18, true); // Only ETH
        assets[AFRAX] = Asset(2869022e16, 75, 0xB9E1E3A9feFf48998E45Fa90847ed4D467E8BcfD, ERC20(AFRAX).decimals(), 8, false);
        assets[FRAX] = Asset(15125e16, 75, 0xB9E1E3A9feFf48998E45Fa90847ed4D467E8BcfD, ERC20(FRAX).decimals(), 8, false);
        assets[TUSD] = Asset(160409e16, 75, 0xec746eCF986E2927Abd291a2A1716c940100f8Ba, ERC20(TUSD).decimals(), 8, false);
        assets[ATUSD] = Asset(608004e16, 75, 0xec746eCF986E2927Abd291a2A1716c940100f8Ba, ERC20(ATUSD).decimals(), 8, false);
        assets[AMANA] = Asset(1622740e16, 200, 0x56a4857acbcfe3a66965c251628B1c9f1c408C19, ERC20(AMANA).decimals(), 8, false);
        assets[MANA] = Asset(33110e16, 200, 0x56a4857acbcfe3a66965c251628B1c9f1c408C19, ERC20(MANA).decimals(), 8, false);
        assets[ABUSD] = Asset(364085e16, 75, 0x833D8Eb16D306ed1FbB5D7A2E019e106B960965A, ERC20(ABUSD).decimals(), 8, false);
        assets[BUSD] = Asset(33991e16, 75, 0x833D8Eb16D306ed1FbB5D7A2E019e106B960965A, ERC20(BUSD).decimals(), 8, false);
        assets[ZRX] = Asset(10719e16, 300, 0x2885d15b8Af22648b98B122b22FDF4D2a56c6023, ERC20(ZRX).decimals(), 8, false);
        assets[AZRX] = Asset(877140e16, 300, 0x2885d15b8Af22648b98B122b22FDF4D2a56c6023, ERC20(AZRX).decimals(), 8, false);
        assets[AENS] = Asset(7047e16, 300, 0x5C00128d4d1c2F4f652C267d7bcdD7aC99C16E16, ERC20(AENS).decimals(), 8, false);
        USDC_DECIMALS = USDC.decimals();
        ETH_USD_ORACLE_DECIMALS = AggregatorV3Interface(ETH_USD_FEED).decimals();
    }

    /// @notice Swaps USDC for specified token
    /// @param _token the address of the token to swap USDC for
    /// @param _amountOut the amount of token wanted
    /// @dev User has to approve USDC transfer prior to calling swap 
    function swap(address _token, uint256 _amountOut) external {
        if (_amountOut == 0) revert OnlyNonZeroAmount();

        uint256 amountIn = getAmountIn(_token, _amountOut);
        uint256 quantity = assets[_token].quantity;
        uint256 sendAmount = _amountOut == type(uint256).max ? quantity : _amountOut;

        unchecked {
            assets[_token].quantity = quantity - sendAmount;
        }

        USDC.transferFrom(msg.sender, AaveV2Ethereum.COLLECTOR, amountIn);
        ERC20(_token).safeTransferFrom(AaveV2Ethereum.COLLECTOR, msg.sender, sendAmount);
        emit Swap(address(USDC), _token, amountIn, sendAmount);
    }

    /// @notice Returns amount of USDC to be spent to swap for token
    /// @param _token the address of the token to swap
    /// @param _amountOut the amount of token wanted
    /// return amountInWithDiscount the amount of USDC used minus premium incentive
    /// @dev User check this function before calling swap() to see the amount of USDC required
    function getAmountIn(
        address _token,
        uint256 _amountOut
    ) public view returns (uint256 amountIn) {
        Asset memory asset = assets[_token];
        if (asset.oracle == address(0)) revert UnsupportedToken();

        if (_amountOut == type(uint256).max) {
            _amountOut = asset.quantity;
        } else if (_amountOut > asset.quantity) {
            revert NotEnoughTokens();
        }

        uint256 oraclePrice = getOraclePrice(asset.oracle);
        unchecked {
            uint256 exponent = asset.decimals + asset.oracleDecimals - USDC_DECIMALS;

            if (asset.ethFeedOnly) {
                uint256 ethUsdPrice = getOraclePrice(ETH_USD_FEED);
                oraclePrice *= ethUsdPrice;
                exponent += ETH_USD_ORACLE_DECIMALS;
            }

            // Basis points arbitrage incentive
            amountIn = ((_amountOut * oraclePrice / 10**exponent) // Amount in before discount 
                * (10000 - asset.premium)) / 10000;
        }
    }
    /// @return The oracle price
    /// @notice The peg price of the referenced oracle as USD per unit
    function getOraclePrice(address _feedAddress) public view returns (uint256) {
        int256 price = AggregatorV3Interface(_feedAddress).latestAnswer();
        if (price <= 0) revert InvalidOracleAnswer();
        return uint256(price);
    }
}
