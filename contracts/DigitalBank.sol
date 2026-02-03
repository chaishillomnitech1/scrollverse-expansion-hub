// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ScrollVerse Digital Bank
 * @dev Provides loans, insurance, and financial token management
 * Core component of the ScrollVerse financial ecosystem
 */
contract ScrollVerseDigitalBank {
    address public scrollVerseAuthority;
    uint256 public loanInterestRate = 500; // 5% in basis points
    uint256 public insurancePremiumRate = 100; // 1% in basis points
    
    struct Loan {
        address borrower;
        uint256 principal;
        uint256 interest;
        uint256 collateral;
        bool active;
        bool repaid;
        uint256 issuedAt;
        uint256 dueDate;
    }
    
    struct Insurance {
        address holder;
        uint256 coverage;
        uint256 premium;
        bool active;
        uint256 startDate;
        uint256 endDate;
    }
    
    struct FinancialToken {
        string name;
        string symbol;
        uint256 totalSupply;
        mapping(address => uint256) balances;
    }
    
    // Storage
    mapping(bytes32 => Loan) public loans;
    mapping(bytes32 => Insurance) public insurancePolicies;
    mapping(string => FinancialToken) private financialTokens;
    mapping(address => uint256) public deposits;
    
    // Events
    event LoanIssued(bytes32 indexed loanId, address indexed borrower, uint256 principal, uint256 collateral);
    event LoanRepaid(bytes32 indexed loanId, address indexed borrower, uint256 amount);
    event InsurancePurchased(bytes32 indexed policyId, address indexed holder, uint256 coverage);
    event InsuranceClaimed(bytes32 indexed policyId, address indexed holder, uint256 payout);
    event FinancialTokenCreated(string symbol, uint256 totalSupply);
    event Deposit(address indexed user, uint256 amount);
    event Withdrawal(address indexed user, uint256 amount);
    
    modifier onlyAuthority() {
        require(msg.sender == scrollVerseAuthority, "Only ScrollVerse Authority can execute");
        _;
    }
    
    constructor() {
        scrollVerseAuthority = msg.sender;
    }
    
    /**
     * @dev Deposit funds to the bank
     */
    function depositFunds() public payable {
        require(msg.value > 0, "Deposit must be greater than 0");
        deposits[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    /**
     * @dev Withdraw funds from the bank
     */
    function withdrawFunds(uint256 amount) public {
        require(deposits[msg.sender] >= amount, "Insufficient balance");
        deposits[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }
    
    /**
     * @dev Request a loan with collateral
     */
    function requestLoan(uint256 principal, uint256 durationDays) public payable returns (bytes32) {
        require(principal > 0, "Principal must be greater than 0");
        require(msg.value >= (principal * 150) / 100, "Collateral must be at least 150% of principal");
        
        bytes32 loanId = keccak256(abi.encodePacked(msg.sender, principal, block.timestamp));
        uint256 interest = (principal * loanInterestRate) / 10000;
        
        loans[loanId] = Loan({
            borrower: msg.sender,
            principal: principal,
            interest: interest,
            collateral: msg.value,
            active: true,
            repaid: false,
            issuedAt: block.timestamp,
            dueDate: block.timestamp + (durationDays * 1 days)
        });
        
        // Transfer loan amount to borrower
        payable(msg.sender).transfer(principal);
        
        emit LoanIssued(loanId, msg.sender, principal, msg.value);
        return loanId;
    }
    
    /**
     * @dev Repay a loan
     */
    function repayLoan(bytes32 loanId) public payable {
        Loan storage loan = loans[loanId];
        require(loan.active, "Loan not active");
        require(loan.borrower == msg.sender, "Only borrower can repay");
        
        uint256 totalRepayment = loan.principal + loan.interest;
        require(msg.value >= totalRepayment, "Insufficient repayment amount");
        
        loan.active = false;
        loan.repaid = true;
        
        // Return collateral
        payable(msg.sender).transfer(loan.collateral);
        
        // Refund excess payment
        if (msg.value > totalRepayment) {
            payable(msg.sender).transfer(msg.value - totalRepayment);
        }
        
        emit LoanRepaid(loanId, msg.sender, totalRepayment);
    }
    
    /**
     * @dev Purchase insurance
     */
    function purchaseInsurance(uint256 coverage, uint256 durationDays) public payable returns (bytes32) {
        require(coverage > 0, "Coverage must be greater than 0");
        
        uint256 premium = (coverage * insurancePremiumRate * durationDays) / (10000 * 365);
        require(msg.value >= premium, "Insufficient premium payment");
        
        bytes32 policyId = keccak256(abi.encodePacked(msg.sender, coverage, block.timestamp));
        
        insurancePolicies[policyId] = Insurance({
            holder: msg.sender,
            coverage: coverage,
            premium: premium,
            active: true,
            startDate: block.timestamp,
            endDate: block.timestamp + (durationDays * 1 days)
        });
        
        emit InsurancePurchased(policyId, msg.sender, coverage);
        
        // Refund excess payment
        if (msg.value > premium) {
            payable(msg.sender).transfer(msg.value - premium);
        }
        
        return policyId;
    }
    
    /**
     * @dev Claim insurance (authority only for validation)
     */
    function claimInsurance(bytes32 policyId, uint256 claimAmount) public onlyAuthority {
        Insurance storage policy = insurancePolicies[policyId];
        require(policy.active, "Policy not active");
        require(block.timestamp <= policy.endDate, "Policy expired");
        require(claimAmount <= policy.coverage, "Claim exceeds coverage");
        
        policy.active = false;
        payable(policy.holder).transfer(claimAmount);
        
        emit InsuranceClaimed(policyId, policy.holder, claimAmount);
    }
    
    /**
     * @dev Create a new financial token
     */
    function createFinancialToken(string memory name, string memory symbol, uint256 totalSupply) public onlyAuthority {
        require(totalSupply > 0, "Total supply must be greater than 0");
        
        FinancialToken storage token = financialTokens[symbol];
        token.name = name;
        token.symbol = symbol;
        token.totalSupply = totalSupply;
        token.balances[scrollVerseAuthority] = totalSupply;
        
        emit FinancialTokenCreated(symbol, totalSupply);
    }
    
    /**
     * @dev Update loan interest rate (authority only)
     */
    function updateLoanInterestRate(uint256 newRate) public onlyAuthority {
        require(newRate <= 2000, "Interest rate cannot exceed 20%");
        loanInterestRate = newRate;
    }
    
    /**
     * @dev Update insurance premium rate (authority only)
     */
    function updateInsurancePremiumRate(uint256 newRate) public onlyAuthority {
        require(newRate <= 1000, "Premium rate cannot exceed 10%");
        insurancePremiumRate = newRate;
    }
    
    /**
     * @dev Get deposit balance
     */
    function getDepositBalance(address user) public view returns (uint256) {
        return deposits[user];
    }
}
