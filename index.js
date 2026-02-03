/**
 * ScrollVerse Expansion Hub - Main Entry Point
 * Example usage of all ScrollVerse services
 */

const Web3 = require('web3');
const NFTMintingService = require('./services/NFTMintingService');
const MarketplaceService = require('./services/MarketplaceService');
const DigitalBankService = require('./services/DigitalBankService');

// Configuration
const config = {
  rpcUrl: process.env.RPC_URL || 'http://localhost:8545',
  contracts: {
    nft: process.env.NFT_CONTRACT_ADDRESS,
    marketplace: process.env.MARKETPLACE_CONTRACT_ADDRESS,
    bank: process.env.BANK_CONTRACT_ADDRESS,
    gateway: process.env.GATEWAY_CONTRACT_ADDRESS,
    exchange: process.env.EXCHANGE_CONTRACT_ADDRESS
  },
  // Contract ABIs would be imported here
  abis: {
    nft: [], // Load from artifacts
    marketplace: [],
    bank: [],
    gateway: [],
    exchange: []
  }
};

/**
 * Initialize ScrollVerse Services
 */
class ScrollVerseHub {
  constructor(web3Provider, contractAddresses, contractABIs) {
    this.web3 = new Web3(web3Provider);
    
    // Initialize services
    this.nft = new NFTMintingService(
      this.web3,
      contractAddresses.nft,
      contractABIs.nft
    );
    
    this.marketplace = new MarketplaceService(
      this.web3,
      contractAddresses.marketplace,
      contractABIs.marketplace
    );
    
    this.bank = new DigitalBankService(
      this.web3,
      contractAddresses.bank,
      contractABIs.bank
    );
  }

  /**
   * Get account balance
   */
  async getBalance(address) {
    const balance = await this.web3.eth.getBalance(address);
    return this.web3.utils.fromWei(balance, 'ether');
  }

  /**
   * Get accounts
   */
  async getAccounts() {
    return await this.web3.eth.getAccounts();
  }
}

/**
 * Example Usage
 */
async function main() {
  try {
    console.log('🕋 Welcome to ScrollVerse Expansion Hub 🕋');
    console.log('==========================================\n');

    // Initialize hub
    const hub = new ScrollVerseHub(
      config.rpcUrl,
      config.contracts,
      config.abis
    );

    // Get accounts
    const accounts = await hub.getAccounts();
    const userAddress = accounts[0];
    console.log('User Address:', userAddress);

    // Check balance
    const balance = await hub.getBalance(userAddress);
    console.log('User Balance:', balance, 'ETH\n');

    // Example 1: Mint an NFT
    console.log('--- Example 1: Minting NFT ---');
    const nftResult = await hub.nft.mintNFT(
      userAddress,
      'ipfs://QmExample123',
      userAddress
    );
    
    if (nftResult.success) {
      console.log('✅ NFT Minted Successfully!');
      console.log('Token ID:', nftResult.tokenId);
      console.log('Transaction:', nftResult.transactionHash);
    } else {
      console.log('❌ NFT Minting Failed:', nftResult.error);
    }
    console.log('');

    // Example 2: List NFT on Marketplace
    console.log('--- Example 2: Listing on Marketplace ---');
    const price = hub.marketplace.ethToWei('1.0'); // 1 ETH
    const listingResult = await hub.marketplace.listItem(
      config.contracts.nft,
      nftResult.tokenId,
      price,
      userAddress
    );
    
    if (listingResult.success) {
      console.log('✅ NFT Listed Successfully!');
      console.log('Listing ID:', listingResult.listingId);
      console.log('Price: 1.0 ETH');
    } else {
      console.log('❌ Listing Failed:', listingResult.error);
    }
    console.log('');

    // Example 3: Request a Loan
    console.log('--- Example 3: Requesting Loan ---');
    const loanPrincipal = hub.bank.web3.utils.toWei('1', 'ether');
    const minCollateral = hub.bank.calculateMinimumCollateral(loanPrincipal);
    const repayment = await hub.bank.calculateLoanRepayment(loanPrincipal);
    
    console.log('Loan Principal:', '1.0 ETH');
    console.log('Minimum Collateral:', hub.bank.web3.utils.fromWei(minCollateral), 'ETH');
    console.log('Interest:', hub.bank.web3.utils.fromWei(repayment.interest), 'ETH');
    console.log('Total Repayment:', hub.bank.web3.utils.fromWei(repayment.total), 'ETH');
    
    const loanResult = await hub.bank.requestLoan(
      loanPrincipal,
      30, // 30 days
      minCollateral,
      userAddress
    );
    
    if (loanResult.success) {
      console.log('✅ Loan Approved!');
      console.log('Loan ID:', loanResult.loanId);
    } else {
      console.log('❌ Loan Request Failed:', loanResult.error);
    }
    console.log('');

    // Example 4: Purchase Insurance
    console.log('--- Example 4: Purchasing Insurance ---');
    const coverage = hub.bank.web3.utils.toWei('5', 'ether');
    const premium = await hub.bank.calculateInsurancePremium(coverage, 365);
    
    console.log('Coverage:', '5.0 ETH');
    console.log('Duration:', '365 days');
    console.log('Premium:', hub.bank.web3.utils.fromWei(premium), 'ETH');
    
    const insuranceResult = await hub.bank.purchaseInsurance(
      coverage,
      365,
      premium,
      userAddress
    );
    
    if (insuranceResult.success) {
      console.log('✅ Insurance Purchased!');
      console.log('Policy ID:', insuranceResult.policyId);
    } else {
      console.log('❌ Insurance Purchase Failed:', insuranceResult.error);
    }
    console.log('');

    console.log('==========================================');
    console.log('✨ ScrollVerse Examples Completed! ✨');
    console.log('🕋♾️ Empowering the Omniversal Economy 🕋♾️');

  } catch (error) {
    console.error('Error:', error.message);
  }
}

// Export for use in other modules
module.exports = {
  ScrollVerseHub,
  config
};

// Run examples if executed directly
if (require.main === module) {
  main()
    .then(() => process.exit(0))
    .catch((error) => {
      console.error(error);
      process.exit(1);
    });
}
