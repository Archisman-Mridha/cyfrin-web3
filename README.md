# Learning Web3

Learning web3 using this amazing video from Freecodecamp - https://youtu.be/gyMwXuJrbJQ.

## Concepts

+ *`Smart Contract`* - A smart contract is an agreement (a set of instructions) deployed on a decentralized blockchain. Once a smart contract is deployed, it **cannot be altered (immutable)**, is **automatically executed** and **everyone can view** the terms of the agreement / contract. The code execution is done by a group of people so no single entity can alter the terms of the agreement.

    > In case traditional contracts, whoever owns the contract can switch off the contract. But this cannot be done in case of smart contracts.

    Smart Contracts are like unbreakable promises and are also called `trust minimized agreements`.

+ *`Oracle`* - Suppose a smart contract, needs **data from the real world**. But they themselves cannot interact with the internet and fetch data. So to solve this problem we have oracles. Oracle bridges the gap between the internet and the blockchain. Example of an oracle is - [Chainlink](https://chain.link/). Like the blockchain, oracles can be decentralized too which keeps our applications **truly decentralized**.

    > The combination of onchain decentralized logic and offchain oracles gives rise to `hybrid smart contracts`.

+ *`EIP and ERC`* - EIP stands for **Ethereum Improvement Protocol** and represents a proposal which can enhance the behaviour of the Ethereum blockchain. Once an EIP gets enough attention, it is standardized by creating an ERC. ERC stands for *`Ethereum Request for Comments`*. One such ERC is **ERC-20**. ERC-20 speaks about how tokens should be created using smart contracts.

## Tutorials

+ Creating our own ERC20 token using hardhat - *./erc20*.

## How the blockchain works

The fundamental unit of the blockchain is a block. This is a structure of a block -

```
{
    id,
    nonce,
    data,
    previousBlockHash,
    hash // hash of this current block
}
```

Blockchain, as deductable from the name itself is a chain of these blocks. The first block in the blockchain is called a *`genesis block`*. Now suppose, we want to create a new block A and append it to the genesis block. How is this done ?

+ Using the block id, nonce, data and previousBlockHash, the hash for the current block is generated using an encryption algorithm (for example the **SHA256 algorithm**). But wait, there is a challenge! The **generated hash should have 4 0s in the beginning**. The block id, data and previousBlockHash have fixed values. So we need to **experiment with the value of nonce** until this challenge is solved. *`nonce`* is an integer. When the value of nonce is found for which the hash of the current block contains 4 0s in the beginning, the new block is appended to the tail of the blockchain.

    > Because of this challenge, mining a block (creating and appending a new block to the blockchain) is so computationally expensive.

+ Lets append another block B to the blockchain.

+ Alright, we have the new blocks A and B appended to the blockchain. The structure of the blockchain now looks like this -

    genesis block <- block A <- block B.

    Suppose somebody changes the data in block A. This will change the hash of the block A. So A.hash and B.previousBlockHash won't match and this messes up the part of the blockchain starting from block A.

Ofcourse if there is a single blockchain, then the blockchain owner can start remining the blocks A and B, adjusting the nonce values. Here comes in *`decentralization`*. So, we maintain not a single blockchain, but multiple copies of a blockchain.

To know more about the *`immutable`* nature of blockchains, you can watch this - https://www.youtube.com/watch?v=gyMwXuJrbJQ&t=3932s.

> In the data section of a block, we will put our smart contracts making them immutable.

## Transactions | Gas | Private and Public keys