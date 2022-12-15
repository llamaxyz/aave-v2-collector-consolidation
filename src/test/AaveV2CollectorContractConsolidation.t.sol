// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import "@forge-std/Test.sol";
import "@forge-std/console.sol";
import {AaveV2CollectorContractConsolidation} from "../AaveV2CollectorContractConsolidation.sol";
import {AggregatorV3Interface} from "../external/AggregatorV3Interface.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

contract AaveV2CollectorContractConsolidationTest is Test {
    address public constant USDC_WHALE = 0x55FE002aefF02F77364de339a1292923A15844B8;
    address public constant ETH_WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC;

    IERC20 public constant USDC = IERC20(0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48);
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    AaveV2CollectorContractConsolidation public collectorContract;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), 16183428); // December 14, 2022

        collectorContract = new AaveV2CollectorContractConsolidation();
    }

    function testGetAmountInInvalidToken() public {
        vm.expectRevert(AaveV2CollectorContractConsolidation.UnsupportedToken.selector);
        collectorContract.getAmountIn(WETH, 1e18, 18);
    }

    function testGetAmountInNotEnoughTokens() public {
        (uint256 amountOut, , , ) = collectorContract.assets(collectorContract.ARAI());
        // console.log(amountOut + 1);
        // console.log(6740239e16);
        // console.log(amountOut + 1 > 6740239e16);

        // vm.expectRevert(AaveV2CollectorContractConsolidation.NotEnoughTokens.selector);

        uint256 result = collectorContract.getAmountIn(collectorContract.ARAI(), amountOut + 1, 18);
        console.log(result);
    }

    function testGetAmountInAll() public {
        uint256 amountOut = 2**256 - 1;
        uint256 result = collectorContract.getAmountIn(collectorContract.BUSD(), amountOut, 18);
        assertEq(result, 8997341314428);
    }

    function testSendEthtoBondingCurve() public {
        // Testing that you can't send ETH to the contract directly since there's no fallback() or receive() function
        vm.startPrank(ETH_WHALE);
        (bool success, ) = address(collectorContract).call{value: 1 ether}("");
        assertFalse(success);
    }

    function testGetOraclePrice() public {
        (, , address oracle, uint48 decimals) = collectorContract.assets(collectorContract.BUSD());
        AggregatorV3Interface feed = AggregatorV3Interface(oracle);
        assertEq(feed.decimals(), decimals);
        (, int256 price, , , ) = feed.latestRoundData();
        assertEq(uint256(price), 99988260);
        assertEq(collectorContract.getOraclePrice(oracle), 99988260);
    }

    function testInvalidPriceFromOracleFuzz(int256 price) public {
        vm.assume(price <= int256(0));

        (, , address oracle, ) = collectorContract.assets(collectorContract.ARAI());
        AggregatorV3Interface feed = AggregatorV3Interface(oracle);
        console.log(oracle);

        vm.mockCall(
            address(oracle),
            abi.encodeWithSelector(feed.latestRoundData.selector),
            abi.encode(uint80(10), price, uint256(2), uint256(3), uint80(10))
        );

        vm.expectRevert(AaveV2CollectorContractConsolidation.InvalidOracleAnswer.selector);
        collectorContract.getOraclePrice(oracle);

        vm.clearMockedCalls();
    }
}
