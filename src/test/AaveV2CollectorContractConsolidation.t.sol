// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import "@forge-std/Test.sol";
import "@forge-std/console.sol";
import {AaveV2Ethereum} from "@aave-address-book/AaveV2Ethereum.sol";
import {AaveV2CollectorContractConsolidation} from "../AaveV2CollectorContractConsolidation.sol";
import {AggregatorV3Interface} from "../external/AggregatorV3Interface.sol";
import {ERC20} from "@openzeppelin/token/ERC20/ERC20.sol";

contract AaveV2CollectorContractConsolidationTest is Test {
    event Swap(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    address public constant USDC_WHALE = 0x55FE002aefF02F77364de339a1292923A15844B8;
    address public constant ETH_WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC;

    ERC20 public constant USDC = ERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    AaveV2CollectorContractConsolidation public collectorContract;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), 16183428); // December 14, 2022

        collectorContract = new AaveV2CollectorContractConsolidation();
    }

    function testSwapZeroAmount() public {
        address frax = collectorContract.FRAX();
        vm.expectRevert(AaveV2CollectorContractConsolidation.OnlyNonZeroAmount.selector);
        collectorContract.swap(frax, 0);
    }

    function testSwapAllAMana() public {
        address amana = collectorContract.AMANA();
        (uint256 initialQty, , , ) = collectorContract.assets(amana);

        vm.prank(AaveV2Ethereum.COLLECTOR);
        ERC20(amana).approve(address(collectorContract), 100_000e18);
        vm.stopPrank();

        vm.prank(USDC_WHALE);
        USDC.approve(address(collectorContract), 100_000e18);
        vm.stopPrank();

        vm.prank(USDC_WHALE);
        vm.expectEmit(true, true, false, true);
        emit Swap(address(USDC), amana, 6186477231, initialQty);
        collectorContract.swap(amana, type(uint256).max);

        (uint256 endQty, , , ) = collectorContract.assets(amana);
        assertEq(endQty, 0);
    }

    function testGetAmountInInvalidToken() public {
        vm.expectRevert(AaveV2CollectorContractConsolidation.UnsupportedToken.selector);
        collectorContract.getAmountIn(WETH, 1e18, 18);
    }

    function testGetAmountInNotEnoughTokens() public {
        address arai = collectorContract.ARAI();
        (uint256 amountOut, , , ) = collectorContract.assets(arai);

        vm.expectRevert(AaveV2CollectorContractConsolidation.NotEnoughTokens.selector);

        collectorContract.getAmountIn(arai, amountOut + 1, 18);
    }

    function testGetAmountInAllBUSD() public {
        // Get out max amount of BUSD from contract (339910000 in USDC terms)
        uint256 amountOut = 2 ** 256 - 1;
        uint256 result = collectorContract.getAmountIn(collectorContract.BUSD(), amountOut, 18);
        // BUSD to USDC should be close to 1:1 in price, thus result should be very close, minus discount
        assertEq(result, 337321068);
    }

    function testGetAmountInAllaSUSDWithETHBasedFeed() public {
        // Get out max amount of BUSD from contract (339910000 in USDC terms)
        uint256 amountOut = 2 ** 256 - 1;
        uint256 result = collectorContract.getAmountIn(collectorContract.ASUSD(), amountOut, 18);
        // BUSD to USDC should be close to 1:1 in price, thus result should be very close, minus discount
        assertEq(result, 11477301463);
    }

    function testSendEthToContractFails() public {
        // Testing that you can't send ETH to the contract directly since there's no fallback() or receive() function
        vm.startPrank(ETH_WHALE);
        (bool success, ) = address(collectorContract).call{value: 1 ether}("");
        assertFalse(success);
    }

    function testGetOraclePrice() public {
        uint256 expectedPrice = 1356316336;

        (, , address oracle, ) = collectorContract.assets(collectorContract.AENS());
        AggregatorV3Interface feed = AggregatorV3Interface(oracle);
        (, int256 price, , , ) = feed.latestRoundData();
        assertEq(uint256(price), expectedPrice);
        (uint256 oraclePrice, ) = collectorContract.getOraclePrice(oracle);
        assertEq(oraclePrice, expectedPrice);
    }

    function testInvalidPriceFromOracleFuzz(int256 price) public {
        vm.assume(price <= int256(0));

        (, , address oracle, ) = collectorContract.assets(collectorContract.ARAI());
        AggregatorV3Interface feed = AggregatorV3Interface(oracle);

        vm.mockCall(address(oracle), abi.encodeWithSelector(feed.latestAnswer.selector), abi.encode(price));

        vm.expectRevert(AaveV2CollectorContractConsolidation.InvalidOracleAnswer.selector);
        collectorContract.getOraclePrice(oracle);

        vm.clearMockedCalls();
    }
}
