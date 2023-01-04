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
import {TokenAddresses} from "../TokenAddresses.sol";
import {DeployMainnetProposal} from "../../script/DeployMainnetProposal.s.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "../external/AggregatorV3Interface.sol";

contract ProposalPayloadE2ETest is Test {
    event Purchase(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    address public constant USDC_WHALE = 0x55FE002aefF02F77364de339a1292923A15844B8;
    address public constant ETH_WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC;
    address public constant BAL_WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC;

    IERC20 public constant BAL = IERC20(0xba100000625a3754423978a60c9317c58a424e3D);

    address[17] public allTokens;

    AaveV2CollectorContractConsolidation public consolidationContract;
    AMMWithdrawer public withdrawContract;
    ProposalPayload public payload;
    uint256 public proposalId;

    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), 16183428); // December 14, 2022

        consolidationContract = new AaveV2CollectorContractConsolidation();
        withdrawContract = new AMMWithdrawer();
        payload = new ProposalPayload(address(consolidationContract), withdrawContract);

        allTokens[0] = TokenAddresses.ARAI;
        allTokens[1] = TokenAddresses.AAMPL;
        allTokens[2] = TokenAddresses.AFRAX;
        allTokens[3] = TokenAddresses.FRAX;
        allTokens[4] = TokenAddresses.AENS;
        allTokens[5] = TokenAddresses.SUSD;
        allTokens[6] = TokenAddresses.ASUSD;
        allTokens[7] = TokenAddresses.TUSD;
        allTokens[8] = TokenAddresses.ATUSD;
        allTokens[9] = TokenAddresses.AMANA;
        allTokens[10] = TokenAddresses.ADPI;
        allTokens[11] = TokenAddresses.ABUSD;
        allTokens[12] = TokenAddresses.BUSD;
        allTokens[13] = TokenAddresses.ZRX;
        allTokens[14] = TokenAddresses.AZRX;
        allTokens[15] = TokenAddresses.AUST;
        allTokens[16] = TokenAddresses.MANA;

        vm.prank(GovHelpers.AAVE_WHALE);
        proposalId = DeployMainnetProposal._deployMainnetProposal(
            address(payload),
            0x78ce0d63ca0c186ca3f58e712d3f1861ced3dad15ce3ad4f0e005d1663b49caf
        );
    }

    function testWithdrawOfAMMTokens() public {
        address[5] memory aAmmTokens = TokenAddresses.getaAMMTokens();
        address[5] memory tokens = TokenAddresses.getaAMMEquivalentTokens();
        uint256[] memory balancesBefore = new uint256[](5);
        uint256 lengthOne = tokens.length;
        for (uint256 i = 0; i < lengthOne; ++i) {
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

        // aAMMDAI
        assertEq(IERC20(aAmmTokens[0]).balanceOf(address(withdrawContract)), 0);
        assertEq(IERC20(aAmmTokens[0]).balanceOf(AaveV2Ethereum.COLLECTOR), 3453049393752744990);
        assertEq(IERC20(tokens[0]).balanceOf(AaveV2Ethereum.COLLECTOR), 463936673430895543895627);
        assertTrue(IERC20(tokens[0]).balanceOf(AaveV2Ethereum.COLLECTOR) > balancesBefore[0]);

        // aAMMUSDC
        assertEq(IERC20(aAmmTokens[1]).balanceOf(address(withdrawContract)), 0);
        assertEq(IERC20(aAmmTokens[1]).balanceOf(AaveV2Ethereum.COLLECTOR), 6803226);
        assertEq(IERC20(tokens[1]).balanceOf(AaveV2Ethereum.COLLECTOR), 406353985732);
        assertTrue(IERC20(tokens[1]).balanceOf(AaveV2Ethereum.COLLECTOR) > balancesBefore[1]);

        // aAMMUSDT
        assertEq(IERC20(aAmmTokens[2]).balanceOf(address(withdrawContract)), 0);
        assertEq(IERC20(aAmmTokens[2]).balanceOf(AaveV2Ethereum.COLLECTOR), 3899548);
        assertEq(IERC20(tokens[2]).balanceOf(AaveV2Ethereum.COLLECTOR), 31903276890);
        assertTrue(IERC20(tokens[2]).balanceOf(AaveV2Ethereum.COLLECTOR) > balancesBefore[2]);

        // aAMMWBTC
        assertEq(IERC20(aAmmTokens[3]).balanceOf(address(withdrawContract)), 0);
        assertEq(IERC20(aAmmTokens[3]).balanceOf(AaveV2Ethereum.COLLECTOR), 2043);
        assertEq(IERC20(tokens[3]).balanceOf(AaveV2Ethereum.COLLECTOR), 8721483);
        assertTrue(IERC20(tokens[3]).balanceOf(AaveV2Ethereum.COLLECTOR) > balancesBefore[3]);

        // aAMMWETH
        assertEq(IERC20(aAmmTokens[4]).balanceOf(address(withdrawContract)), 0);
        assertEq(IERC20(aAmmTokens[4]).balanceOf(AaveV2Ethereum.COLLECTOR), 2922298332584297);
        assertEq(IERC20(tokens[4]).balanceOf(AaveV2Ethereum.COLLECTOR), 10260853621241145165);
        assertTrue(IERC20(tokens[4]).balanceOf(AaveV2Ethereum.COLLECTOR) > balancesBefore[4]);
    }

    function testWithdrawOfAMMTokensOneTokenHasZeroQty() public {
        address[5] memory aAmmTokens = TokenAddresses.getaAMMTokens();
        address[5] memory tokens = TokenAddresses.getaAMMEquivalentTokens();

        // Empty aAMMUSDT so that balance is zero on redeem()
        vm.startPrank(AaveV2Ethereum.COLLECTOR);
        IERC20(aAmmTokens[2]).transfer(BAL_WHALE, IERC20(aAmmTokens[2]).balanceOf(AaveV2Ethereum.COLLECTOR));
        vm.stopPrank();

        uint256[] memory balancesBefore = new uint256[](5);
        uint256 lengthOne = tokens.length;
        for (uint256 i = 0; i < lengthOne; ++i) {
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

        GovHelpers.passVoteAndExecute(vm, proposalId);

        // aAMMDAI
        assertEq(IERC20(aAmmTokens[0]).balanceOf(address(withdrawContract)), 0);
        assertEq(IERC20(aAmmTokens[0]).balanceOf(AaveV2Ethereum.COLLECTOR), 3453049393752744990);
        assertEq(IERC20(tokens[0]).balanceOf(AaveV2Ethereum.COLLECTOR), 463936673430895543895627);
        assertTrue(IERC20(tokens[0]).balanceOf(AaveV2Ethereum.COLLECTOR) > balancesBefore[0]);

        // aAMMUSDC
        assertEq(IERC20(aAmmTokens[1]).balanceOf(address(withdrawContract)), 0);
        assertEq(IERC20(aAmmTokens[1]).balanceOf(AaveV2Ethereum.COLLECTOR), 6803226);
        assertEq(IERC20(tokens[1]).balanceOf(AaveV2Ethereum.COLLECTOR), 406353985732);
        assertTrue(IERC20(tokens[1]).balanceOf(AaveV2Ethereum.COLLECTOR) > balancesBefore[1]);

        // aAMMUSDT Should not be changed at all
        assertEq(IERC20(aAmmTokens[2]).balanceOf(address(withdrawContract)), 0);
        assertEq(IERC20(aAmmTokens[2]).balanceOf(AaveV2Ethereum.COLLECTOR), 0);
        assertEq(IERC20(tokens[2]).balanceOf(address(withdrawContract)), 0);
        assertEq(IERC20(tokens[2]).balanceOf(AaveV2Ethereum.COLLECTOR), balancesBefore[2]);

        // aAMMWBTC
        assertEq(IERC20(aAmmTokens[3]).balanceOf(address(withdrawContract)), 0);
        assertEq(IERC20(aAmmTokens[3]).balanceOf(AaveV2Ethereum.COLLECTOR), 2043);
        assertEq(IERC20(tokens[3]).balanceOf(AaveV2Ethereum.COLLECTOR), 8721483);
        assertTrue(IERC20(tokens[3]).balanceOf(AaveV2Ethereum.COLLECTOR) > balancesBefore[3]);

        // aAMMWETH
        assertEq(IERC20(aAmmTokens[4]).balanceOf(address(withdrawContract)), 0);
        assertEq(IERC20(aAmmTokens[4]).balanceOf(AaveV2Ethereum.COLLECTOR), 2922298332584297);
        assertEq(IERC20(tokens[4]).balanceOf(AaveV2Ethereum.COLLECTOR), 10260853621241145165);
        assertTrue(IERC20(tokens[4]).balanceOf(AaveV2Ethereum.COLLECTOR) > balancesBefore[4]);
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

        address frax = TokenAddresses.FRAX;
        vm.expectRevert(AaveV2CollectorContractConsolidation.OnlyNonZeroAmount.selector);
        consolidationContract.purchase(frax, 0);
    }

    function testPurchaseInvalidToken() public {
        GovHelpers.passVoteAndExecute(vm, proposalId);

        vm.expectRevert(abi.encodeWithSelector(AaveV2CollectorContractConsolidation.UnsupportedToken.selector, WETH));
        consolidationContract.purchase(WETH, 1e18);
    }

    function testPurchaseTooManyTokens() public {
        GovHelpers.passVoteAndExecute(vm, proposalId);

        (uint256 initialQty, , , , , ) = consolidationContract.assets(TokenAddresses.ARAI);
        vm.expectRevert(
            abi.encodeWithSelector(AaveV2CollectorContractConsolidation.NotEnoughTokens.selector, initialQty)
        );
        consolidationContract.purchase(allTokens[0], initialQty + 1);
    }

    function testPurchaseAmountOfTokensOut() public {
        GovHelpers.passVoteAndExecute(vm, proposalId);

        vm.prank(USDC_WHALE);
        IERC20(USDC).approve(address(consolidationContract), type(uint256).max);

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
        vm.expectRevert(abi.encodeWithSelector(AaveV2CollectorContractConsolidation.UnsupportedToken.selector, WETH));
        consolidationContract.getAmountIn(WETH, 1e18);
    }

    function testGetAmountInNotEnoughTokens() public {
        address arai = TokenAddresses.ARAI;
        (uint256 amountOut, , , , , ) = consolidationContract.assets(arai);

        vm.expectRevert(
            abi.encodeWithSelector(AaveV2CollectorContractConsolidation.NotEnoughTokens.selector, amountOut)
        );

        consolidationContract.getAmountIn(arai, amountOut + 1);
    }

    function testGetAmountInAllBUSD() public {
        // Get out max amount of BUSD from contract (339.910000 in USDC terms)
        uint256 amountOut = 2**256 - 1;
        uint256 result = consolidationContract.getAmountIn(TokenAddresses.BUSD, amountOut);
        // BUSD to USDC should be close to 1:1 in price, thus result should be very close, minus discount
        assertEq(result, 337336479);
    }

    function testGetAmountInAllaSUSDWithETHBasedFeed() public {
        // Get out max amount of aUSD from contract (11,483.0000000 in USDC terms)
        uint256 amountOut = 2**256 - 1;
        uint256 result = consolidationContract.getAmountIn(TokenAddresses.ASUSD, amountOut);
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

        (, , address oracle, , , ) = consolidationContract.assets(TokenAddresses.AENS);
        AggregatorV3Interface feed = AggregatorV3Interface(oracle);
        (, int256 price, , , ) = feed.latestRoundData();
        assertEq(uint256(price), expectedPrice);
        uint256 oraclePrice = consolidationContract.getOraclePrice(oracle);
        assertEq(oraclePrice, expectedPrice);
    }

    function testInvalidPriceFromOracleFuzz(int256 price) public {
        vm.assume(price <= int256(0));

        (, , address oracle, , , ) = consolidationContract.assets(TokenAddresses.ARAI);
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
