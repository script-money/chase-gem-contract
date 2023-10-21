// SPDX-License-Identifier: MIT
pragma solidity ^0.8.21;

import {ERC1155URIStorageUpgradeable} from
    "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155URIStorageUpgradeable.sol";
import {OwnableUpgradeable} from "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import {UUPSUpgradeable} from "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";
import {Initializable} from "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract ChaseGem is Initializable, ERC1155URIStorageUpgradeable, OwnableUpgradeable, UUPSUpgradeable {
    error InvalidGemId(uint256 gemId);
    error PaymentNotEnough();

    uint256 public mintPrice;
    uint256 public cutOff;

    struct Gem {
        address user;
        string avatar;
        string name;
        string bio;
        string url;
    }

    uint256 public gemIdIndex;
    uint8 public latestTag;
    mapping(address => uint256) public gemAddressToId;
    mapping(uint256 => Gem) private _idToGem;
    mapping(uint256 => uint256) public idToSupportAmount;
    mapping(uint256 => mapping(address => uint256)) public idToSupporterAmount;
    mapping(uint8 => string) public tagIdToTag;
    mapping(uint8 => mapping(uint256 => bool)) public tagIdToGemIds;
    mapping(uint256 => mapping(uint8 => bool)) public gemIdToTagIds;

    event Join(uint256 indexed gemId, address indexed user, uint256 timestamp);
    event Support(uint256 indexed gemId, address indexed user, uint256 amount);
    event NewGemAdded(uint256 indexed gemId, address indexed user);
    event NewTagAdded(uint256 indexed tagId, string tag);

    constructor() {
        _disableInitializers();
    }

    function initialize(string memory baseUri, address owner_) public initializer {
        __ERC1155URIStorage_init();
        __Ownable_init(owner_);
        __UUPSUpgradeable_init();
        mintPrice = 0.000777777777777777 ether;
        cutOff = 5;
        _setBaseURI(baseUri);
    }

    modifier isValidGemId(uint256 gemId) {
        if (_idToGem[gemId].user == address(0)) {
            revert InvalidGemId(gemId);
        }
        _;
    }

    /* external functions */
    function join(uint256 gemId) external payable isValidGemId(gemId) {
        if (msg.value < mintPrice) {
            revert PaymentNotEnough();
        }
        _mint(msg.sender, gemId, 1, abi.encodePacked(bytes32(block.timestamp)));
        emit Join(gemId, msg.sender, block.timestamp);
    }

    function joinBatch(uint256[] memory gemIds) external payable {
        if (msg.value < mintPrice * gemIds.length) {
            revert PaymentNotEnough();
        }

        for (uint256 i = 0; i < gemIds.length; i++) {
            if (_idToGem[gemIds[i]].user == address(0)) {
                revert InvalidGemId(gemIds[i]);
            }
            _mint(msg.sender, gemIds[i], 1, abi.encodePacked(bytes32(block.timestamp)));
            emit Join(gemIds[i], msg.sender, block.timestamp);
        }
    }

    function support(uint256 gemId) external payable isValidGemId(gemId) {
        if (msg.value == 0) {
            revert PaymentNotEnough();
        }
        // send 95% to gem user
        (bool success,) = payable(_idToGem[gemId].user).call{value: msg.value * (100 - cutOff) / 100}("");
        require(success, "Support transfer failed");
        idToSupportAmount[gemId] += msg.value;
        idToSupporterAmount[gemId][msg.sender] += msg.value;
        emit Support(gemId, msg.sender, msg.value);
    }

    /* public functions */
    function getSupportAmount(uint256 gemId, address fans) public view isValidGemId(gemId) returns (uint256) {
        return idToSupporterAmount[gemId][fans];
    }

    function getGemById(uint256 gemId) public view returns (Gem memory) {
        return _idToGem[gemId];
    }

    function getUserGemBalances(address user, uint256[] memory tokenIds) public view returns (uint256[] memory) {
        uint256[] memory balances = new uint256[](tokenIds.length);
        for (uint256 i = 0; i < tokenIds.length; i++) {
            balances[i] = balanceOf(user, tokenIds[i]);
        }
        return balances;
    }

    function getGemIdsByTag(uint8 tagId) public view returns (uint256[] memory) {
        uint256[] memory gemIds = new uint256[](gemIdIndex);
        uint256 count = 0;
        for (uint256 i = 1; i <= gemIdIndex; i++) {
            if (gemIdToTagIds[i][tagId]) {
                gemIds[count] = i;
                count++;
            }
        }
        assembly {
            mstore(gemIds, count)
        }
        return gemIds;
    }

    /* private function */
    function uintToString(uint256 value) internal pure returns (string memory) {
        if (value == 0) {
            return "0";
        }
        uint256 temp = value;
        uint256 digits;
        while (temp != 0) {
            digits++;
            temp /= 10;
        }
        bytes memory buffer = new bytes(digits);
        while (value != 0) {
            digits -= 1;
            buffer[digits] = bytes1(uint8(48 + uint256(value % 10)));
            value /= 10;
        }
        return string(buffer);
    }

    /* admin functions */
    function addNewGem(Gem memory gem, uint8[] memory tagIds) public onlyOwner {
        if (gemAddressToId[gem.user] != 0) {
            revert("Gem already exists");
        }
        gemIdIndex++;
        gemAddressToId[gem.user] = gemIdIndex;
        _idToGem[gemIdIndex] = gem;
        for (uint256 i = 0; i < tagIds.length; i++) {
            if (tagIds[i] > latestTag) {
                revert("Tag not exists");
            }
            gemIdToTagIds[gemIdIndex][tagIds[i]] = true;
            tagIdToGemIds[tagIds[i]][gemIdIndex] = true;
        }
        _setURI(gemIdIndex, uintToString(gemIdIndex));
        emit NewGemAdded(gemIdIndex, gem.user);
    }

    function addNewTag(string memory tag) public onlyOwner {
        latestTag += 1;
        tagIdToTag[latestTag] = tag;
        emit NewTagAdded(latestTag, tag);
    }

    function setBaseURI(string memory baseURI) public onlyOwner {
        _setBaseURI(baseURI);
    }

    /* upgrade functions */
    function _authorizeUpgrade(address newImplementation) internal override onlyOwner {}
}
