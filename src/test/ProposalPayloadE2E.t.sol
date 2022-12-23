// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

// testing libraries
import "@forge-std/Test.sol";
import "@forge-std/console.sol";

// contract dependencies
import {GovHelpers} from "@aave-helpers/GovHelpers.sol";
import {AaveV2Ethereum} from "@aave-address-book/AaveV2Ethereum.sol";
import {AaveAddressBookV2} from "@aave-address-book/AaveAddressBook.sol";
import {AaveV2EthereumAMM} from "@aave-address-book/AaveV2EthereumAMM.sol";
import {AaveV2CollectorContractConsolidation} from "../AaveV2CollectorContractConsolidation.sol";
import {AMMWithdrawer} from "../AMMWithdrawer.sol";
import {ProposalPayload} from "../ProposalPayload.sol";
import {DeployMainnetProposal} from "../../script/DeployMainnetProposal.s.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {AggregatorV3Interface} from "../external/AggregatorV3Interface.sol";

contract ProposalPayloadE2ETest is Test {
    event Swap(address indexed tokenIn, address indexed tokenOut, uint256 amountIn, uint256 amountOut);

    address public constant USDC_WHALE = 0x55FE002aefF02F77364de339a1292923A15844B8;
    address public constant ETH_WHALE = 0xF977814e90dA44bFA03b6295A0616a897441aceC;

    AaveV2CollectorContractConsolidation public collectorContract;

    address[17] public allTokens;

    AaveV2CollectorContractConsolidation public consolidationContract;
    AMMWithdrawer public withdrawContract;
    ProposalPayload public payload;
    uint256 public proposalId;

    address public constant AMMDAI = 0x79bE75FFC64DD58e66787E4Eae470c8a1FD08ba4;
    address public constant AMMUSDC = 0xd24946147829DEaA935bE2aD85A3291dbf109c80;
    address public constant AMMUSDT = 0x17a79792Fe6fE5C95dFE95Fe3fCEE3CAf4fE4Cb7;
    address public constant AMMWBTC = 0x13B2f6928D7204328b0E8E4BCd0379aA06EA21FA;
    address public constant AMMWETH = 0xf9Fb4AD91812b704Ba883B11d2B576E890a6730A;

    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address[5] private ammTokens = [AMMDAI, AMMUSDC, AMMUSDT, AMMWBTC, AMMWETH];
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
        GovHelpers.passVoteAndExecute(vm, proposalId);

        uint256 length = ammTokens.length;
        for (uint256 i = 0; i < length; i++) {
            // The withdrawal conversion is not 1 to 1 so might not be able to redeem to 0
            assertApproxEqAbs(IERC20(ammTokens[i]).balanceOf(AaveV2Ethereum.COLLECTOR), 0, 4 ether);
        }
    }

    function testAllowanceOfToken() public {
        address arai = consolidationContract.ARAI();
        assertEq(IERC20(arai).allowance(AaveV2Ethereum.COLLECTOR, address(consolidationContract)), 0);

        GovHelpers.passVoteAndExecute(vm, proposalId);

        (uint256 qty, , , , , ) = consolidationContract.assets(arai);
        assertLe(qty, IERC20(arai).allowance(AaveV2Ethereum.COLLECTOR, address(consolidationContract)));
    }

    function testSwapZeroAmount() public {
        GovHelpers.passVoteAndExecute(vm, proposalId);

        address frax = consolidationContract.FRAX();
        vm.expectRevert(AaveV2CollectorContractConsolidation.OnlyNonZeroAmount.selector);
        consolidationContract.swap(frax, 0);
    }

    function testSwapInvalidToken() public {
        GovHelpers.passVoteAndExecute(vm, proposalId);

        vm.expectRevert(AaveV2CollectorContractConsolidation.UnsupportedToken.selector);
        consolidationContract.swap(WETH, 1e18);
    }

    function testSwapTooManyTokens() public {
        GovHelpers.passVoteAndExecute(vm, proposalId);

        (uint256 initialQty, , , , , ) = consolidationContract.assets(consolidationContract.ARAI());
        vm.expectRevert(AaveV2CollectorContractConsolidation.NotEnoughTokens.selector);
        consolidationContract.swap(allTokens[0], initialQty + 1);
    }

    function testSwapAmountOfTokensOut() public {
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
            consolidationContract.swap(token, amountToWithdraw);

            (uint256 endQty, , , , , ) = consolidationContract.assets(token);
            assertEq(endQty, initialQty - amountToWithdraw);
        }
    }

    function testSwapAllTokensOut() public {
        GovHelpers.passVoteAndExecute(vm, proposalId);

        vm.prank(USDC_WHALE);
        IERC20(USDC).approve(address(consolidationContract), type(uint256).max);
        vm.stopPrank();

        uint256 length = allTokens.length;
        for (uint256 i = 0; i < length; i++) {
            address token = allTokens[i];

            vm.prank(USDC_WHALE);
            consolidationContract.swap(token, type(uint256).max);

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
        assertEq(result, 337336478);
    }

    function testGetAmountInAllaSUSDWithETHBasedFeed() public {
        // Get out max amount of aUSD from contract (11,483.0000000 in USDC terms)
        uint256 amountOut = 2**256 - 1;
        uint256 result = consolidationContract.getAmountIn(consolidationContract.ASUSD(), amountOut);
        // aUSD to USDC should be close to 1:1 in price, thus result should be very close, minus discount
        assertEq(result, 11872754069);
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
}
