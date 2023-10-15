// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import {ChaseGem} from "../src/ChaseGem.sol";

contract AddNewTag is Script {
    function run() public {
        uint256 privKey = vm.envUint("PRIVATE_KEY");
        address chaseGemAddress = vm.envAddress("CHASE_GEM_ADDRESS");
        address deployer = vm.rememberKey(privKey);
        vm.startBroadcast(deployer);
        ChaseGem chaseGem = ChaseGem(chaseGemAddress);
        chaseGem.addNewTag("Alpha");
        vm.stopBroadcast();
    }
}
