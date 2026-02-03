// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ScrollVerse Marketplace
 * @dev Artifact-driven open marketplace for trading NFTs and digital assets
 * Implements fair exchange systems and price discovery mechanisms
 */
contract ScrollVerseMarketplace {
    address public scrollVerseAuthority;
    uint256 public marketplaceFee = 25; // 2.5% fee in basis points
    
    struct Listing {
        address seller;
        address nftContract;
        uint256 tokenId;
        uint256 price;
        bool active;
        uint256 listedAt;
    }
    
    struct Offer {
        address buyer;
        uint256 amount;
        bool active;
        uint256 offeredAt;
    }
    
    // Listings and offers
    mapping(bytes32 => Listing) public listings;
    mapping(bytes32 => mapping(address => Offer)) public offers;
    mapping(address => uint256) public earnings;
    
    // Events
    event ItemListed(bytes32 indexed listingId, address indexed seller, address nftContract, uint256 tokenId, uint256 price);
    event ItemSold(bytes32 indexed listingId, address indexed buyer, uint256 price);
    event ListingCancelled(bytes32 indexed listingId);
    event OfferMade(bytes32 indexed listingId, address indexed buyer, uint256 amount);
    event OfferAccepted(bytes32 indexed listingId, address indexed buyer, uint256 amount);
    
    modifier onlyAuthority() {
        require(msg.sender == scrollVerseAuthority, "Only ScrollVerse Authority can execute");
        _;
    }
    
    constructor() {
        scrollVerseAuthority = msg.sender;
    }
    
    /**
     * @dev List an item for sale
     */
    function listItem(address nftContract, uint256 tokenId, uint256 price) public returns (bytes32) {
        require(price > 0, "Price must be greater than 0");
        
        bytes32 listingId = keccak256(abi.encodePacked(nftContract, tokenId, msg.sender, block.timestamp));
        
        listings[listingId] = Listing({
            seller: msg.sender,
            nftContract: nftContract,
            tokenId: tokenId,
            price: price,
            active: true,
            listedAt: block.timestamp
        });
        
        emit ItemListed(listingId, msg.sender, nftContract, tokenId, price);
        return listingId;
    }
    
    /**
     * @dev Buy an item
     */
    function buyItem(bytes32 listingId) public payable {
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing not active");
        require(msg.value >= listing.price, "Insufficient payment");
        
        uint256 fee = (listing.price * marketplaceFee) / 10000;
        uint256 sellerAmount = listing.price - fee;
        
        listing.active = false;
        earnings[listing.seller] += sellerAmount;
        earnings[scrollVerseAuthority] += fee;
        
        emit ItemSold(listingId, msg.sender, listing.price);
        
        // Refund excess payment
        if (msg.value > listing.price) {
            payable(msg.sender).transfer(msg.value - listing.price);
        }
    }
    
    /**
     * @dev Cancel a listing
     */
    function cancelListing(bytes32 listingId) public {
        Listing storage listing = listings[listingId];
        require(listing.seller == msg.sender, "Only seller can cancel");
        require(listing.active, "Listing not active");
        
        listing.active = false;
        emit ListingCancelled(listingId);
    }
    
    /**
     * @dev Make an offer on a listing
     */
    function makeOffer(bytes32 listingId) public payable {
        require(msg.value > 0, "Offer must be greater than 0");
        Listing storage listing = listings[listingId];
        require(listing.active, "Listing not active");
        
        offers[listingId][msg.sender] = Offer({
            buyer: msg.sender,
            amount: msg.value,
            active: true,
            offeredAt: block.timestamp
        });
        
        emit OfferMade(listingId, msg.sender, msg.value);
    }
    
    /**
     * @dev Accept an offer
     */
    function acceptOffer(bytes32 listingId, address buyer) public {
        Listing storage listing = listings[listingId];
        require(listing.seller == msg.sender, "Only seller can accept offer");
        require(listing.active, "Listing not active");
        
        Offer storage offer = offers[listingId][buyer];
        require(offer.active, "Offer not active");
        
        uint256 fee = (offer.amount * marketplaceFee) / 10000;
        uint256 sellerAmount = offer.amount - fee;
        
        listing.active = false;
        offer.active = false;
        earnings[listing.seller] += sellerAmount;
        earnings[scrollVerseAuthority] += fee;
        
        emit OfferAccepted(listingId, buyer, offer.amount);
    }
    
    /**
     * @dev Withdraw earnings
     */
    function withdrawEarnings() public {
        uint256 amount = earnings[msg.sender];
        require(amount > 0, "No earnings to withdraw");
        
        earnings[msg.sender] = 0;
        payable(msg.sender).transfer(amount);
    }
    
    /**
     * @dev Update marketplace fee (authority only)
     */
    function updateMarketplaceFee(uint256 newFee) public onlyAuthority {
        require(newFee <= 1000, "Fee cannot exceed 10%");
        marketplaceFee = newFee;
    }
}
