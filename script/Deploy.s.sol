// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "forge-std/Script.sol";
import "forge-std/console2.sol";

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
        chaseGem.initialize(baseUri, deployer);
        console2.log("owner:", chaseGem.owner());
        chaseGem.addNewTag("Alpha");
        chaseGem.addNewTag("DeFi");
        console2.log("tags:", chaseGem.latestTag());

        address gem1Address = 0xd6adcf3FBFF643dBB22e89B4550ce50E8c22460F;
        string memory gem1Avatar = "https://pbs.twimg.com/profile_images/1580943652045701120/yc9sUEj9.jpg";
        string memory gem1Name = "DeFiMinty";
        string memory gem1Bio =
            "Author of https://defiminty.substack.com/p/smart-money-insights-6, insights on on-chain data";
        string memory gem1Url = "https://twitter.com/DeFiMinty";
        ChaseGem.Gem memory gem1 =
            ChaseGem.Gem({user: gem1Address, avatar: gem1Avatar, name: gem1Name, bio: gem1Bio, url: gem1Url});

        uint8[] memory tags = new uint8[](1);
        tags[0] = 2;
        chaseGem.addNewGem(gem1, tags);

        address gem2Address = 0x9A4506F51d392bFCd369228f7F8cDE8fB3cc6262;
        string memory gem2Avatar = "https://pbs.twimg.com/profile_images/1624724399386423297/rJoU601t.jpg";
        string memory gem2Name = "CryptoNikyous";
        string memory gem2Bio = "Daily sharing of new projects";
        string memory gem2Url = "https://twitter.com/CryptoNikyous";
        ChaseGem.Gem memory gem2 =
            ChaseGem.Gem({user: gem2Address, avatar: gem2Avatar, name: gem2Name, bio: gem2Bio, url: gem2Url});
        uint8[] memory tags2 = new uint8[](1);
        tags2[0] = 1;
        chaseGem.addNewGem(gem2, tags2);

        address gem3Address = 0x232E03CC440ad5158Bd38636607f0E0Ad62A01c2;
        string memory gem3Avatar = "https://pbs.twimg.com/profile_images/1605119061402083328/tMR1iA_w.jpg";
        string memory gem3Name = "CJCJCJCJ_";
        string memory gem3Bio = "Daily new news, launches and projects";
        string memory gem3Url = "https://twitter.com/CJCJCJCJ_";
        ChaseGem.Gem memory gem3 =
            ChaseGem.Gem({user: gem3Address, avatar: gem3Avatar, name: gem3Name, bio: gem3Bio, url: gem3Url});
        chaseGem.addNewGem(gem3, tags2);

        uint256[] memory idsByTag1 = chaseGem.getGemIdsByTag(1);
        for (uint256 i = 0; i < idsByTag1.length; i++) {
            console2.log("idsByTag1", idsByTag1[i]);
        }
        uint256[] memory idsByTag2 = chaseGem.getGemIdsByTag(2);
        for (uint256 i = 0; i < idsByTag2.length; i++) {
            console2.log("idsByTag2", idsByTag2[i]);
        }
        vm.stopBroadcast();
    }
}
