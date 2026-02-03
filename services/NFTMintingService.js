/**
 * ScrollVerse NFT Minting Service
 * Provides high-level API for minting and managing NFTs
 */

class NFTMintingService {
  constructor(web3, contractAddress, contractABI) {
    this.web3 = web3;
    this.contract = new web3.eth.Contract(contractABI, contractAddress);
  }

  /**
   * Mint a new NFT
   * @param {string} toAddress - Recipient address
   * @param {string} metadataURI - IPFS or other URI containing NFT metadata
   * @param {string} fromAddress - Sender address
   * @returns {Promise<Object>} Transaction receipt with token ID
   */
  async mintNFT(toAddress, metadataURI, fromAddress) {
    try {
      const tx = await this.contract.methods
        .mintNFT(toAddress, metadataURI)
        .send({ from: fromAddress });

      const tokenId = tx.events.NFTMinted.returnValues.tokenId;
      
      return {
        success: true,
        tokenId,
        transactionHash: tx.transactionHash,
        blockNumber: tx.blockNumber
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Get NFT owner
   * @param {number} tokenId - Token ID
   * @returns {Promise<string>} Owner address
   */
  async getOwner(tokenId) {
    try {
      return await this.contract.methods.ownerOf(tokenId).call();
    } catch (error) {
      throw new Error(`Failed to get owner: ${error.message}`);
    }
  }

  /**
   * Get NFT metadata URI
   * @param {number} tokenId - Token ID
   * @returns {Promise<string>} Metadata URI
   */
  async getTokenURI(tokenId) {
    try {
      return await this.contract.methods.tokenURI(tokenId).call();
    } catch (error) {
      throw new Error(`Failed to get token URI: ${error.message}`);
    }
  }

  /**
   * Get user's NFT balance
   * @param {string} address - User address
   * @returns {Promise<number>} Number of NFTs owned
   */
  async getBalance(address) {
    try {
      return await this.contract.methods.balanceOf(address).call();
    } catch (error) {
      throw new Error(`Failed to get balance: ${error.message}`);
    }
  }

  /**
   * Transfer NFT to another address
   * @param {string} toAddress - Recipient address
   * @param {number} tokenId - Token ID to transfer
   * @param {string} fromAddress - Current owner address
   * @returns {Promise<Object>} Transaction receipt
   */
  async transferNFT(toAddress, tokenId, fromAddress) {
    try {
      const tx = await this.contract.methods
        .transfer(toAddress, tokenId)
        .send({ from: fromAddress });

      return {
        success: true,
        transactionHash: tx.transactionHash,
        blockNumber: tx.blockNumber
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Get total supply of NFTs
   * @returns {Promise<number>} Total number of minted NFTs
   */
  async getTotalSupply() {
    try {
      return await this.contract.methods.totalSupply().call();
    } catch (error) {
      throw new Error(`Failed to get total supply: ${error.message}`);
    }
  }

  /**
   * Fetch NFT metadata from URI
   * @param {string} uri - Metadata URI
   * @returns {Promise<Object>} NFT metadata
   */
  async fetchMetadata(uri) {
    try {
      // Handle IPFS URIs
      if (uri.startsWith('ipfs://')) {
        uri = uri.replace('ipfs://', 'https://ipfs.io/ipfs/');
      }

      const response = await fetch(uri);
      return await response.json();
    } catch (error) {
      throw new Error(`Failed to fetch metadata: ${error.message}`);
    }
  }

  /**
   * Get NFT details including metadata
   * @param {number} tokenId - Token ID
   * @returns {Promise<Object>} Complete NFT details
   */
  async getNFTDetails(tokenId) {
    try {
      const owner = await this.getOwner(tokenId);
      const uri = await this.getTokenURI(tokenId);
      const metadata = await this.fetchMetadata(uri);

      return {
        tokenId,
        owner,
        uri,
        metadata
      };
    } catch (error) {
      throw new Error(`Failed to get NFT details: ${error.message}`);
    }
  }
}

module.exports = NFTMintingService;
