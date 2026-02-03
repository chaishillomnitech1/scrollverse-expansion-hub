// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ScrollVerse Crypto Gateway
 * @dev Handles cryptocurrency payments and multi-chain transactions
 * Enables seamless integration with various blockchain networks
 */
contract ScrollVerseCryptoGateway {
    address public scrollVerseAuthority;
    
    // Payment tracking
    mapping(bytes32 => Payment) public payments;
    mapping(address => uint256) public balances;
    
    struct Payment {
        address payer;
        address payee;
        uint256 amount;
        string currency;
        bool completed;
        uint256 timestamp;
    }
    
    // Events
    event PaymentInitiated(bytes32 indexed paymentId, address indexed payer, address indexed payee, uint256 amount);
    event PaymentCompleted(bytes32 indexed paymentId);
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
     * @dev Deposit funds to the gateway
     */
    function deposit() public payable {
        require(msg.value > 0, "Deposit amount must be greater than 0");
        balances[msg.sender] += msg.value;
        emit Deposit(msg.sender, msg.value);
    }
    
    /**
     * @dev Withdraw funds from the gateway
     */
    function withdraw(uint256 amount) public {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        balances[msg.sender] -= amount;
        payable(msg.sender).transfer(amount);
        emit Withdrawal(msg.sender, amount);
    }
    
    /**
     * @dev Initiate a payment
     */
    function initiatePayment(address payee, uint256 amount, string memory currency) public returns (bytes32) {
        require(balances[msg.sender] >= amount, "Insufficient balance");
        require(payee != address(0), "Invalid payee address");
        
        bytes32 paymentId = keccak256(abi.encodePacked(msg.sender, payee, amount, block.timestamp));
        
        payments[paymentId] = Payment({
            payer: msg.sender,
            payee: payee,
            amount: amount,
            currency: currency,
            completed: false,
            timestamp: block.timestamp
        });
        
        emit PaymentInitiated(paymentId, msg.sender, payee, amount);
        return paymentId;
    }
    
    /**
     * @dev Complete a payment
     */
    function completePayment(bytes32 paymentId) public {
        Payment storage payment = payments[paymentId];
        require(!payment.completed, "Payment already completed");
        require(payment.payer == msg.sender, "Only payer can complete payment");
        require(balances[msg.sender] >= payment.amount, "Insufficient balance");
        
        balances[payment.payer] -= payment.amount;
        balances[payment.payee] += payment.amount;
        payment.completed = true;
        
        emit PaymentCompleted(paymentId);
    }
    
    /**
     * @dev Get balance
     */
    function getBalance(address user) public view returns (uint256) {
        return balances[user];
    }
}
