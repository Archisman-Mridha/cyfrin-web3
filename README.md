# Learning Web3

Learning web3 using this amazing video from Freecodecamp - https://youtu.be/gyMwXuJrbJQ.

## Concepts

+ *`Smart Contract`* - A smart contract is an agreement (a set of instructions) deployed on a decentralized blockchain. Once a smart contract is deployed, it **cannot be altered (immutable)**, is **automatically executed** and **everyone can view** the terms of the agreement / contract. The code execution is done by a group of people so no single entity can alter the terms of the agreement.

    > In case traditional contracts, whoever owns the contract can switch off the contract. But this cannot be done in case of smart contracts.

    Smart Contracts are like unbreakable promises and are also called `trust minimized agreements`.

+ *`Oracle`* - Suppose a smart contract, needs **data from the real world**. But they themselves cannot interact with the internet and fetch data. So to solve this problem we have oracles. Oracle bridges the gap between the internet and the blockchain. Example of an oracle is - [Chainlink](https://chain.link/). Like the blockchain, oracles can be decentralized too which keeps our applications **truly decentralized**.

    > The combination of onchain decentralized logic and offchain oracles gives rise to `hybrid smart contracts`.

+ *`EIP and ERC`* - EIP stands for **Ethereum Improvement Protocol** and represents a proposal which can enhance the behaviour of the Ethereum blockchain. Once an EIP gets enough attention, it is standardized by creating an ERC. ERC stands for *`Ethereum Request for Comments`*. One such ERC is **ERC-20**. ERC-20 speaks about how tokens should be created using smart contracts. You can read more about ERC20 here - https://ethereum.org/en/developers/docs/standards/tokens/erc-20/.

+ *`DeFi (Decentralized Finance)`* - Aave is a defi **protocol for borrowing and lending cryptocurrencies**. Traditionally, we put our money in the bank for sometime and the bank gives us interest for that. Using Aave, we can lend our cryptocurrencies and get interests from the lender.
    > The only difference from traditional systems is that, nobody touches our money.
    You can learn more about how decentralized financial products work and become a *`Quantitave DeFi Engineer`* 😊.

+ *`DAO(Decentralized Autonomous Organization)`* - DAO represents a group that is governed by a set of rules represented by a smart contract. Example of DAO - *[`Compound`](https://compound.finance/)* which is a DeFi platform. Now if the Compound maintainers want to do any kind of change to the platform, they need to create a *`proposal`* here - https://compound.finance/governance. Here is one such proposal - https://compound.finance/governance/proposals/141. The proposal creator **needs to perform a transaction** to create that proposal. After the proposal is created, it becomes active after some time and the platform users can then start voting for or against the proposal. After some time, based on the voting result, the proposal is **failed** or is **succeded and is queued for execution**. If the proposal is queued, it is then implemented.
    > Sometimes along with the voting system, a discussion hub is also present.

    The architecture of voting mechanism is crucial. There can be 2 types of voting mechanism :

    - **Onchain voting** - The voter needs to call a vote function from a smart contract and send a signed transaction. But in case of onchain voting, the cost of the process becomes soo high because of the gas consumed during sending the signed transactions. To solve this problem, there is a method called *`Governer C`*.

    - **Offchain voting** - In this case, we sign the transaction, but we dont send it to the blockchain. Instead we **store the signed transactions in a decentralized database like IPFS**. Then we count the votes and deliver the result to the blockchain using a decentralized system of oracles. So throughout the voting process, the number of transactions sent to the blockchain is just 1. This mechanism saves lots of gas and also gives a more efficient way to store the voting transactions.

    The voting mechanism can also be broken down to subtypes from different perspectives.

    Tools we can use to build DAOs - *[`Snapshot`](https://snapshot.org/#/)*.

## Tutorials

+ Creating our own ERC20 token using hardhat - *./erc20*.
    > However, generally we won't write all the implementations for an NFT. Rather, we will extend an existing NFT. For example, we can extend the ERC20 standardized token from **OpenZeppelin** - https://docs.openzeppelin.com/contracts/4.x/erc20, to create our own NFT. This token, contains the base implementations.

+ Playing around with Aave - *./aave*.

+ Creating an NFT marketplace - *./nft-marketplace*.

+ Creating a DAO - *./dao*.

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
