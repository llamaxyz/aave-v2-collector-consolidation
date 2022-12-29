// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {AaveV2Ethereum} from "@aave-address-book/AaveV2Ethereum.sol";
import {AggregatorV3Interface} from "./external/AggregatorV3Interface.sol";
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";

/// @title AaveV2CollectorContractConsolidation
/// @author Llama
/// @notice Contract to sell excess assets for USDC at a discount
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
    address public constant AENS = 0x9a14e23A58edf4EFDcB360f68cd1b95ce2081a2F;
    address public constant ADPI = 0x6F634c6135D2EBD550000ac92F494F9CB8183dAe;

    event Purchase(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    /// Not enough token left to purchase
    error NotEnoughTokens();
    /// Oracle price is 0 or lower
    error InvalidOracleAnswer();
    /// Need to request more than 0 tokens out
    error OnlyNonZeroAmount();
    /// Token is not available for purchase
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
        assets[ARAI] = Asset(
            ERC20(ARAI).balanceOf(AaveV2Ethereum.COLLECTOR),
            100,
            0x483d36F6a1d063d580c7a24F9A42B346f3a69fbb,
            ERC20(ARAI).decimals(),
            AggregatorV3Interface(0x483d36F6a1d063d580c7a24F9A42B346f3a69fbb).decimals(),
            false
        );
        assets[AAMPL] = Asset(
            ERC20(AAMPL).balanceOf(AaveV2Ethereum.COLLECTOR),
            300,
            0xe20CA8D7546932360e37E9D72c1a47334af57706,
            ERC20(AAMPL).decimals(),
            AggregatorV3Interface(0xe20CA8D7546932360e37E9D72c1a47334af57706).decimals(),
            false
        );
        assets[ADPI] = Asset(
            ERC20(ADPI).balanceOf(AaveV2Ethereum.COLLECTOR),
            300,
            0xD2A593BF7594aCE1faD597adb697b5645d5edDB2,
            ERC20(ADPI).decimals(),
            AggregatorV3Interface(0xD2A593BF7594aCE1faD597adb697b5645d5edDB2).decimals(),
            false
        );
        assets[SUSD] = Asset(
            ERC20(SUSD).balanceOf(AaveV2Ethereum.COLLECTOR),
            75,
            0x8e0b7e6062272B5eF4524250bFFF8e5Bd3497757,
            ERC20(SUSD).decimals(),
            AggregatorV3Interface(0x8e0b7e6062272B5eF4524250bFFF8e5Bd3497757).decimals(),
            true
        );
        assets[ASUSD] = Asset(
            ERC20(ASUSD).balanceOf(AaveV2Ethereum.COLLECTOR),
            75,
            0x8e0b7e6062272B5eF4524250bFFF8e5Bd3497757,
            ERC20(ASUSD).decimals(),
            AggregatorV3Interface(0x8e0b7e6062272B5eF4524250bFFF8e5Bd3497757).decimals(),
            true
        );
        assets[AFRAX] = Asset(
            ERC20(AFRAX).balanceOf(AaveV2Ethereum.COLLECTOR),
            75,
            0xB9E1E3A9feFf48998E45Fa90847ed4D467E8BcfD,
            ERC20(AFRAX).decimals(),
            AggregatorV3Interface(0xB9E1E3A9feFf48998E45Fa90847ed4D467E8BcfD).decimals(),
            false
        );
        assets[FRAX] = Asset(
            ERC20(FRAX).balanceOf(AaveV2Ethereum.COLLECTOR),
            75,
            0xB9E1E3A9feFf48998E45Fa90847ed4D467E8BcfD,
            ERC20(FRAX).decimals(),
            AggregatorV3Interface(0xB9E1E3A9feFf48998E45Fa90847ed4D467E8BcfD).decimals(),
            false
        );
        assets[TUSD] = Asset(
            ERC20(TUSD).balanceOf(AaveV2Ethereum.COLLECTOR),
            75,
            0xec746eCF986E2927Abd291a2A1716c940100f8Ba,
            ERC20(TUSD).decimals(),
            AggregatorV3Interface(0xec746eCF986E2927Abd291a2A1716c940100f8Ba).decimals(),
            false
        );
        assets[ATUSD] = Asset(
            ERC20(ATUSD).balanceOf(AaveV2Ethereum.COLLECTOR),
            75,
            0xec746eCF986E2927Abd291a2A1716c940100f8Ba,
            ERC20(ATUSD).decimals(),
            AggregatorV3Interface(0xec746eCF986E2927Abd291a2A1716c940100f8Ba).decimals(),
            false
        );
        assets[AMANA] = Asset(
            ERC20(AMANA).balanceOf(AaveV2Ethereum.COLLECTOR),
            200,
            0x56a4857acbcfe3a66965c251628B1c9f1c408C19,
            ERC20(AMANA).decimals(),
            AggregatorV3Interface(0x56a4857acbcfe3a66965c251628B1c9f1c408C19).decimals(),
            false
        );
        assets[MANA] = Asset(
            ERC20(MANA).balanceOf(AaveV2Ethereum.COLLECTOR),
            200,
            0x56a4857acbcfe3a66965c251628B1c9f1c408C19,
            ERC20(MANA).decimals(),
            AggregatorV3Interface(0x56a4857acbcfe3a66965c251628B1c9f1c408C19).decimals(),
            false
        );
        assets[ABUSD] = Asset(
            ERC20(ABUSD).balanceOf(AaveV2Ethereum.COLLECTOR),
            75,
            0x833D8Eb16D306ed1FbB5D7A2E019e106B960965A,
            ERC20(ABUSD).decimals(),
            AggregatorV3Interface(0x833D8Eb16D306ed1FbB5D7A2E019e106B960965A).decimals(),
            false
        );
        assets[BUSD] = Asset(
            ERC20(BUSD).balanceOf(AaveV2Ethereum.COLLECTOR),
            75,
            0x833D8Eb16D306ed1FbB5D7A2E019e106B960965A,
            ERC20(BUSD).decimals(),
            AggregatorV3Interface(0x833D8Eb16D306ed1FbB5D7A2E019e106B960965A).decimals(),
            false
        );
        assets[ZRX] = Asset(
            ERC20(ZRX).balanceOf(AaveV2Ethereum.COLLECTOR),
            300,
            0x2885d15b8Af22648b98B122b22FDF4D2a56c6023,
            ERC20(ZRX).decimals(),
            AggregatorV3Interface(0x2885d15b8Af22648b98B122b22FDF4D2a56c6023).decimals(),
            false
        );
        assets[AZRX] = Asset(
            ERC20(AZRX).balanceOf(AaveV2Ethereum.COLLECTOR),
            300,
            0x2885d15b8Af22648b98B122b22FDF4D2a56c6023,
            ERC20(AZRX).decimals(),
            AggregatorV3Interface(0x2885d15b8Af22648b98B122b22FDF4D2a56c6023).decimals(),
            false
        );
        assets[AENS] = Asset(
            ERC20(AENS).balanceOf(AaveV2Ethereum.COLLECTOR),
            300,
            0x5C00128d4d1c2F4f652C267d7bcdD7aC99C16E16,
            ERC20(AENS).decimals(),
            AggregatorV3Interface(0x5C00128d4d1c2F4f652C267d7bcdD7aC99C16E16).decimals(),
            false
        );
        assets[AUST] = Asset(
            ERC20(AUST).balanceOf(AaveV2Ethereum.COLLECTOR),
            200,
            0xa20623070413d42a5C01Db2c8111640DD7A5A03a,
            ERC20(AUST).decimals(),
            AggregatorV3Interface(0xa20623070413d42a5C01Db2c8111640DD7A5A03a).decimals(),
            false
        );

        USDC_DECIMALS = USDC.decimals();
        ETH_USD_ORACLE_DECIMALS = AggregatorV3Interface(ETH_USD_FEED).decimals();
    }

    /// @notice Lets user pay with USDC for specified token
    /// @param _token the address of the token to purchase with USDC
    /// @param _amountOut the amount of token wanted
    /// @dev User has to approve USDC transfer prior to calling purchase
    function purchase(address _token, uint256 _amountOut) external {
        if (_amountOut == 0) revert OnlyNonZeroAmount();

        uint256 amountIn = getAmountIn(_token, _amountOut);
        uint256 quantity = assets[_token].quantity;
        uint256 sendAmount = _amountOut == type(uint256).max ? quantity : _amountOut;

        assets[_token].quantity = quantity - sendAmount;

        USDC.transferFrom(msg.sender, AaveV2Ethereum.COLLECTOR, amountIn);
        ERC20(_token).safeTransferFrom(AaveV2Ethereum.COLLECTOR, msg.sender, sendAmount);
        emit Purchase(address(USDC), _token, amountIn, sendAmount);
    }

    /// @notice Returns amount of USDC to be spent to purchase for token
    /// @param _token the address of the token to purchase
    /// @param _amountOut the amount of token wanted
    /// return amountInWithDiscount the amount of USDC used minus premium incentive
    /// @dev User check this function before calling purchase() to see the amount of USDC required
    /// @dev User can pass type(uint256).max as amount in order to purchase all
    function getAmountIn(address _token, uint256 _amountOut) public view returns (uint256 amountIn) {
        Asset memory asset = assets[_token];
        if (asset.oracle == address(0)) revert UnsupportedToken();

        if (_amountOut == type(uint256).max) {
            _amountOut = asset.quantity;
        } else if (_amountOut > asset.quantity) {
            revert NotEnoughTokens();
        }

        uint256 oraclePrice = getOraclePrice(asset.oracle);
        uint256 exponent = asset.decimals + asset.oracleDecimals - USDC_DECIMALS;

        if (asset.ethFeedOnly) {
            uint256 ethUsdPrice = getOraclePrice(ETH_USD_FEED);
            oraclePrice *= ethUsdPrice;
            exponent += ETH_USD_ORACLE_DECIMALS;
        }

        // Basis points arbitrage incentive
        /** 
            Amount In Calculation with 3% discount (300 basis points)
            The actual calculation is a collapsed version of this to prevent precision loss:
            => amountIn = (amountTokenWei / 10^tokenDecimals) * (chainlinkPrice / chainlinkPrecision) * 10^usdcDecimals
            => amountInWithDiscount = amountIn * 10000 / (10000 + bps)
            => ie: amountIn = (amountTokenWei / 10^18) * (chainlinkPrice / 10^8) * 10^6
            =>     amountInWithDiscount = amountIn * 10000 / (10000 + 300) 
         */
        amountIn =
            (((_amountOut * oraclePrice) / 10**exponent) * 10000) / // Amount before discount
            (10000 + asset.premium);
    }

    /// @return The oracle price
    /// @notice The peg price of the referenced oracle as USD per unit
    function getOraclePrice(address _feedAddress) public view returns (uint256) {
        (, int256 price, , , ) = AggregatorV3Interface(_feedAddress).latestRoundData();
        if (price <= 0) revert InvalidOracleAnswer();
        return uint256(price);
    }

    /// @notice Transfer any tokens accidentally sent to this contract to Aave V2 Collector
    /// @param tokens List of token addresses
    function rescueTokens(address[] calldata tokens) external {
        for (uint256 i = 0; i < tokens.length; ++i) {
            ERC20(tokens[i]).safeTransfer(AaveV2Ethereum.COLLECTOR, ERC20(tokens[i]).balanceOf(address(this)));
        }
    }
}
