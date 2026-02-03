# ScrollVerse Expansion Hub - Deployment Guide

## Overview

This guide covers deploying the ScrollVerse Expansion Hub smart contracts to various blockchain networks.

---

## Prerequisites

1. **Node.js and npm** (v14 or higher)
2. **Hardhat or Truffle** (deployment framework)
3. **Web3 Provider** (Infura, Alchemy, or local node)
4. **Wallet with funds** for deployment gas fees

---

## Setup

### 1. Install Dependencies

```bash
npm install --save-dev hardhat
npm install @openzeppelin/contracts
npm install dotenv
npm install web3
```

### 2. Configure Environment

Create a `.env` file in the root directory:

```env
# Network RPC URLs
MAINNET_RPC_URL=https://mainnet.infura.io/v3/YOUR_INFURA_KEY
GOERLI_RPC_URL=https://goerli.infura.io/v3/YOUR_INFURA_KEY
SEPOLIA_RPC_URL=https://sepolia.infura.io/v3/YOUR_INFURA_KEY
POLYGON_RPC_URL=https://polygon-mainnet.infura.io/v3/YOUR_INFURA_KEY
BSC_RPC_URL=https://bsc-dataseed.binance.org/

# Private Keys (NEVER commit these!)
DEPLOYER_PRIVATE_KEY=your_private_key_here

# Etherscan API Keys (for verification)
ETHERSCAN_API_KEY=your_etherscan_api_key
POLYGONSCAN_API_KEY=your_polygonscan_api_key
BSCSCAN_API_KEY=your_bscscan_api_key

# ScrollVerse Authority Address
SCROLLVERSE_AUTHORITY=0xYourAuthorityAddress
```

### 3. Hardhat Configuration

Create `hardhat.config.js`:

```javascript
require("@nomiclabs/hardhat-waffle");
require("@nomiclabs/hardhat-etherscan");
require("dotenv").config();

module.exports = {
  solidity: {
    version: "0.8.0",
    settings: {
      optimizer: {
        enabled: true,
        runs: 200
      }
    }
  },
  networks: {
    hardhat: {
      chainId: 1337
    },
    goerli: {
      url: process.env.GOERLI_RPC_URL,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY]
    },
    sepolia: {
      url: process.env.SEPOLIA_RPC_URL,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY]
    },
    mainnet: {
      url: process.env.MAINNET_RPC_URL,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY]
    },
    polygon: {
      url: process.env.POLYGON_RPC_URL,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY]
    },
    bsc: {
      url: process.env.BSC_RPC_URL,
      accounts: [process.env.DEPLOYER_PRIVATE_KEY]
    }
  },
  etherscan: {
    apiKey: {
      mainnet: process.env.ETHERSCAN_API_KEY,
      goerli: process.env.ETHERSCAN_API_KEY,
      sepolia: process.env.ETHERSCAN_API_KEY,
      polygon: process.env.POLYGONSCAN_API_KEY,
      bsc: process.env.BSCSCAN_API_KEY
    }
  }
};
```

---

## Deployment Scripts

### Create `scripts/deploy.js`:

```javascript
const hre = require("hardhat");

async function main() {
  console.log("Starting ScrollVerse Expansion Hub deployment...");

  // Get deployer account
  const [deployer] = await hre.ethers.getSigners();
  console.log("Deploying contracts with account:", deployer.address);
  console.log("Account balance:", (await deployer.getBalance()).toString());

  // Deploy NFT Minting Contract
  console.log("\n1. Deploying ScrollVerse NFT...");
  const ScrollVerseNFT = await hre.ethers.getContractFactory("ScrollVerseNFT");
  const nft = await ScrollVerseNFT.deploy();
  await nft.deployed();
  console.log("ScrollVerseNFT deployed to:", nft.address);

  // Deploy Crypto Gateway
  console.log("\n2. Deploying Crypto Gateway...");
  const CryptoGateway = await hre.ethers.getContractFactory("ScrollVerseCryptoGateway");
  const gateway = await CryptoGateway.deploy();
  await gateway.deployed();
  console.log("CryptoGateway deployed to:", gateway.address);

  // Deploy Marketplace
  console.log("\n3. Deploying Marketplace...");
  const Marketplace = await hre.ethers.getContractFactory("ScrollVerseMarketplace");
  const marketplace = await Marketplace.deploy();
  await marketplace.deployed();
  console.log("Marketplace deployed to:", marketplace.address);

  // Deploy Fair Exchange
  console.log("\n4. Deploying Fair Exchange...");
  const FairExchange = await hre.ethers.getContractFactory("ScrollVerseFairExchange");
  const exchange = await FairExchange.deploy();
  await exchange.deployed();
  console.log("FairExchange deployed to:", exchange.address);

  // Deploy Digital Bank
  console.log("\n5. Deploying Digital Bank...");
  const DigitalBank = await hre.ethers.getContractFactory("ScrollVerseDigitalBank");
  const bank = await DigitalBank.deploy();
  await bank.deployed();
  console.log("DigitalBank deployed to:", bank.address);

  // Save deployment addresses
  const deploymentInfo = {
    network: hre.network.name,
    deployer: deployer.address,
    timestamp: new Date().toISOString(),
    contracts: {
      ScrollVerseNFT: nft.address,
      CryptoGateway: gateway.address,
      Marketplace: marketplace.address,
      FairExchange: exchange.address,
      DigitalBank: bank.address
    }
  };

  console.log("\n=== Deployment Summary ===");
  console.log(JSON.stringify(deploymentInfo, null, 2));

  // Save to file
  const fs = require('fs');
  const path = require('path');
  const deploymentsDir = path.join(__dirname, '../deployments');
  
  if (!fs.existsSync(deploymentsDir)) {
    fs.mkdirSync(deploymentsDir);
  }
  
  const filename = `deployment-${hre.network.name}-${Date.now()}.json`;
  fs.writeFileSync(
    path.join(deploymentsDir, filename),
    JSON.stringify(deploymentInfo, null, 2)
  );
  
  console.log(`\nDeployment info saved to: deployments/${filename}`);

  // Wait for confirmations before verification
  if (hre.network.name !== "hardhat" && hre.network.name !== "localhost") {
    console.log("\nWaiting for block confirmations...");
    await nft.deployTransaction.wait(5);
    
    console.log("\nVerifying contracts on Etherscan...");
    try {
      await hre.run("verify:verify", {
        address: nft.address,
        constructorArguments: []
      });
    } catch (error) {
      console.log("Verification error:", error.message);
    }
  }

  console.log("\n✅ Deployment completed successfully!");
}

main()
  .then(() => process.exit(0))
  .catch((error) => {
    console.error(error);
    process.exit(1);
  });
```

---

## Deployment Steps

### Local Testing (Hardhat Network)

```bash
# Start local Hardhat node
npx hardhat node

# In another terminal, deploy
npx hardhat run scripts/deploy.js --network localhost
```

### Testnet Deployment (Goerli)

```bash
# Deploy to Goerli testnet
npx hardhat run scripts/deploy.js --network goerli

# Verify on Etherscan
npx hardhat verify --network goerli DEPLOYED_CONTRACT_ADDRESS
```

### Mainnet Deployment

```bash
# Deploy to Ethereum mainnet
npx hardhat run scripts/deploy.js --network mainnet

# Deploy to Polygon mainnet
npx hardhat run scripts/deploy.js --network polygon

# Deploy to BSC mainnet
npx hardhat run scripts/deploy.js --network bsc
```

---

## Post-Deployment

### 1. Verify Contracts

Verify all deployed contracts on block explorers:

```bash
npx hardhat verify --network <network> <contract-address>
```

### 2. Update Configuration

Update the contract addresses in:
- Documentation (README.md, docs/API.md)
- Frontend configuration
- Service layer initialization

### 3. Test Deployment

Run integration tests against deployed contracts:

```bash
npx hardhat test --network <network>
```

### 4. Initialize Services

Create a service configuration file:

```javascript
// config/contracts.js
module.exports = {
  mainnet: {
    nft: "0x...",
    gateway: "0x...",
    marketplace: "0x...",
    exchange: "0x...",
    bank: "0x..."
  },
  polygon: {
    nft: "0x...",
    gateway: "0x...",
    marketplace: "0x...",
    exchange: "0x...",
    bank: "0x..."
  }
};
```

---

## Security Considerations

1. **Audit Smart Contracts**: Before mainnet deployment, conduct thorough security audits
2. **Test Extensively**: Run comprehensive tests on testnets
3. **Use Multi-sig Wallet**: For ScrollVerse Authority address
4. **Monitor Deployments**: Set up monitoring and alerts
5. **Emergency Plans**: Have pause/upgrade mechanisms ready

---

## Cost Estimation

Approximate gas costs for deployment (Ethereum mainnet):

| Contract | Estimated Gas | Cost @ 50 Gwei |
|----------|---------------|----------------|
| ScrollVerseNFT | ~2,000,000 | ~0.1 ETH |
| CryptoGateway | ~1,800,000 | ~0.09 ETH |
| Marketplace | ~2,500,000 | ~0.125 ETH |
| FairExchange | ~3,000,000 | ~0.15 ETH |
| DigitalBank | ~3,500,000 | ~0.175 ETH |
| **Total** | **~12,800,000** | **~0.64 ETH** |

*Note: Costs vary based on network congestion and gas prices*

---

## Troubleshooting

### Common Issues

**Issue**: "Insufficient funds for gas"
- **Solution**: Ensure deployer wallet has enough native tokens

**Issue**: "Nonce too high"
- **Solution**: Reset nonce or wait for pending transactions

**Issue**: "Contract verification failed"
- **Solution**: Ensure correct constructor arguments and compiler version

**Issue**: "Transaction timeout"
- **Solution**: Increase gas price or use faster network

---

## Multi-Chain Deployment Strategy

1. **Primary Chain**: Deploy to Ethereum mainnet first
2. **Secondary Chains**: Deploy to Polygon, BSC for lower fees
3. **Bridge Setup**: Configure cross-chain communication
4. **Sync State**: Ensure consistency across chains

---

## Maintenance

### Regular Tasks

- Monitor contract interactions
- Update documentation
- Respond to security alerts
- Deploy upgrades (if using proxy pattern)
- Communicate with community

### Upgrade Process

If using upgradeable contracts:

```bash
npx hardhat run scripts/upgrade.js --network <network>
```

---

## Support

For deployment assistance:
- Discord: [discord.gg/scrollverse](https://discord.gg/scrollverse)
- Email: support@scrollverse.io
- Documentation: [docs.scrollverse.io](https://docs.scrollverse.io)

---

**🕋♾️ ScrollVerse Expansion Hub - Deploy with Confidence**
