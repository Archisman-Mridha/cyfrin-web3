## Concepts

+ `Blockchain` - Bitcoin was one of the first protocols to use this revolutionary technologies called Blockchain. The Bitcoin white paper written by Satoshi Nakamoto, outlined how Bitcoin can make peer-to-peer transactions in a decentralized network. This network was powered by cryptography and decentrality. People were able to make transactions without any censorchip or control from a central authority. Due to its features, people started using it as a superior digital store of value (a better store of value over something like Gold). Thats'y people also refer to Bitcoin as Digital Gold. Similar to Gold, there is a limited amount of Bitcoin available on the planet.

    Few years after the Bitcoin whitepaper was released, Vitalik Buterin released a whitepaper on a protocol called Ethereum, which allowed people to not only make decentralized transactions but also decentralized agreements, organizations etc.

+ `Smart Contracts` - A smart contract is an agreement (a set of instructions) deployed on a decentralized blockchain. Once a smart contract is deployed, it **cannot be altered (immutable)**, is **automatically executed** and **everyone can view** the terms of the agreement / contract. The code execution is done by a group of people, so no single entity can alter the terms of the agreement.

    > In case of traditional contracts, whoever owns the contract can switch off the contract. But this cannot be done in case of smart contracts.

    Smart Contracts are like unbreakable promises and are also called `Trust Minimized Agreements`.

+ `Oracle` - Suppose a smart contract, needs **data from the real world**. But they themselves cannot interact with the internet and fetch data. So to solve this problem we have oracles. Oracles bridge the gap between the internet and the blockchain. Example of an oracle is - [Chainlink](https://chain.link/). Like the blockchain, oracles can be decentralized too which keeps our applications **truly decentralized**.

    > The combination of onchain decentralized logic and offchain oracles gives rise to `hybrid smart contracts`.

+ `Dapp` - Dapp stands for Decentralized Application. A Decentralized Application is usually a collection of smart contracts.

+ `EIP and ERC` - EIP stands for **Ethereum Improvement Protocol** and represents a proposal which can enhance the behaviour of the Ethereum blockchain. Once an EIP gets enough attention, it is standardized by creating an ERC. ERC stands for `Ethereum Request for Comments`. One such ERC is **ERC-20**. ERC-20 speaks about how tokens should be created using smart contracts. You can read more about ERC20 here - https://ethereum.org/en/developers/docs/standards/tokens/erc-20/.

+ `DAO(Decentralized Autonomous Organization)` - DAO represents a group that is governed by a set of rules represented by a smart contract. Example of DAO - [`Compound`](https://compound.finance/) which is a DeFi platform. Now if the Compound maintainers want to do any kind of change to the platform, they need to create a `proposal` here - https://compound.finance/governance. Here is one such proposal - https://compound.finance/governance/proposals/141. The proposal creator **needs to perform a transaction** to create that proposal. After the proposal is created, it becomes active after some time and the platform users can then start voting for or against the proposal. After some time, based on the voting result, the proposal is **failed** or is **succeded and is queued for execution**. If the proposal is queued, it is then implemented.
    > Sometimes along with the voting system, a discussion hub is also present.

    The architecture of voting mechanism is crucial. There can be 2 types of voting mechanism :

    - **Onchain voting** - The voter needs to call a vote function from a smart contract and send a signed transaction. But in case of onchain voting, the cost of the process becomes soo high because of the gas consumed during sending the signed transactions. To solve this problem, there is a method called `Governer C`.

    - **Offchain voting** - In this case, we sign the transaction, but we dont send it to the blockchain. Instead we **store the signed transactions in a decentralized database like IPFS**. Then we count the votes and deliver the result to the blockchain using a decentralized system of oracles. So throughout the voting process, the number of transactions sent to the blockchain is just 1. This mechanism saves lots of gas and also gives a more efficient way to store the voting transactions.

    The voting mechanism can also be broken down to subtypes from different perspectives.

    Tools we can use to build DAOs - [`Snapshot`](https://snapshot.org/#/).

+ `NFTS (Non Fungible Tokens)` - NFTs (also known as `ERC721s`) are a token standard created on the Ethereum platform. **They are unique and not interchangeable (unlike USD or Eth)**. Currently, they are mostly represented as digital pieces of art that have a permanent history of who has deployed and owned them.

    NFTs are deployed to smart contract platforms and then can be viewed and traded in NFT platforms / marketplaces like `Opensea` (note - they can also be viewed and traded without the help of these NFT marketplaces).

+ `IPFS (Inter Planatery File System)` - IPFS is `a distributed decentralized data storage system`, that is not exactly a blockhain system but is similar to a blockchain system.

    Our IPFS node hashes our data to get a unique hash. The hash is then linked to the data. Every IPFS node in the planet has the same hashing function. The IPFS node then hosts the data mapped to the unique hash.

    Our IPFS node is connected to a massive network of other IPFS nodes. The hash and the data gets replicated to some of those other IPFS nodes.

    An IPFS node is very lightweight compared to a blockchain node, since it supports only data storage and not any smart contract execution. Each IPFS node can choose which data it will replicate. So an IPFS node can be of size few MBs to several TBs or more.

    Now what if, no other IPFS node has replicated the data hosted in our IPFS node? We can use [Pinata cloud](https://www.pinata.cloud) - a service which will replicate our host our data, so that it remains available, even when our IPFS node goes down.

## How the blockchain works

The fundamental unit of the blockchain is a block. This is a structure of a block -

```
id,
nonce,
data,
previousBlockHash,
hash (of this current block)
```

Blockchain, as deductable from the name itself is a chain of these blocks. The first block in the blockchain is called a `genesis block`. Now suppose, we want to create a new block **A** and append it to the genesis block. How is this done ?

+ Using the block id, nonce, data and previousBlockHash, the hash for the current block is generated using an encryption algorithm (for example the **SHA256 algorithm**). But wait, there is a challenge! The **generated hash should have 4 0s in the beginning**. The block id, data and previousBlockHash have fixed values. So we need to **experiment with the value of nonce** until this challenge is solved. `nonce` (number used only once) is an integer. When the value of nonce is found for which the hash of the current block contains 4 0s in the beginning, the new block is appended to the tail of the blockchain.

    > Because of this challenge, mining a block (creating and appending a new block to the blockchain) is so computationally expensive.

+ Lets append another block B to the blockchain.

+ Alright, we have the new blocks A and B appended to the blockchain. The structure of the blockchain now looks like this -

    genesis block <- block A <- block B.

    Suppose somebody changes the data in block A. This will change the hash of the block A. So A.hash and B.previousBlockHash won't match and this messes up the part of the blockchain starting from block A.

Ofcourse if there is a single blockchain, then the blockchain owner can start remining the blocks A and B, adjusting the nonce values. Here comes in `decentralization`: we maintain not a single blockchain, but multiple copies of a blockchain.

To know more about the `immutable` nature of blockchains, you can watch this - https://www.youtube.com/watch?v=gyMwXuJrbJQ&t=3932s.

> In the data section of a block, we will put our smart contracts making them immutable. In general, we can say that a blockchain is a decentralized database. With Ethereum, we also get the ability to perform decentralized computations.

## Transactions | Gas

For every transaction

- A **unique id** called `transaction hash` will be generated using the private key of a keypair (generated using an Elliptic Curve Digital Signature Algorithm). Anyone can verify the transaction signature, using the public key of the keypair.
    > The private key is generated using your Metamask passphrase and Metamask account number combined. Part of it is your Metamask account address. The public key is then derived from the private key.
- You need to pay a `transaction fee` - Whenever you perform a transaction, the node validating that transaction (called `validator` / `miner`) gets paid with a little portion of the transaction fee as compensation.
  > Gas is a unit of computational measurement. The more complex the transaction is, the more gas is required. **transaction fee = gas used . current gas price**. The current gas price is proportional to how many transactions are currently being performed in the blockchain.

  Currently in Ethereum, according to EIP 1559, for every transaction, you need to mention a `base fee`. It is the minimum gas price you need to set, to execute the transaction. The base fee is measured in `Gwei` (1 billion gwei = 1 ether). We also need to mention a `max fee` and `max priority fee` (max gas fee + maximum tip we are willing to pay to the miners). Currently in Ethereum, **the base fee ends up getting burned** (removed from circulation forever). The base fee is proportional to how many transactions are currently being performed in the blockchain. So the amount of economic compensation a miner gets for verifying the transaction = **transaction fee - base fee**.

## Consensus - Proof of Work | Proof of Stake

`Consensus` is the mechanism used to reach on an agreement regarding the state of the blockchain. A blockchain consensus protocol can be broken down into 2 pieces - a `chain selection algorithm` and `a sybil resistence mechanism`.

There are 2 kinds of sybil resistence mechanisms - the `proof of work` and the `proof of stake` algorithms. Using the sybil resistence mechanism, the blockchain prevents `sybil attacks` (someone creating a bunch of fake nodes and trying to influence the blockchain).

- `Proof of Work` algorithm (uses a lot of electrical energy) - The mining procedure being done to append a new block to the blockchain is the proof of work algorithm in action. It helps to determine who is going to be the `block author` (All nodes are competing against each other to find the nonce value. Block author is the first node which finds it and appends the new block to the blockchain.). The block author receives the transaction fee (and maybe also `block reward` from the protocol itself). The blockchain can make the challenge related to the proof of work algorithm (like finding the nonce value) hard or easy, which in-turn decides how fast blocks can be appended to the blockchain. The rate at which blocks are added to a blockchain is called the `block time`.
  > In both Bitcoin and Ethereum, the consensus algorithm being used is called `Nakamoto consensus` - a combination of the proof of work algorithm and the longest chain selection algorithm - **the decentralized network uses that blockchain which at the moment has the largest number of blocks**. This makes sense, since longer the blockchain, harder the challenge is going to be. So the rate of new blocks being added will slow down while other blockchains get synced.

  > TODO : Document `block confirmation` and `51% attack`.

- `Proof of Stake` algorithm (lot more environment friendly) - Ethereum 2 has migrated to the proof of stake algorithm. Here, nodes are called `validators` and not miners. Validators are randomly chosen to create new blocks and validate transactions based on the amount of cryptocurrency they hold and are willing to `stake` as collateral. The idea is that participants with a higher stake in the cryptocurrency have a greater interest in maintaining the integrity of the network, as they have more to lose if they act maliciously.
    > The PoS algorithm is much more environment friendly, since instead of all nodes competing to find the nonce value of a transaction, only 1 node does it. Other nodes just validate the transaction.

## Stablecoins

> A stablecoin is a **non volatile crypto asset** (whose buying power fluctuates very little relative to the rest of the market).

Consider we went to an apple market 1 year ago and bought *x* amount of apples in exchange of 1 Bitcoin (this is called `buying power`). Today, if we try to do the some, we can get way more number of apples using 1 Bitcoin (let's say *y* amount). But instead of Bitcoin, if we used USD, those numbers would more or less be the same (*x = y*). Thus USD is a much more `stable currency` compared to Bitcoin.

Most cryptocurrencies by nature are not stable. In our everyday life, we need some sort of stable currency to fulfill the 3 functions of money - `storage of value`, `unit of account` (a way to measure how valuable something is) and `medium of exchange`. In web3, stablecoins play the role of stable currencies.

Factors categorizing stablecoins -

+ `Relative stability` - These stablecoins are stable relative to only something else. The most common type of stablecoins are `pegged / anchored` stablecoins like Tether, Dai, USDC (stable relative to USD) etc. We also have `floating` stablecoins - they are not pegged to anything but their buying power stays the same (neutral to inflation unlike anchored stablecoins) (like Rai).

+ `Stability method` (`governed` or `algorithmic`)

+ `Collateral type` (`exogenous` or `endogenous`)

## Tutorials

+ Creating our own [ERC20 token](./erc20).

+ Creating an [NFT marketplace](./nft-marketplace).

+ Creating a DAO - *./dao*.

+ Creating a [Stablecoin](./stablecoin).

## TODO

- [ ] Read about the Robinhood scam and how it could be prevented using Blockchains.
- [ ] What are `Decentralized Exchanges` (like `Uniswap`)?
- [ ] What are `Layer 2 Blockchains` (like Arbitrum, Optimism etc.)? Arbitrum and Optimism are also called `Rollups`. How do they work?
