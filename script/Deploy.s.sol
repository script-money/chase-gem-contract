// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import {UUPSProxy} from "../src/UUPSProxy.sol";
import {ChaseGem} from "../src/ChaseGem.sol";

contract Deploy is Script {
    function run() public {
        uint256 privKey = vm.envUint("PRIVATE_KEY");
        string memory baseUri = vm.envString("BASE_URI");
        address deployer = vm.rememberKey(privKey);
        vm.startBroadcast(deployer);
        ChaseGem chaseGemImplementation = new ChaseGem();
        UUPSProxy chaseGemProxy = new UUPSProxy(address(chaseGemImplementation), "");
        ChaseGem chaseGem = ChaseGem(address(chaseGemProxy));
        chaseGem.initialize(baseUri);
    }
}
