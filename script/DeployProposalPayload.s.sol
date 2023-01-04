// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import {Script} from "@forge-std/Script.sol";
import {AaveV2CollectorContractConsolidation} from "../src/AaveV2CollectorContractConsolidation.sol";
import {AMMWithdrawer} from "../src/AMMWithdrawer.sol";
import {ProposalPayload} from "../src/ProposalPayload.sol";

contract DeployProposalPayload is Script {
    function run() external {
        vm.startBroadcast();
        AaveV2CollectorContractConsolidation consolidationContract = new AaveV2CollectorContractConsolidation();
        AMMWithdrawer withdrawContract = new AMMWithdrawer();

        ProposalPayload proposalPayload = new ProposalPayload(address(consolidationContract), withdrawContract);
        vm.stopBroadcast();
    }
}
