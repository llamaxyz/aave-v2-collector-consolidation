// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {AaveV2CollectorContractConsolidation} from "./AaveV2CollectorContractConsolidation.sol";
import {AMMWithdrawer} from "./AMMWithdrawer.sol";
import {TokenAddresses} from "./TokenAddresses.sol";
import {AaveMisc} from "@aave-address-book/AaveMisc.sol";
import {AaveV2Ethereum} from "@aave-address-book/AaveV2Ethereum.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

/**
 * @title Payload to redeem set of AMM tokens and to deploy a contract for V2Collector consolidation
 * @author Llama
 * @notice Provides an execute function for Aave governance to execute
 * Governance Forum Post: https://governance.aave.com/t/arfc-ethereum-v2-collector-contract-consolidation/10909
 * Snapshot: https://snapshot.org/#/aave.eth/proposal/0xe1e72012b87ead90a7be671cd4adba4b5d7c543be5c2c876d14337e6e22d3cec
 */
contract ProposalPayload {
    address public immutable consolidationContract;
    AMMWithdrawer public immutable withdrawContract;

    constructor(address _consolidationContract, AMMWithdrawer _withdrawContract) {
        consolidationContract = _consolidationContract;
        withdrawContract = _withdrawContract;
    }

    /// @notice The AAVE governance executor calls this function to implement the proposal.
    function execute() external {
        // Transfer to withdraw contract to spend pre-defined amount of tokens and then redeem AMM Tokens
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.transfer(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.aAMMDAI,
            address(withdrawContract),
            IERC20(TokenAddresses.aAMMDAI).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.transfer(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.aAMMUSDC,
            address(withdrawContract),
            IERC20(TokenAddresses.aAMMUSDC).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.transfer(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.aAMMUSDT,
            address(withdrawContract),
            IERC20(TokenAddresses.aAMMUSDT).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.transfer(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.aAMMWBTC,
            address(withdrawContract),
            IERC20(TokenAddresses.aAMMWBTC).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.transfer(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.aAMMWETH,
            address(withdrawContract),
            IERC20(TokenAddresses.aAMMWETH).balanceOf(AaveV2Ethereum.COLLECTOR)
        );

        withdrawContract.redeem();

        // Approve the Consolidation Contract to spend pre-defined amount of tokens from AAVE V2 Collector
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.ARAI,
            consolidationContract,
            IERC20(TokenAddresses.ARAI).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.AAMPL,
            consolidationContract,
            IERC20(TokenAddresses.AAMPL).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.AFRAX,
            consolidationContract,
            IERC20(TokenAddresses.AFRAX).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.FRAX,
            consolidationContract,
            IERC20(TokenAddresses.FRAX).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.AUST,
            consolidationContract,
            IERC20(TokenAddresses.AUST).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.SUSD,
            consolidationContract,
            IERC20(TokenAddresses.SUSD).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.ASUSD,
            consolidationContract,
            IERC20(TokenAddresses.ASUSD).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.TUSD,
            consolidationContract,
            IERC20(TokenAddresses.TUSD).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.ATUSD,
            consolidationContract,
            IERC20(TokenAddresses.ATUSD).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.AMANA,
            consolidationContract,
            IERC20(TokenAddresses.AMANA).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.MANA,
            consolidationContract,
            IERC20(TokenAddresses.MANA).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.ABUSD,
            consolidationContract,
            IERC20(TokenAddresses.ABUSD).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.BUSD,
            consolidationContract,
            IERC20(TokenAddresses.BUSD).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.ZRX,
            consolidationContract,
            IERC20(TokenAddresses.ZRX).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.AZRX,
            consolidationContract,
            IERC20(TokenAddresses.AZRX).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.AENS,
            consolidationContract,
            IERC20(TokenAddresses.AENS).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        AaveMisc.AAVE_ECOSYSTEM_RESERVE_CONTROLLER.approve(
            AaveV2Ethereum.COLLECTOR,
            TokenAddresses.ADPI,
            consolidationContract,
            IERC20(TokenAddresses.ADPI).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
    }
}
