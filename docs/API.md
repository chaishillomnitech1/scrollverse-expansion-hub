# ScrollVerse Expansion Hub - API Documentation

## Overview
The ScrollVerse Expansion Hub provides a comprehensive API for interacting with the sovereign omniversal economy. This documentation covers all smart contracts and their public interfaces.

---

## 1. NFT Minting Contract (ScrollVerseNFT)

### Contract Address
*To be deployed*

### Functions

#### `mintNFT(address to, string memory uri) → uint256`
Mint a new NFT to the specified address.

**Parameters:**
- `to`: Address to receive the NFT
- `uri`: Metadata URI for the NFT (IPFS hash or URL)

**Returns:**
- `tokenId`: The ID of the newly minted token

**Events:**
- `NFTMinted(address indexed creator, uint256 indexed tokenId, string uri)`
- `Transfer(address indexed from, address indexed to, uint256 indexed tokenId)`

#### `ownerOf(uint256 tokenId) → address`
Get the owner of a specific token.

#### `balanceOf(address owner) → uint256`
Get the number of tokens owned by an address.

#### `tokenURI(uint256 tokenId) → string`
Get the metadata URI for a token.

#### `totalSupply() → uint256`
Get the total number of minted tokens.

#### `transfer(address to, uint256 tokenId)`
Transfer a token to another address.

---

## 2. Crypto Gateway Contract (ScrollVerseCryptoGateway)

### Functions

#### `deposit() payable`
Deposit cryptocurrency to your gateway balance.

**Events:**
- `Deposit(address indexed user, uint256 amount)`

#### `withdraw(uint256 amount)`
Withdraw funds from your gateway balance.

**Events:**
- `Withdrawal(address indexed user, uint256 amount)`

#### `initiatePayment(address payee, uint256 amount, string memory currency) → bytes32`
Create a new payment transaction.

**Parameters:**
- `payee`: Recipient address
- `amount`: Payment amount
- `currency`: Currency identifier (e.g., "ETH", "USDC")

**Returns:**
- `paymentId`: Unique payment identifier

**Events:**
- `PaymentInitiated(bytes32 indexed paymentId, address indexed payer, address indexed payee, uint256 amount)`

#### `completePayment(bytes32 paymentId)`
Finalize a payment transaction.

**Events:**
- `PaymentCompleted(bytes32 indexed paymentId)`

#### `getBalance(address user) → uint256`
Check the balance of a user.

---

## 3. Marketplace Contract (ScrollVerseMarketplace)

### Functions

#### `listItem(address nftContract, uint256 tokenId, uint256 price) → bytes32`
List an NFT for sale on the marketplace.

**Parameters:**
- `nftContract`: Address of the NFT contract
- `tokenId`: Token ID to list
- `price`: Listing price in wei

**Returns:**
- `listingId`: Unique listing identifier

**Events:**
- `ItemListed(bytes32 indexed listingId, address indexed seller, address nftContract, uint256 tokenId, uint256 price)`

#### `buyItem(bytes32 listingId) payable`
Purchase a listed item.

**Events:**
- `ItemSold(bytes32 indexed listingId, address indexed buyer, uint256 price)`

#### `cancelListing(bytes32 listingId)`
Cancel an active listing (seller only).

**Events:**
- `ListingCancelled(bytes32 indexed listingId)`

#### `makeOffer(bytes32 listingId) payable`
Make an offer on a listed item.

**Events:**
- `OfferMade(bytes32 indexed listingId, address indexed buyer, uint256 amount)`

#### `acceptOffer(bytes32 listingId, address buyer)`
Accept an offer (seller only).

**Events:**
- `OfferAccepted(bytes32 indexed listingId, address indexed buyer, uint256 amount)`

#### `withdrawEarnings()`
Withdraw marketplace earnings.

---

## 4. Digital Bank Contract (ScrollVerseDigitalBank)

### Functions

#### `depositFunds() payable`
Deposit funds to the bank.

**Events:**
- `Deposit(address indexed user, uint256 amount)`

#### `withdrawFunds(uint256 amount)`
Withdraw funds from the bank.

**Events:**
- `Withdrawal(address indexed user, uint256 amount)`

#### `requestLoan(uint256 principal, uint256 durationDays) payable → bytes32`
Request a loan with collateral (150% minimum).

**Parameters:**
- `principal`: Loan amount
- `durationDays`: Loan duration in days

**Returns:**
- `loanId`: Unique loan identifier

**Events:**
- `LoanIssued(bytes32 indexed loanId, address indexed borrower, uint256 principal, uint256 collateral)`

#### `repayLoan(bytes32 loanId) payable`
Repay a loan with interest.

**Events:**
- `LoanRepaid(bytes32 indexed loanId, address indexed borrower, uint256 amount)`

#### `purchaseInsurance(uint256 coverage, uint256 durationDays) payable → bytes32`
Purchase insurance coverage.

**Parameters:**
- `coverage`: Coverage amount
- `durationDays`: Policy duration in days

**Returns:**
- `policyId`: Unique policy identifier

**Events:**
- `InsurancePurchased(bytes32 indexed policyId, address indexed holder, uint256 coverage)`

#### `getDepositBalance(address user) → uint256`
Check deposit balance.

---

## 5. Fair Exchange Contract (ScrollVerseFairExchange)

### Functions

#### `createExchange(address party2, uint256 party1Amount, uint256 party2Amount, string memory description) → bytes32`
Create a new fair exchange agreement.

**Parameters:**
- `party2`: Second party address
- `party1Amount`: Amount party1 will provide
- `party2Amount`: Amount party2 will provide
- `description`: Exchange description

**Returns:**
- `exchangeId`: Unique exchange identifier

**Events:**
- `ExchangeCreated(bytes32 indexed exchangeId, address indexed party1, address indexed party2)`

#### `fundExchange(bytes32 exchangeId) payable`
Fund your side of the exchange (escrow).

**Events:**
- `ExchangeFunded(bytes32 indexed exchangeId, address indexed party, uint256 amount)`

#### `completeExchange(bytes32 exchangeId)`
Complete an exchange (both parties must agree).

**Events:**
- `ExchangeCompleted(bytes32 indexed exchangeId)`

#### `cancelExchange(bytes32 exchangeId)`
Cancel an exchange.

**Events:**
- `ExchangeCancelled(bytes32 indexed exchangeId)`

#### `raiseDispute(bytes32 exchangeId, string memory reason) → bytes32`
Raise a dispute on an exchange.

**Returns:**
- `disputeId`: Unique dispute identifier

**Events:**
- `DisputeRaised(bytes32 indexed disputeId, bytes32 indexed exchangeId, address indexed initiator)`

---

## Fee Structure

- **Marketplace Fee**: 2.5% (adjustable by authority)
- **Loan Interest Rate**: 5% (adjustable by authority)
- **Insurance Premium**: 1% per year (adjustable by authority)
- **Dispute Resolution Fee**: 0.5% (adjustable by authority)

---

## Security Considerations

1. **Collateralization**: Loans require 150% collateral
2. **Escrow Protection**: Fair exchange uses escrow mechanisms
3. **Authority Control**: Certain functions restricted to ScrollVerse Authority
4. **Time-based Validation**: Insurance and loan duration tracking
5. **Dispute Resolution**: Transparent dispute handling by authority

---

## Integration Guide

### Web3.js Example

```javascript
const Web3 = require('web3');
const web3 = new Web3('YOUR_RPC_URL');

// Load contract
const nftContract = new web3.eth.Contract(NFT_ABI, NFT_ADDRESS);

// Mint an NFT
const mint = async (toAddress, uri) => {
  const accounts = await web3.eth.getAccounts();
  const result = await nftContract.methods
    .mintNFT(toAddress, uri)
    .send({ from: accounts[0] });
  
  console.log('Token minted:', result.events.NFTMinted.returnValues.tokenId);
};
```

### Ethers.js Example

```javascript
const { ethers } = require('ethers');

// Connect to provider
const provider = new ethers.providers.JsonRpcProvider('YOUR_RPC_URL');
const signer = provider.getSigner();

// Load contract
const nftContract = new ethers.Contract(NFT_ADDRESS, NFT_ABI, signer);

// Mint an NFT
const mint = async (toAddress, uri) => {
  const tx = await nftContract.mintNFT(toAddress, uri);
  const receipt = await tx.wait();
  console.log('Transaction confirmed:', receipt.transactionHash);
};
```

---

## Support

For questions or support, please refer to ScrollVerse documentation or contact the ScrollVerse Authority.
