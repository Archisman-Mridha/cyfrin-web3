import { HardhatRuntimeEnvironment } from "hardhat/types"
import { MarketplaceContract__factory } from "../typechain-types"
import { DeployFunction } from "hardhat-deploy/types"

const deployMarketplaceContract: DeployFunction= async function({ ethers }: HardhatRuntimeEnvironment) {

    const accounts= await ethers.getSigners( ),
        deployer= accounts[0]

    console.info("address of the deployer - ", await deployer.getAddress( ))

    const marketplaceContractFactory=
        await ethers.getContractFactory("MarketplaceContract", deployer) as MarketplaceContract__factory
    const deployedMarketplaceContract= await marketplaceContractFactory.deploy( )

    console.info("address of the marketplace contract when it's deployed - ", deployedMarketplaceContract.address)
    console.info("💫 deploying marketplace contract...")

    await deployedMarketplaceContract.deployed( )

    console.info("🚀 marketplace contract deployment finished")
}

export default deployMarketplaceContract
