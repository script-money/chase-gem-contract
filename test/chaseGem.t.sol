// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import "../src/ChaseGem.sol";
import "../src/UUPSProxy.sol";
import {PRBTest} from "@prb/test/PRBTest.sol";
import "forge-std/console2.sol";

contract ChaseGemTest is PRBTest {
    ChaseGem chaseGem;

    // DeFiMinty
    address gem1Address = 0xd6adcf3FBFF643dBB22e89B4550ce50E8c22460F;
    string gem1Avatar = "https://pbs.twimg.com/profile_images/1580943652045701120/yc9sUEj9.jpg";
    string gem1Name = "DeFiMinty";
    string gem1Bio = "Author of https://defiminty.substack.com/p/smart-money-insights-6, insights on on-chain data";
    string gem1Url = "https://twitter.com/DeFiMinty";

    // CryptoNikyous
    address gem2Address = 0x9A4506F51d392bFCd369228f7F8cDE8fB3cc6262;
    string gem2Avatar = "https://pbs.twimg.com/profile_images/1624724399386423297/rJoU601t.jpg";
    string gem2Name = "CryptoNikyous";
    string gem2Bio = "Daily sharing of new projects";
    string gem2Url = "https://twitter.com/CryptoNikyous";

    address user1 = address(0x1);

    function setUp() public {
        ChaseGem chaseGemImplementation = new ChaseGem();
        UUPSProxy chaseGemProxy = new UUPSProxy(address(chaseGemImplementation), "");
        chaseGem = ChaseGem(address(chaseGemProxy));
        chaseGem.initialize("http://localhost:3000/api/gemInfo/");
        vm.deal(user1, 1 ether);
    }

    function testAddNewTag() public {
        assertEq(chaseGem.latestTag(), 0);
        chaseGem.addNewTag("Alpha");
        assertEq(chaseGem.latestTag(), 1);
        assertEq(chaseGem.tagIdToTag(1), "Alpha");
        assertEq(chaseGem.tagIdToTag(2), "");
    }

    function testAddNewGem() public {
        assertEq(chaseGem.gemIdIndex(), 0);
        assertEq(chaseGem.gemAddressToId(gem1Address), 0);
        assertEq(chaseGem.gemAddressToId(gem2Address), 0);

        uint8[] memory alphaTag = new uint8[](1);
        alphaTag[0] = 1;
        ChaseGem.Gem memory gem1 =
            ChaseGem.Gem({user: gem1Address, avatar: gem1Avatar, name: gem1Name, bio: gem1Bio, url: gem1Url});
        ChaseGem.Gem memory gem2 =
            ChaseGem.Gem({user: gem2Address, avatar: gem2Avatar, name: gem2Name, bio: gem2Bio, url: gem2Url});

        vm.expectRevert("Tag not exists");
        chaseGem.addNewGem(gem2, alphaTag);

        chaseGem.addNewTag("Alpha");
        chaseGem.addNewGem(gem2, alphaTag);

        assertEq(chaseGem.gemIdIndex(), 1);
        assertEq(chaseGem.gemAddressToId(gem2Address), 1);
        assertEq(chaseGem.gemAddressToId(gem1Address), 0);

        chaseGem.addNewTag("OnChain");
        uint8[] memory alphaTags = new uint8[](2);
        alphaTags[0] = 1;
        alphaTags[1] = 2;
        chaseGem.addNewGem(gem1, alphaTags);
        assertEq(chaseGem.gemIdIndex(), 2);
        assertEq(chaseGem.gemAddressToId(gem2Address), 1);
        assertEq(chaseGem.gemAddressToId(gem1Address), 2);

        assertEq(chaseGem.gemIdToTagIds(2, 0), false);
        assertEq(chaseGem.gemIdToTagIds(2, 1), true);
        assertEq(chaseGem.gemIdToTagIds(2, 2), true);
        assertEq(chaseGem.gemIdToTagIds(2, 3), false);
    }

    function testJoin() public {
        uint8[] memory alphaTag = new uint8[](1);
        alphaTag[0] = 1;
        ChaseGem.Gem memory gem1 =
            ChaseGem.Gem({user: gem1Address, avatar: gem1Avatar, name: gem1Name, bio: gem1Bio, url: gem1Url});
        chaseGem.addNewTag("Alpha");
        chaseGem.addNewGem(gem1, alphaTag);

        vm.startPrank(user1);
        vm.expectRevert(abi.encodeWithSelector(ChaseGem.InvalidGemId.selector, 0));
        chaseGem.join(0);
        vm.expectRevert(abi.encodeWithSelector(ChaseGem.InvalidGemId.selector, 2));
        chaseGem.join(2);
        vm.expectRevert(ChaseGem.PaymentNotEnough.selector);
        chaseGem.join(1);

        chaseGem.join{value: 0.0008 ether}(1);
        console2.log("nft 1 url", chaseGem.uri(1));
        vm.stopPrank();
    }

    function _setUpGems() private {
        chaseGem.addNewTag("Alpha");
        chaseGem.addNewTag("OnChain");
        uint8[] memory gem1AlphaTag = new uint8[](1);
        gem1AlphaTag[0] = 1;
        uint8[] memory gem2AlphaTag = new uint8[](2);
        gem2AlphaTag[0] = 1;
        gem2AlphaTag[1] = 2;
        ChaseGem.Gem memory gem1 =
            ChaseGem.Gem({user: gem1Address, avatar: gem1Avatar, name: gem1Name, bio: gem1Bio, url: gem1Url});
        ChaseGem.Gem memory gem2 =
            ChaseGem.Gem({user: gem2Address, avatar: gem2Avatar, name: gem2Name, bio: gem2Bio, url: gem2Url});

        chaseGem.addNewGem(gem1, gem1AlphaTag);
        chaseGem.addNewGem(gem2, gem2AlphaTag);
    }

    function testJoinBatch() public {
        _setUpGems();
        vm.startPrank(user1);
        uint256[] memory gemIds = new uint256[](2);
        gemIds[0] = 1;
        gemIds[1] = 3;
        vm.expectRevert(abi.encodeWithSelector(ChaseGem.InvalidGemId.selector, 3));
        chaseGem.joinBatch{value: 0.0016 ether}(gemIds);

        gemIds[1] = 2;
        vm.expectRevert(ChaseGem.PaymentNotEnough.selector);
        chaseGem.joinBatch{value: 0.0015 ether}(gemIds);

        chaseGem.joinBatch{value: 0.0016 ether}(gemIds);
        assertEq(chaseGem.balanceOf(user1, 1), 1);
        assertEq(chaseGem.balanceOf(user1, 2), 1);
    }

    function testSupport() public {
        _setUpGems();
        vm.startPrank(user1);
        vm.expectRevert(ChaseGem.PaymentNotEnough.selector);
        chaseGem.support(1);

        ChaseGem.Gem memory toGem = chaseGem.getGemById(1);
        uint256 balanceBefore = toGem.user.balance;
        chaseGem.support{value: 0.1 ether}(1);
        assertEq(chaseGem.idToSupportAmount(1), 0.1 ether);
        assertEq(chaseGem.idToSupporterAmount(1, user1), 0.1 ether);
        assertEq(toGem.user.balance, balanceBefore + 0.095 ether);
    }

    function testUri() public {
        _setUpGems();
        assertEq(chaseGem.uri(1), "http://localhost:3000/api/gemInfo/1");
        chaseGem.setBaseURI("http://localhost:3000/api/newGemInfo/");
        assertEq(chaseGem.uri(1), "http://localhost:3000/api/newGemInfo/1");
    }
}
