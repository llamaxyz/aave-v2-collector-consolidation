// SPDX-License-Identifier: MIT
pragma solidity ^0.8.15;

import "@forge-std/console.sol";
import {Script} from "@forge-std/Script.sol";
import {AaveV2CollectorContractConsolidation} from "../src/AaveV2CollectorContractConsolidation.sol";
import {AMMWithdrawer} from "../src/AMMWithdrawer.sol";
import {ProposalPayload} from "../src/ProposalPayload.sol";

contract DeployProposalPayload is Script {
    function run() external {
        vm.startBroadcast();
        AaveV2CollectorContractConsolidation consolidationContract = new AaveV2CollectorContractConsolidation();
        console.log("AaveV2CollectorContractConsolidation address", address(consolidationContract));
        AMMWithdrawer withdrawContract = new AMMWithdrawer();
        console.log("AMMWithdrawer address", address(withdrawContract));

        ProposalPayload proposalPayload = new ProposalPayload(address(consolidationContract), withdrawContract);
        console.log("Proposal Payload address", address(proposalPayload));
        vm.stopBroadcast();
    }
}
