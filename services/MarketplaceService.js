/**
 * ScrollVerse Marketplace Service
 * Provides high-level API for marketplace operations
 */

class MarketplaceService {
  constructor(web3, contractAddress, contractABI) {
    this.web3 = web3;
    this.contract = new web3.eth.Contract(contractABI, contractAddress);
  }

  /**
   * List an NFT for sale
   * @param {string} nftContract - NFT contract address
   * @param {number} tokenId - Token ID
   * @param {string} price - Price in wei
   * @param {string} fromAddress - Seller address
   * @returns {Promise<Object>} Transaction receipt with listing ID
   */
  async listItem(nftContract, tokenId, price, fromAddress) {
    try {
      const tx = await this.contract.methods
        .listItem(nftContract, tokenId, price)
        .send({ from: fromAddress });

      const listingId = tx.events.ItemListed.returnValues.listingId;

      return {
        success: true,
        listingId,
        transactionHash: tx.transactionHash
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Buy a listed item
   * @param {string} listingId - Listing ID
   * @param {string} price - Price to pay (in wei)
   * @param {string} fromAddress - Buyer address
   * @returns {Promise<Object>} Transaction receipt
   */
  async buyItem(listingId, price, fromAddress) {
    try {
      const tx = await this.contract.methods
        .buyItem(listingId)
        .send({ from: fromAddress, value: price });

      return {
        success: true,
        transactionHash: tx.transactionHash
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Cancel a listing
   * @param {string} listingId - Listing ID
   * @param {string} fromAddress - Seller address
   * @returns {Promise<Object>} Transaction receipt
   */
  async cancelListing(listingId, fromAddress) {
    try {
      const tx = await this.contract.methods
        .cancelListing(listingId)
        .send({ from: fromAddress });

      return {
        success: true,
        transactionHash: tx.transactionHash
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Make an offer on a listing
   * @param {string} listingId - Listing ID
   * @param {string} offerAmount - Offer amount in wei
   * @param {string} fromAddress - Buyer address
   * @returns {Promise<Object>} Transaction receipt
   */
  async makeOffer(listingId, offerAmount, fromAddress) {
    try {
      const tx = await this.contract.methods
        .makeOffer(listingId)
        .send({ from: fromAddress, value: offerAmount });

      return {
        success: true,
        transactionHash: tx.transactionHash
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Accept an offer
   * @param {string} listingId - Listing ID
   * @param {string} buyerAddress - Buyer address
   * @param {string} fromAddress - Seller address
   * @returns {Promise<Object>} Transaction receipt
   */
  async acceptOffer(listingId, buyerAddress, fromAddress) {
    try {
      const tx = await this.contract.methods
        .acceptOffer(listingId, buyerAddress)
        .send({ from: fromAddress });

      return {
        success: true,
        transactionHash: tx.transactionHash
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Withdraw marketplace earnings
   * @param {string} fromAddress - User address
   * @returns {Promise<Object>} Transaction receipt
   */
  async withdrawEarnings(fromAddress) {
    try {
      const tx = await this.contract.methods
        .withdrawEarnings()
        .send({ from: fromAddress });

      return {
        success: true,
        transactionHash: tx.transactionHash
      };
    } catch (error) {
      return {
        success: false,
        error: error.message
      };
    }
  }

  /**
   * Get listing details
   * @param {string} listingId - Listing ID
   * @returns {Promise<Object>} Listing details
   */
  async getListing(listingId) {
    try {
      return await this.contract.methods.listings(listingId).call();
    } catch (error) {
      throw new Error(`Failed to get listing: ${error.message}`);
    }
  }

  /**
   * Get user earnings
   * @param {string} address - User address
   * @returns {Promise<string>} Earnings in wei
   */
  async getEarnings(address) {
    try {
      return await this.contract.methods.earnings(address).call();
    } catch (error) {
      throw new Error(`Failed to get earnings: ${error.message}`);
    }
  }

  /**
   * Get marketplace fee
   * @returns {Promise<number>} Fee in basis points
   */
  async getMarketplaceFee() {
    try {
      return await this.contract.methods.marketplaceFee().call();
    } catch (error) {
      throw new Error(`Failed to get marketplace fee: ${error.message}`);
    }
  }

  /**
   * Helper: Convert ETH to Wei
   * @param {string} ethAmount - Amount in ETH
   * @returns {string} Amount in wei
   */
  ethToWei(ethAmount) {
    return this.web3.utils.toWei(ethAmount, 'ether');
  }

  /**
   * Helper: Convert Wei to ETH
   * @param {string} weiAmount - Amount in wei
   * @returns {string} Amount in ETH
   */
  weiToEth(weiAmount) {
    return this.web3.utils.fromWei(weiAmount, 'ether');
  }
}

module.exports = MarketplaceService;
