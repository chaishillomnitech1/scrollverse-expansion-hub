// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ScrollVerse Fair Exchange System
 * @dev Implements escrow mechanisms and fair trading protocols
 * Ensures trust and transparency in all ScrollVerse transactions
 */
contract ScrollVerseFairExchange {
    address public scrollVerseAuthority;
    uint256 public disputeResolutionFee = 50; // 0.5% in basis points
    
    enum ExchangeStatus { Created, Funded, Completed, Disputed, Resolved, Cancelled }
    
    struct Exchange {
        address party1;
        address party2;
        uint256 party1Amount;
        uint256 party2Amount;
        bool party1Funded;
        bool party2Funded;
        ExchangeStatus status;
        uint256 createdAt;
        string description;
    }
    
    struct Dispute {
        bytes32 exchangeId;
        address initiator;
        string reason;
        bool resolved;
        address winner;
        uint256 createdAt;
    }
    
    // Storage
    mapping(bytes32 => Exchange) public exchanges;
    mapping(bytes32 => Dispute) public disputes;
    mapping(address => uint256) public escrowBalances;
    
    // Events
    event ExchangeCreated(bytes32 indexed exchangeId, address indexed party1, address indexed party2);
    event ExchangeFunded(bytes32 indexed exchangeId, address indexed party, uint256 amount);
    event ExchangeCompleted(bytes32 indexed exchangeId);
    event ExchangeCancelled(bytes32 indexed exchangeId);
    event DisputeRaised(bytes32 indexed disputeId, bytes32 indexed exchangeId, address indexed initiator);
    event DisputeResolved(bytes32 indexed disputeId, address indexed winner);
    
    modifier onlyAuthority() {
        require(msg.sender == scrollVerseAuthority, "Only ScrollVerse Authority can execute");
        _;
    }
    
    modifier onlyParty(bytes32 exchangeId) {
        Exchange storage exchange = exchanges[exchangeId];
        require(msg.sender == exchange.party1 || msg.sender == exchange.party2, "Not a party to this exchange");
        _;
    }
    
    constructor() {
        scrollVerseAuthority = msg.sender;
    }
    
    /**
     * @dev Create a new exchange agreement
     */
    function createExchange(
        address party2,
        uint256 party1Amount,
        uint256 party2Amount,
        string memory description
    ) public returns (bytes32) {
        require(party2 != address(0), "Invalid party2 address");
        require(party1Amount > 0 || party2Amount > 0, "At least one amount must be greater than 0");
        
        bytes32 exchangeId = keccak256(abi.encodePacked(msg.sender, party2, block.timestamp));
        
        exchanges[exchangeId] = Exchange({
            party1: msg.sender,
            party2: party2,
            party1Amount: party1Amount,
            party2Amount: party2Amount,
            party1Funded: false,
            party2Funded: false,
            status: ExchangeStatus.Created,
            createdAt: block.timestamp,
            description: description
        });
        
        emit ExchangeCreated(exchangeId, msg.sender, party2);
        return exchangeId;
    }
    
    /**
     * @dev Fund an exchange (deposit into escrow)
     */
    function fundExchange(bytes32 exchangeId) public payable onlyParty(exchangeId) {
        Exchange storage exchange = exchanges[exchangeId];
        require(exchange.status == ExchangeStatus.Created || exchange.status == ExchangeStatus.Funded, "Invalid exchange status");
        
        if (msg.sender == exchange.party1) {
            require(!exchange.party1Funded, "Party1 already funded");
            require(msg.value >= exchange.party1Amount, "Insufficient funding");
            exchange.party1Funded = true;
            escrowBalances[exchangeId] += exchange.party1Amount;
            
            // Refund excess
            if (msg.value > exchange.party1Amount) {
                payable(msg.sender).transfer(msg.value - exchange.party1Amount);
            }
        } else {
            require(!exchange.party2Funded, "Party2 already funded");
            require(msg.value >= exchange.party2Amount, "Insufficient funding");
            exchange.party2Funded = true;
            escrowBalances[exchangeId] += exchange.party2Amount;
            
            // Refund excess
            if (msg.value > exchange.party2Amount) {
                payable(msg.sender).transfer(msg.value - exchange.party2Amount);
            }
        }
        
        emit ExchangeFunded(exchangeId, msg.sender, msg.value);
        
        // Update status if both parties funded
        if (exchange.party1Funded && exchange.party2Funded) {
            exchange.status = ExchangeStatus.Funded;
        }
    }
    
    /**
     * @dev Complete an exchange (both parties must agree)
     */
    function completeExchange(bytes32 exchangeId) public onlyParty(exchangeId) {
        Exchange storage exchange = exchanges[exchangeId];
        require(exchange.status == ExchangeStatus.Funded, "Exchange not fully funded");
        require(exchange.party1Funded && exchange.party2Funded, "Both parties must fund");
        
        exchange.status = ExchangeStatus.Completed;
        
        // Transfer funds to respective parties
        if (exchange.party1Amount > 0) {
            payable(exchange.party2).transfer(exchange.party1Amount);
        }
        if (exchange.party2Amount > 0) {
            payable(exchange.party1).transfer(exchange.party2Amount);
        }
        
        escrowBalances[exchangeId] = 0;
        emit ExchangeCompleted(exchangeId);
    }
    
    /**
     * @dev Cancel an exchange (only if not funded or by authority)
     */
    function cancelExchange(bytes32 exchangeId) public {
        Exchange storage exchange = exchanges[exchangeId];
        require(
            msg.sender == scrollVerseAuthority || 
            (exchange.status == ExchangeStatus.Created && (msg.sender == exchange.party1 || msg.sender == exchange.party2)),
            "Not authorized to cancel"
        );
        
        exchange.status = ExchangeStatus.Cancelled;
        
        // Refund any funded amounts
        if (exchange.party1Funded && exchange.party1Amount > 0) {
            payable(exchange.party1).transfer(exchange.party1Amount);
        }
        if (exchange.party2Funded && exchange.party2Amount > 0) {
            payable(exchange.party2).transfer(exchange.party2Amount);
        }
        
        escrowBalances[exchangeId] = 0;
        emit ExchangeCancelled(exchangeId);
    }
    
    /**
     * @dev Raise a dispute on an exchange
     */
    function raiseDispute(bytes32 exchangeId, string memory reason) public onlyParty(exchangeId) returns (bytes32) {
        Exchange storage exchange = exchanges[exchangeId];
        require(exchange.status == ExchangeStatus.Funded, "Exchange must be funded to dispute");
        
        bytes32 disputeId = keccak256(abi.encodePacked(exchangeId, msg.sender, block.timestamp));
        
        disputes[disputeId] = Dispute({
            exchangeId: exchangeId,
            initiator: msg.sender,
            reason: reason,
            resolved: false,
            winner: address(0),
            createdAt: block.timestamp
        });
        
        exchange.status = ExchangeStatus.Disputed;
        emit DisputeRaised(disputeId, exchangeId, msg.sender);
        
        return disputeId;
    }
    
    /**
     * @dev Resolve a dispute (authority only)
     */
    function resolveDispute(bytes32 disputeId, address winner) public onlyAuthority {
        Dispute storage dispute = disputes[disputeId];
        require(!dispute.resolved, "Dispute already resolved");
        
        Exchange storage exchange = exchanges[dispute.exchangeId];
        require(winner == exchange.party1 || winner == exchange.party2, "Winner must be a party to the exchange");
        
        dispute.resolved = true;
        dispute.winner = winner;
        exchange.status = ExchangeStatus.Resolved;
        
        // Calculate fee
        uint256 totalAmount = exchange.party1Amount + exchange.party2Amount;
        uint256 fee = (totalAmount * disputeResolutionFee) / 10000;
        uint256 winnerAmount = totalAmount - fee;
        
        // Transfer amounts
        payable(winner).transfer(winnerAmount);
        payable(scrollVerseAuthority).transfer(fee);
        
        escrowBalances[dispute.exchangeId] = 0;
        emit DisputeResolved(disputeId, winner);
    }
    
    /**
     * @dev Get exchange details
     */
    function getExchange(bytes32 exchangeId) public view returns (Exchange memory) {
        return exchanges[exchangeId];
    }
    
    /**
     * @dev Update dispute resolution fee (authority only)
     */
    function updateDisputeResolutionFee(uint256 newFee) public onlyAuthority {
        require(newFee <= 500, "Fee cannot exceed 5%");
        disputeResolutionFee = newFee;
    }
}
