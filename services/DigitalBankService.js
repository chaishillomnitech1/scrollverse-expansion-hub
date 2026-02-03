/**
 * ScrollVerse Digital Bank Service
 * Provides high-level API for banking operations
 */

class DigitalBankService {
  constructor(web3, contractAddress, contractABI) {
    this.web3 = web3;
    this.contract = new web3.eth.Contract(contractABI, contractAddress);
  }

  /**
   * Deposit funds to the bank
   * @param {string} amount - Amount in wei
   * @param {string} fromAddress - User address
   * @returns {Promise<Object>} Transaction receipt
   */
  async deposit(amount, fromAddress) {
    try {
      const tx = await this.contract.methods
        .depositFunds()
        .send({ from: fromAddress, value: amount });

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
   * Withdraw funds from the bank
   * @param {string} amount - Amount in wei
   * @param {string} fromAddress - User address
   * @returns {Promise<Object>} Transaction receipt
   */
  async withdraw(amount, fromAddress) {
    try {
      const tx = await this.contract.methods
        .withdrawFunds(amount)
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
   * Request a loan
   * @param {string} principal - Loan amount in wei
   * @param {number} durationDays - Loan duration in days
   * @param {string} collateral - Collateral amount in wei (minimum 150% of principal)
   * @param {string} fromAddress - Borrower address
   * @returns {Promise<Object>} Transaction receipt with loan ID
   */
  async requestLoan(principal, durationDays, collateral, fromAddress) {
    try {
      const tx = await this.contract.methods
        .requestLoan(principal, durationDays)
        .send({ from: fromAddress, value: collateral });

      const loanId = tx.events.LoanIssued.returnValues.loanId;

      return {
        success: true,
        loanId,
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
   * Repay a loan
   * @param {string} loanId - Loan ID
   * @param {string} repaymentAmount - Total repayment (principal + interest)
   * @param {string} fromAddress - Borrower address
   * @returns {Promise<Object>} Transaction receipt
   */
  async repayLoan(loanId, repaymentAmount, fromAddress) {
    try {
      const tx = await this.contract.methods
        .repayLoan(loanId)
        .send({ from: fromAddress, value: repaymentAmount });

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
   * Purchase insurance
   * @param {string} coverage - Coverage amount in wei
   * @param {number} durationDays - Policy duration in days
   * @param {string} premium - Premium amount in wei
   * @param {string} fromAddress - Policy holder address
   * @returns {Promise<Object>} Transaction receipt with policy ID
   */
  async purchaseInsurance(coverage, durationDays, premium, fromAddress) {
    try {
      const tx = await this.contract.methods
        .purchaseInsurance(coverage, durationDays)
        .send({ from: fromAddress, value: premium });

      const policyId = tx.events.InsurancePurchased.returnValues.policyId;

      return {
        success: true,
        policyId,
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
   * Get loan details
   * @param {string} loanId - Loan ID
   * @returns {Promise<Object>} Loan details
   */
  async getLoan(loanId) {
    try {
      return await this.contract.methods.loans(loanId).call();
    } catch (error) {
      throw new Error(`Failed to get loan: ${error.message}`);
    }
  }

  /**
   * Get insurance policy details
   * @param {string} policyId - Policy ID
   * @returns {Promise<Object>} Insurance policy details
   */
  async getInsurancePolicy(policyId) {
    try {
      return await this.contract.methods.insurancePolicies(policyId).call();
    } catch (error) {
      throw new Error(`Failed to get insurance policy: ${error.message}`);
    }
  }

  /**
   * Get user's deposit balance
   * @param {string} address - User address
   * @returns {Promise<string>} Balance in wei
   */
  async getDepositBalance(address) {
    try {
      return await this.contract.methods.getDepositBalance(address).call();
    } catch (error) {
      throw new Error(`Failed to get deposit balance: ${error.message}`);
    }
  }

  /**
   * Calculate loan repayment amount
   * @param {string} principal - Loan principal in wei
   * @returns {Promise<Object>} Breakdown of repayment
   */
  async calculateLoanRepayment(principal) {
    try {
      const interestRate = await this.contract.methods.loanInterestRate().call();
      const principalBN = this.web3.utils.toBN(principal);
      const rateBN = this.web3.utils.toBN(interestRate);
      const basisPoints = this.web3.utils.toBN(10000);

      const interest = principalBN.mul(rateBN).div(basisPoints);
      const total = principalBN.add(interest);

      return {
        principal: principal,
        interest: interest.toString(),
        total: total.toString()
      };
    } catch (error) {
      throw new Error(`Failed to calculate repayment: ${error.message}`);
    }
  }

  /**
   * Calculate insurance premium
   * @param {string} coverage - Coverage amount in wei
   * @param {number} durationDays - Policy duration in days
   * @returns {Promise<string>} Premium in wei
   */
  async calculateInsurancePremium(coverage, durationDays) {
    try {
      const premiumRate = await this.contract.methods.insurancePremiumRate().call();
      const coverageBN = this.web3.utils.toBN(coverage);
      const rateBN = this.web3.utils.toBN(premiumRate);
      const durationBN = this.web3.utils.toBN(durationDays);
      const basisPoints = this.web3.utils.toBN(10000);
      const daysInYear = this.web3.utils.toBN(365);

      const premium = coverageBN.mul(rateBN).mul(durationBN).div(basisPoints.mul(daysInYear));

      return premium.toString();
    } catch (error) {
      throw new Error(`Failed to calculate premium: ${error.message}`);
    }
  }

  /**
   * Calculate minimum collateral for loan
   * @param {string} principal - Loan principal in wei
   * @returns {string} Minimum collateral in wei (150% of principal)
   */
  calculateMinimumCollateral(principal) {
    const principalBN = this.web3.utils.toBN(principal);
    const minCollateral = principalBN.mul(this.web3.utils.toBN(150)).div(this.web3.utils.toBN(100));
    return minCollateral.toString();
  }
}

module.exports = DigitalBankService;
