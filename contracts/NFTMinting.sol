// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

/**
 * @title ScrollVerse NFT Minting Contract
 * @dev Implementation of NFT minting for the ScrollVerse Expansion Hub
 * This contract enables creators to mint NFTs while adhering to ScrollVerse laws and codices
 */
contract ScrollVerseNFT {
    // Token storage
    mapping(uint256 => address) private _owners;
    mapping(address => uint256) private _balances;
    mapping(uint256 => string) private _tokenURIs;
    mapping(uint256 => bool) private _exists;
    
    // Metadata and governance
    uint256 private _tokenIdCounter;
    string public name = "ScrollVerse NFT";
    string public symbol = "SVNFT";
    address public scrollVerseAuthority;
    
    // Events
    event NFTMinted(address indexed creator, uint256 indexed tokenId, string uri);
    event Transfer(address indexed from, address indexed to, uint256 indexed tokenId);
    event ApprovalForAll(address indexed owner, address indexed operator, bool approved);
    
    // Modifiers
    modifier onlyAuthority() {
        require(msg.sender == scrollVerseAuthority, "Only ScrollVerse Authority can execute");
        _;
    }
    
    modifier tokenExists(uint256 tokenId) {
        require(_exists[tokenId], "Token does not exist");
        _;
    }
    
    constructor() {
        scrollVerseAuthority = msg.sender;
    }
    
    /**
     * @dev Mint a new NFT
     * @param to Address to receive the NFT
     * @param uri Metadata URI for the NFT
     * @return tokenId The ID of the newly minted token
     */
    function mintNFT(address to, string memory uri) public returns (uint256) {
        require(to != address(0), "Cannot mint to zero address");
        
        uint256 tokenId = _tokenIdCounter;
        _tokenIdCounter++;
        
        _owners[tokenId] = to;
        _balances[to]++;
        _tokenURIs[tokenId] = uri;
        _exists[tokenId] = true;
        
        emit NFTMinted(to, tokenId, uri);
        emit Transfer(address(0), to, tokenId);
        
        return tokenId;
    }
    
    /**
     * @dev Get the owner of a token
     */
    function ownerOf(uint256 tokenId) public view tokenExists(tokenId) returns (address) {
        return _owners[tokenId];
    }
    
    /**
     * @dev Get the balance of an address
     */
    function balanceOf(address owner) public view returns (uint256) {
        require(owner != address(0), "Address zero is not a valid owner");
        return _balances[owner];
    }
    
    /**
     * @dev Get token URI
     */
    function tokenURI(uint256 tokenId) public view tokenExists(tokenId) returns (string memory) {
        return _tokenURIs[tokenId];
    }
    
    /**
     * @dev Get total supply
     */
    function totalSupply() public view returns (uint256) {
        return _tokenIdCounter;
    }
    
    /**
     * @dev Transfer token (simplified version)
     */
    function transfer(address to, uint256 tokenId) public tokenExists(tokenId) {
        require(ownerOf(tokenId) == msg.sender, "Not token owner");
        require(to != address(0), "Cannot transfer to zero address");
        
        _balances[msg.sender]--;
        _balances[to]++;
        _owners[tokenId] = to;
        
        emit Transfer(msg.sender, to, tokenId);
    }
}
