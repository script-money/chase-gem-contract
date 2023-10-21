# ChaseGem: An ERC-1155 Based Gem Find Platform

ChaseGem is a decentralized platform for finding, supporting trustable information source called Gems. Built on the Polygon zkEVM blockchain and utilizing the ERC-1155 token standard, ChaseGem allows users to support hidden gem information source.

## Features

- Create unique Gems with custom attributes and tags by admin
- Support Gems by Ether
- Query and manage Gems through a user-friendly interface

## Smart Contracts

The platform consists of the following smart contracts:

1. `ChaseGem.sol`: The main contract that manages the creation, join and supporting of Gems.

## Installation and Setup

To set up the development environment and deploy the contracts, follow these steps:

1. Install [Foundry](https://book.getfoundry.sh/getting-started/installation)
2. `forge install` to install the dependencies
3. `cp .env.example .env` to create the environment file
4. `anvil --chain-id=1337` to run local node
5. `source .env && forge script script/Deploy.s.sol:Deploy --fork-url $RPC_URL --private-key $PRIVATE_KEY  --via-ir --broadcast` to deploy the contracts

> `source .env && forge script script/AddNewTag.s.sol:AddNewTag --fork-url $RPC_URL --private-key $PRIVATE_KEY  --via-ir --broadcast` to add new tag

> `source .env && forge script script/AddNewGem.s.sol:AddNewGem --fork-url $RPC_URL --private-key $PRIVATE_KEY  --via-ir --broadcast` to add test gem

## Testing

The repository includes a set of tests to ensure the correct functionality of the smart contracts. To run the tests, execute the following command:

```
forge test
```

## License

ChaseGem is released under the [MIT License](LICENSE).
