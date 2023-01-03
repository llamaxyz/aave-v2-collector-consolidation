// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

// testing libraries
import "@forge-std/Test.sol";
import "@forge-std/console.sol";

// contract dependencies
import {GovHelpers} from "@aave-helpers/GovHelpers.sol";
import {AaveV2Ethereum} from "@aave-address-book/AaveV2Ethereum.sol";
import {AaveV2EthereumAMM} from "@aave-address-book/AaveV2EthereumAMM.sol";
import {AaveV2CollectorContractConsolidation} from "../AaveV2CollectorContractConsolidation.sol";
import {AMMWithdrawer} from "../AMMWithdrawer.sol";
import {ProposalPayload} from "../ProposalPayload.sol";
import {DeployMainnetProposal} from "../../script/DeployMainnetProposal.s.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "../external/AggregatorV3Interface.sol";

contract ProposalPayloadE2ETest is Test {
    event Purchase(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    address public constant USDC_WHALE = 0x55FE002aefF02F77364de339a1292923A15844B8;
    address public constant ETH_WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC;
    address public constant BAL_WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC;

    IERC20 public constant BAL = IERC20(0xba100000625a3754423978a60c9317c58a424e3D);

    AaveV2CollectorContractConsolidation public collectorContract;

    address[17] public allTokens;

    AaveV2CollectorContractConsolidation public consolidationContract;
    AMMWithdrawer public withdrawContract;
    ProposalPayload public payload;
    uint256 public proposalId;

    address public constant aAMMDAI = 0x79bE75FFC64DD58e66787E4Eae470c8a1FD08ba4;
    address public constant aAMMUSDC = 0xd24946147829DEaA935bE2aD85A3291dbf109c80;
    address public constant aAMMUSDT = 0x17a79792Fe6fE5C95dFE95Fe3fCEE3CAf4fE4Cb7;
    address public constant aAMMWBTC = 0x13B2f6928D7204328b0E8E4BCd0379aA06EA21FA;
    address public constant aAMMWETH = 0xf9Fb4AD91812b704Ba883B11d2B576E890a6730A;

    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address[5] private aAmmTokens = [aAMMDAI, aAMMUSDC, aAMMUSDT, aAMMWBTC, aAMMWETH];
    address[5] private tokens = [DAI, USDC, USDT, WBTC, WETH];

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), 16183428); // December 14, 2022

        consolidationContract = new AaveV2CollectorContractConsolidation();
        withdrawContract = new AMMWithdrawer();
        payload = new ProposalPayload(consolidationContract, withdrawContract);

        allTokens[0] = consolidationContract.ARAI();
        allTokens[1] = consolidationContract.AAMPL();
        allTokens[2] = consolidationContract.AFRAX();
        allTokens[3] = consolidationContract.FRAX();
        allTokens[4] = consolidationContract.AENS();
        allTokens[5] = consolidationContract.SUSD();
        allTokens[6] = consolidationContract.ASUSD();
        allTokens[7] = consolidationContract.TUSD();
        allTokens[8] = consolidationContract.ATUSD();
        allTokens[9] = consolidationContract.AMANA();
        allTokens[10] = consolidationContract.ADPI();
        allTokens[11] = consolidationContract.ABUSD();
        allTokens[12] = consolidationContract.BUSD();
        allTokens[13] = consolidationContract.ZRX();
        allTokens[14] = consolidationContract.AZRX();
        allTokens[15] = consolidationContract.AUST();
        allTokens[16] = consolidationContract.MANA();

        vm.startPrank(GovHelpers.AAVE_WHALE);
        proposalId = DeployMainnetProposal._deployMainnetProposal(
            address(payload),
            0x78ce0d63ca0c186ca3f58e712d3f1861ced3dad15ce3ad4f0e005d1663b49caf
        );
        vm.stopPrank();
    }

    function testWithdrawOfAMMTokens() public {
        uint256[] memory ammBalancesBefore = new uint256[](5);
        uint256[] memory balancesBefore = new uint256[](5);
        uint256 lengthOne = tokens.length;
        for (uint256 i = 0; i < lengthOne; ++i) {
            ammBalancesBefore[i] = IERC20(aAmmTokens[i]).balanceOf(AaveV2Ethereum.COLLECTOR);
            balancesBefore[i] = IERC20(tokens[i]).balanceOf(AaveV2Ethereum.COLLECTOR);

            vm.expectCall(
                address(AaveV2EthereumAMM.POOL),
                abi.encodeCall(
                    AaveV2EthereumAMM.POOL.withdraw,
                    (tokens[i], type(uint256).max, AaveV2Ethereum.COLLECTOR)
                )
            );
        }

        GovHelpers.passVoteAndExecute(vm, proposalId);

        uint256 length = aAmmTokens.length;
        for (uint256 i = 0; i < length; ++i) {
            uint256 ammBalanceOfCollector = IERC20(aAmmTokens[i]).balanceOf(AaveV2Ethereum.COLLECTOR);
            uint256 finalUnderlyingBalance = balancesBefore[i] + ammBalancesBefore[i];
            // The withdrawal conversion is not 1 to 1 so might not be able to redeem to 0
            assertApproxEqAbs(ammBalanceOfCollector, 0, 4 ether);
            assertApproxEqAbs(IERC20(tokens[i]).balanceOf(AaveV2Ethereum.COLLECTOR), finalUnderlyingBalance, 1 ether);
            assertEq(IERC20(aAmmTokens[i]).balanceOf(address(withdrawContract)), 0);
        }
    }

    function testWithdrawOfAMMTokensOneTokenHasZeroQty() public {
        uint256[] memory ammBalancesBefore = new uint256[](5);
        uint256[] memory balancesBefore = new uint256[](5);
        uint256 lengthOne = tokens.length;
        for (uint256 i = 0; i < lengthOne; ++i) {
            ammBalancesBefore[i] = IERC20(aAmmTokens[i]).balanceOf(AaveV2Ethereum.COLLECTOR);
            balancesBefore[i] = IERC20(tokens[i]).balanceOf(AaveV2Ethereum.COLLECTOR);
        }

        vm.expectCall(
            address(AaveV2EthereumAMM.POOL),
            abi.encodeCall(AaveV2EthereumAMM.POOL.withdraw, (tokens[0], type(uint256).max, AaveV2Ethereum.COLLECTOR))
        );

        vm.expectCall(
            address(AaveV2EthereumAMM.POOL),
            abi.encodeCall(AaveV2EthereumAMM.POOL.withdraw, (tokens[1], type(uint256).max, AaveV2Ethereum.COLLECTOR))
        );

        vm.expectCall(
            address(AaveV2EthereumAMM.POOL),
            abi.encodeCall(AaveV2EthereumAMM.POOL.withdraw, (tokens[3], type(uint256).max, AaveV2Ethereum.COLLECTOR))
        );

        vm.expectCall(
            address(AaveV2EthereumAMM.POOL),
            abi.encodeCall(AaveV2EthereumAMM.POOL.withdraw, (tokens[4], type(uint256).max, AaveV2Ethereum.COLLECTOR))
        );

        vm.mockCall(
            address(tokens[2]),
            abi.encodeCall(IERC20(tokens[2]).balanceOf, (address(AaveV2Ethereum.COLLECTOR))),
            abi.encode(uint256(0))
        );

        GovHelpers.passVoteAndExecute(vm, proposalId);

        uint256 length = aAmmTokens.length;
        for (uint256 i = 0; i < length; ++i) {
            uint256 ammBalanceOfCollector = IERC20(aAmmTokens[i]).balanceOf(AaveV2Ethereum.COLLECTOR);
            uint256 finalUnderlyingBalance = balancesBefore[i] + ammBalancesBefore[i];
            // The withdrawal conversion is not 1 to 1 so might not be able to redeem to 0
            assertApproxEqAbs(ammBalanceOfCollector, 0, 4 ether);
            assertApproxEqAbs(IERC20(tokens[i]).balanceOf(AaveV2Ethereum.COLLECTOR), finalUnderlyingBalance, 1 ether);
            assertEq(IERC20(aAmmTokens[i]).balanceOf(address(withdrawContract)), 0);
        }
    }

    function testAllowanceOfToken() public {
        uint256 length = allTokens.length;
        for (uint256 i = 0; i < length; ++i) {
            address token = allTokens[i];
            assertEq(IERC20(token).allowance(AaveV2Ethereum.COLLECTOR, address(consolidationContract)), 0);
        }

        GovHelpers.passVoteAndExecute(vm, proposalId);

        for (uint256 i = 0; i < length; ++i) {
            address token = allTokens[i];
            (uint256 qty, , , , , ) = consolidationContract.assets(token);
            assertLe(qty, IERC20(token).allowance(AaveV2Ethereum.COLLECTOR, address(consolidationContract)));
        }
    }

    function testPurchaseZeroAmount() public {
        GovHelpers.passVoteAndExecute(vm, proposalId);

        address frax = consolidationContract.FRAX();
        vm.expectRevert(AaveV2CollectorContractConsolidation.OnlyNonZeroAmount.selector);
        consolidationContract.purchase(frax, 0);
    }

    function testPurchaseInvalidToken() public {
        GovHelpers.passVoteAndExecute(vm, proposalId);

        vm.expectRevert(AaveV2CollectorContractConsolidation.UnsupportedToken.selector);
        consolidationContract.purchase(WETH, 1e18);
    }

    function testPurchaseTooManyTokens() public {
        GovHelpers.passVoteAndExecute(vm, proposalId);

        (uint256 initialQty, , , , , ) = consolidationContract.assets(consolidationContract.ARAI());
        vm.expectRevert(AaveV2CollectorContractConsolidation.NotEnoughTokens.selector);
        consolidationContract.purchase(allTokens[0], initialQty + 1);
    }

    function testPurchaseAmountOfTokensOut() public {
        GovHelpers.passVoteAndExecute(vm, proposalId);

        vm.prank(USDC_WHALE);
        IERC20(USDC).approve(address(consolidationContract), type(uint256).max);
        vm.stopPrank();

        uint256 length = allTokens.length;
        for (uint256 i = 0; i < length; i++) {
            address token = allTokens[i];
            (uint256 initialQty, , , , , ) = consolidationContract.assets(token);
            uint256 amountToWithdraw = (initialQty * 100) / 200;

            vm.prank(USDC_WHALE);
            consolidationContract.purchase(token, amountToWithdraw);

            (uint256 endQty, , , , , ) = consolidationContract.assets(token);
            assertEq(endQty, initialQty - amountToWithdraw);
        }
    }

    function testPurchaseAllTokensOut() public {
        GovHelpers.passVoteAndExecute(vm, proposalId);

        vm.prank(USDC_WHALE);
        IERC20(USDC).approve(address(consolidationContract), type(uint256).max);
        vm.stopPrank();

        uint256 length = allTokens.length;
        for (uint256 i = 0; i < length; i++) {
            address token = allTokens[i];

            vm.prank(USDC_WHALE);
            consolidationContract.purchase(token, type(uint256).max);

            (uint256 endQty, , , , , ) = consolidationContract.assets(token);
            assertEq(endQty, 0);
        }
    }

    function testGetAmountInInvalidToken() public {
        vm.expectRevert(AaveV2CollectorContractConsolidation.UnsupportedToken.selector);
        consolidationContract.getAmountIn(WETH, 1e18);
    }

    function testGetAmountInNotEnoughTokens() public {
        address arai = consolidationContract.ARAI();
        (uint256 amountOut, , , , , ) = consolidationContract.assets(arai);

        vm.expectRevert(AaveV2CollectorContractConsolidation.NotEnoughTokens.selector);

        consolidationContract.getAmountIn(arai, amountOut + 1);
    }

    function testGetAmountInAllBUSD() public {
        // Get out max amount of BUSD from contract (339.910000 in USDC terms)
        uint256 amountOut = 2**256 - 1;
        uint256 result = consolidationContract.getAmountIn(consolidationContract.BUSD(), amountOut);
        // BUSD to USDC should be close to 1:1 in price, thus result should be very close, minus discount
        assertEq(result, 337336479);
    }

    function testGetAmountInAllaSUSDWithETHBasedFeed() public {
        // Get out max amount of aUSD from contract (11,483.0000000 in USDC terms)
        uint256 amountOut = 2**256 - 1;
        uint256 result = consolidationContract.getAmountIn(consolidationContract.ASUSD(), amountOut);
        // aUSD to USDC should be close to 1:1 in price, thus result should be very close, minus discount
        assertEq(result, 11872754070);
    }

    function testSendEthToContractFails() public {
        // Testing that you can't send ETH to the contract directly since there's no fallback() or receive() function
        vm.startPrank(ETH_WHALE);
        (bool success, ) = address(consolidationContract).call{value: 1 ether}("");
        assertFalse(success);
    }

    function testSendEthToWithdrawContractFails() public {
        // Testing that you can't send ETH to the contract directly since there's no fallback() or receive() function
        vm.startPrank(ETH_WHALE);
        (bool success, ) = address(withdrawContract).call{value: 1 ether}("");
        assertFalse(success);
    }

    function testGetOraclePrice() public {
        uint256 expectedPrice = 1356316336;

        (, , address oracle, , , ) = consolidationContract.assets(consolidationContract.AENS());
        AggregatorV3Interface feed = AggregatorV3Interface(oracle);
        (, int256 price, , , ) = feed.latestRoundData();
        assertEq(uint256(price), expectedPrice);
        uint256 oraclePrice = consolidationContract.getOraclePrice(oracle);
        assertEq(oraclePrice, expectedPrice);
    }

    function testInvalidPriceFromOracleFuzz(int256 price) public {
        vm.assume(price <= int256(0));

        (, , address oracle, , , ) = consolidationContract.assets(consolidationContract.ARAI());
        AggregatorV3Interface feed = AggregatorV3Interface(oracle);

        vm.mockCall(
            address(oracle),
            abi.encodeWithSelector(feed.latestRoundData.selector),
            abi.encode(uint80(10), price, uint256(2), uint256(3), uint80(10))
        );

        vm.expectRevert(AaveV2CollectorContractConsolidation.InvalidOracleAnswer.selector);
        consolidationContract.getOraclePrice(oracle);

        vm.clearMockedCalls();
    }

    function testRescueTokens() public {
        assertEq(BAL.balanceOf(address(consolidationContract)), 0);
        assertEq(IERC20(USDC).balanceOf(address(consolidationContract)), 0);

        uint256 balAmount = 10_000e18;
        uint256 usdcAmount = 10_000e6;

        vm.prank(BAL_WHALE);
        BAL.transfer(address(consolidationContract), balAmount);

        vm.prank(USDC_WHALE);
        IERC20(USDC).transfer(address(consolidationContract), usdcAmount);

        assertEq(BAL.balanceOf(address(consolidationContract)), balAmount);
        assertEq(IERC20(USDC).balanceOf(address(consolidationContract)), usdcAmount);

        uint256 initialCollectorBalBalance = BAL.balanceOf(AaveV2Ethereum.COLLECTOR);
        uint256 initialCollectorUsdcBalance = IERC20(USDC).balanceOf(AaveV2Ethereum.COLLECTOR);

        address[] memory toRescue = new address[](2);
        toRescue[0] = address(BAL);
        toRescue[1] = address(USDC);
        consolidationContract.rescueTokens(toRescue);

        assertEq(BAL.balanceOf(AaveV2Ethereum.COLLECTOR), initialCollectorBalBalance + balAmount);
        assertEq(IERC20(USDC).balanceOf(AaveV2Ethereum.COLLECTOR), initialCollectorUsdcBalance + usdcAmount);
        assertEq(BAL.balanceOf(address(consolidationContract)), 0);
        assertEq(IERC20(USDC).balanceOf(address(consolidationContract)), 0);
    }
}
