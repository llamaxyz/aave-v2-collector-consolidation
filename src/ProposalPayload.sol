// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity ^0.8.15;

import {AaveV2CollectorContractConsolidation} from "./AaveV2CollectorContractConsolidation.sol";
import {AMMWithdrawer} from "./AMMWithdrawer.sol";
import {IAaveEcosystemReserveController} from "./external/aave/IAaveEcosystemReserveController.sol";
import {AaveV2Ethereum} from "@aave-address-book/AaveV2Ethereum.sol";
import {AaveV2EthereumAMM} from "@aave-address-book/AaveV2EthereumAMM.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";

/**
 * @title Payload to approve v2 Collector Contract consolidation
 * @author Llama
 * @notice Provides an execute function for Aave governance to execute
 * Governance Forum Post: https://governance.aave.com/t/arfc-ethereum-v2-collector-contract-consolidation/10909
 * Snapshot: https://snapshot.org/#/aave.eth/proposal/0xe1e72012b87ead90a7be671cd4adba4b5d7c543be5c2c876d14337e6e22d3cec
 */
contract ProposalPayload {
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

    // AMM Tokens

    address public constant aAMMDAI = 0x79bE75FFC64DD58e66787E4Eae470c8a1FD08ba4;
    address public constant aAMMUSDC = 0xd24946147829DEaA935bE2aD85A3291dbf109c80;
    address public constant aAMMUSDT = 0x17a79792Fe6fE5C95dFE95Fe3fCEE3CAf4fE4Cb7;
    address public constant aAMMWBTC = 0x13B2f6928D7204328b0E8E4BCd0379aA06EA21FA;
    address public constant aAMMWETH = 0xf9Fb4AD91812b704Ba883B11d2B576E890a6730A;

    AaveV2CollectorContractConsolidation public immutable consolidationContract;
    AMMWithdrawer public immutable withdrawContract;

    constructor(AaveV2CollectorContractConsolidation _consolidationContract, AMMWithdrawer _withdrawContract) {
        consolidationContract = _consolidationContract;
        withdrawContract = _withdrawContract;
    }

    /// @notice The AAVE governance executor calls this function to implement the proposal.
    function execute() external {
        // Transfer to withdraw contract to spend pre-defined amount of tokens and then redeem AMM Tokens
        IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).transfer(
            AaveV2Ethereum.COLLECTOR,
            aAMMDAI,
            address(withdrawContract),
            IERC20(aAMMDAI).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).transfer(
            AaveV2Ethereum.COLLECTOR,
            aAMMUSDC,
            address(withdrawContract),
            IERC20(aAMMUSDC).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).transfer(
            AaveV2Ethereum.COLLECTOR,
            aAMMUSDT,
            address(withdrawContract),
            IERC20(aAMMUSDT).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).transfer(
            AaveV2Ethereum.COLLECTOR,
            aAMMWBTC,
            address(withdrawContract),
            IERC20(aAMMWBTC).balanceOf(AaveV2Ethereum.COLLECTOR)
        );
        IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).transfer(
            AaveV2Ethereum.COLLECTOR,
            aAMMWETH,
            address(withdrawContract),
            IERC20(aAMMWETH).balanceOf(AaveV2Ethereum.COLLECTOR)
        );

        withdrawContract.redeem();

        // Approve the Consolidation Contract to spend pre-defined amount of tokens from AAVE V2 Collector
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     ARAI,
        //     address(consolidationContract),
        //     IERC20(ARAI).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     AAMPL,
        //     address(consolidationContract),
        //     IERC20(AAMPL).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     AFRAX,
        //     address(consolidationContract),
        //     IERC20(AFRAX).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     FRAX,
        //     address(consolidationContract),
        //     IERC20(FRAX).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     AUST,
        //     address(consolidationContract),
        //     IERC20(AUST).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     SUSD,
        //     address(consolidationContract),
        //     IERC20(SUSD).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     ASUSD,
        //     address(consolidationContract),
        //     IERC20(ASUSD).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     TUSD,
        //     address(consolidationContract),
        //     IERC20(TUSD).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     ATUSD,
        //     address(consolidationContract),
        //     IERC20(ATUSD).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     AMANA,
        //     address(consolidationContract),
        //     IERC20(AMANA).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     MANA,
        //     address(consolidationContract),
        //     IERC20(MANA).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     ABUSD,
        //     address(consolidationContract),
        //     IERC20(ABUSD).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     BUSD,
        //     address(consolidationContract),
        //     IERC20(BUSD).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     ZRX,
        //     address(consolidationContract),
        //     IERC20(ZRX).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     AZRX,
        //     address(consolidationContract),
        //     IERC20(AZRX).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     AENS,
        //     address(consolidationContract),
        //     IERC20(AENS).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
        // IAaveEcosystemReserveController(AaveV2Ethereum.COLLECTOR_CONTROLLER).approve(
        //     AaveV2Ethereum.COLLECTOR,
        //     ADPI,
        //     address(consolidationContract),
        //     IERC20(ADPI).balanceOf(AaveV2Ethereum.COLLECTOR)
        // );
    }
}
