// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import {ChaseGem} from "../src/ChaseGem.sol";

contract AddNewGem is Script {
    function run() public {
        uint256 privKey = vm.envUint("PRIVATE_KEY");
        address chaseGemAddress = vm.envAddress("CHASE_GEM_ADDRESS");
        address deployer = vm.rememberKey(privKey);
        vm.startBroadcast(deployer);
        ChaseGem chaseGem = ChaseGem(chaseGemAddress);
        address gem1Address = 0xd6adcf3FBFF643dBB22e89B4550ce50E8c22460F;
        string memory gem1Avatar = "https://pbs.twimg.com/profile_images/1580943652045701120/yc9sUEj9.jpg";
        string memory gem1Name = "DeFiMinty";
        string memory gem1Bio =
            "Author of https://defiminty.substack.com/p/smart-money-insights-6, insights on on-chain data";
        string memory gem1Url = "https://twitter.com/DeFiMinty";
        ChaseGem.Gem memory gem1 =
            ChaseGem.Gem({user: gem1Address, avatar: gem1Avatar, name: gem1Name, bio: gem1Bio, url: gem1Url});

        uint8 chooseTag = 1;
        require(chaseGem.latestTag() >= chooseTag, "Tag not exists");
        uint8[] memory tags = new uint8[](1);
        tags[0] = chooseTag;
        chaseGem.addNewGem(gem1, tags);
        vm.stopBroadcast();
    }
}
