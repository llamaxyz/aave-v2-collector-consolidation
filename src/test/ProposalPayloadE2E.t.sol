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
import {ProposalPayload} from "../ProposalPayload.sol";
import {DeployMainnetProposal} from "../../script/DeployMainnetProposal.s.sol";
import {AaveV2Helpers, InterestStrategyValues, IReserveInterestRateStrategy, ReserveConfig} from "./utils/AaveV2Helpers.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

contract ProposalPayloadE2ETest is Test {
    AaveV2CollectorContractConsolidation public consolidationContract;
    ProposalPayload public payload;

    function setUp() public {
        vm.createSelectFork(vm.rpcUrl("mainnet"), 16183428); // December 14, 2022

        consolidationContract = new AaveV2CollectorContractConsolidation();
        payload = new ProposalPayload(consolidationContract);
    }

    function testTheTest() public {
        address DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
        address AMMDAI = 0x79bE75FFC64DD58e66787E4Eae470c8a1FD08ba4;
        uint256 amount = IERC20(AMMDAI).balanceOf(AaveV2Ethereum.COLLECTOR);
        console.log(amount);
        AaveV2EthereumAMM.POOL.withdraw(DAI, amount, AaveV2Ethereum.COLLECTOR);
        uint256 endAmount = IERC20(DAI).balanceOf(AaveV2Ethereum.COLLECTOR);
        assertEq(endAmount, 0);
    }

    function testAllowanceOfToken() public {
        address arai = consolidationContract.ARAI();

        assertEq(IERC20(arai).allowance(AaveV2Ethereum.COLLECTOR, address(consolidationContract)), 0);
        (uint256 qty, , , , , ) = consolidationContract.assets(arai);

        _passProposal();

        assertLe(qty, IERC20(arai).allowance(AaveV2Ethereum.COLLECTOR, address(consolidationContract)));
    }

    function _passProposal() internal {
        // 1. create proposal
        vm.startPrank(GovHelpers.AAVE_WHALE);
        uint256 proposalId = DeployMainnetProposal._deployMainnetProposal(
            address(payload),
            0x78ce0d63ca0c186ca3f58e712d3f1861ced3dad15ce3ad4f0e005d1663b49caf
        );
        vm.stopPrank();

        // 2. Execute proposal
        GovHelpers.passVoteAndExecute(vm, proposalId);
    }
}
