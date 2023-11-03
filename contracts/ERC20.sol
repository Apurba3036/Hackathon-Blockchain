// SPDX-License-Identifier: MIT
pragma solidity >=0.8.19 <=0.8.20;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";
//The contract imports two external Solidity files from OpenZeppelin's GitHub repository:ERC20.sol and Ownable.sol. 
//These files contain predefined contract code for ERC-20 tokens and a basic access control contract.
 
 
 contract TheodoresToken is ERC20("Theodores Token", "TT"){
    //Here TheodoresToken takes two arguments : token name and token symbol
    address public manager;
    IERC20 _token;

    address payable[] public buyers;
    
     constructor(){
        manager=msg.sender;    //constructor save the address of the owner
    }
    function mintFifty() public  {
        require(msg.sender==manager,"Only owner can access it"); //It checks whether the sender (the caller of the function) is the manager, and if not, it reverts with an "Only owner can access it" error message.
        _mint(msg.sender, 50 * 10**18);  //mintFifty Function: This function allows the manager to mint 50 tokens and transfer them to themselves.
    }
    

     function getbalance() public  view returns(uint)
    {    
        require(msg.sender==manager, "You are not the owner");
        return  _token.balanceOf(address(this));
    }
    
    function buytoknes() public payable {

       
        require(msg.value==2 ether,"Please pay 2 ether to buy token");
       
        address payable  buyer=payable(msg.sender);
        uint256 tokentobuy= getbalance()/10 ether;
        buyer.transfer(tokentobuy);
        buyers.push(payable (buyer));
        
    }

   

}


contract Community is TheodoresToken{

    struct Communitycreate{
         
         address creator;
         string title;
         string description;
         
    }

    Communitycreate public sc;
    address payable  public Owner;
    address payable [] public nativebuyers;

    function  tocheckbuyer(string memory name,string memory descript ) public{

          for (uint256 i = 0; i < buyers.length; i++) {
            if (buyers[i] == msg.sender) {
                sc.creator=buyers[i]; 
                sc.title=name;
                sc.description=descript;    
            }
        }
    }


   function native() public  {
        require(msg.sender==manager,"Only owner can access it"); //It checks whether the sender (the caller of the function) is the manager, and if not, it reverts with an "Only owner can access it" error message.
        _mint(msg.sender, 20 * 10**18);  //mintFifty Function: This function allows the manager to mint 50 tokens and transfer them to themselves.
    }


      function balance() public  view returns(uint)
    {    
        require(msg.sender==manager, "You are not the owner");
        return  _token.balanceOf(address(this));
    }

       function buytoknen() public payable {

       
        require(msg.value==2 ether,"Please pay 2 ether to buy token");
       
        address payable  nativebuyer=payable(msg.sender);
        uint256 tobuy= balance()/10 ether;
        nativebuyer.transfer(tobuy);
        nativebuyers.push(payable (nativebuyer));
        
    }



     
    function destroy() public {
        require(Owner ==msg.sender,"You can not change");
        selfdestruct(Owner);
    }
    
}


contract CommunityProducts {
    struct Product {
        address owner;
        string title;
        string category; // "exclusive" or "general"
        uint256 likes;
        uint256 dislikes;
    }

    Product[] public products;
    mapping(address => uint256[]) public userProducts;

    event ProductPublished(address indexed owner, uint256 indexed productId, string title, string category);
    event VoteCasted(address indexed voter, uint256 indexed productId, bool liked);

    function publishProduct(string memory _title, string memory _category) public {
        require(bytes(_title).length > 0, "Title cannot be empty");
        require(bytes(_category).length > 0, "Category cannot be empty");
        require(keccak256(abi.encodePacked(_category)) == keccak256(abi.encodePacked("exclusive")) || keccak256(abi.encodePacked(_category)) == keccak256(abi.encodePacked("general")), "Invalid category");

        uint256 productId = products.length;
        products.push(Product(msg.sender, _title, _category, 0, 0));
        userProducts[msg.sender].push(productId);

        emit ProductPublished(msg.sender, productId, _title, _category);
    }

    function getProductsCount() public view returns (uint256) {
        return products.length;
    }

    function getProduct(uint256 _productId) public view returns (Product memory) {
        require(_productId < products.length, "Invalid product ID");
        return products[_productId];
    }
}

contract CommunityVoting {
    CommunityProducts public productsContract;
    event VoteCasted(address indexed voter, uint256 indexed productId, bool liked);
    constructor(address _productsContract) {
        productsContract = CommunityProducts(_productsContract);
    }

    function vote(uint256 _productId, bool _liked) public {
        require(_productId < productsContract.getProductsCount(), "Invalid product ID");
       
        CommunityProducts.Product memory product = productsContract.getProduct(_productId);
        require(product.owner != msg.sender, "You cannot vote on your own product");

        if (_liked) {
            product.likes +=1;
        } else {
            product.dislikes +=1;
        }

        emit VoteCasted(msg.sender, _productId, _liked);
    }
}



contract Auction {
    address payable  public owner;
    string public productName;
    uint256 public startPrice;
    uint256 public priceDecrement;
    uint256 public minimumPrice;
    uint256 public auctionEndTime;

    address public highestBidder;
    uint256 public highestBid;

    bool public auctionEnded;

    event NewBid(address indexed bidder, uint256 amount);
    event AuctionEnded(address winner, uint256 amount);

    constructor(
        string memory _productName,
        uint256 _startPrice,
        uint256 _priceDecrement,
        uint256 _minimumPrice,
        uint256 _durationMinutes
    ) {
        owner = payable (msg.sender);
        productName = _productName;
        startPrice = _startPrice;
        priceDecrement = _priceDecrement;
        minimumPrice = _minimumPrice;
        auctionEndTime = block.timestamp + (_durationMinutes * 1 minutes);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action");
        _;
    }

    modifier auctionNotEnded() {
        require(!auctionEnded, "The auction has already ended");
        _;
    }

    function getCurrentPrice() public view returns (uint256) {
        uint256 timeRemaining = (auctionEndTime > block.timestamp) ? auctionEndTime - block.timestamp : 0;
        uint256 timeElapsed = (block.timestamp > auctionEndTime) ? block.timestamp - auctionEndTime : 0;
        uint256 price = startPrice - (priceDecrement * (timeElapsed / 1 minutes));
        return (price < minimumPrice) ? minimumPrice : price;
    }

    function placeBid() public payable auctionNotEnded {
        require(msg.value > 0, "Bid amount must be greater than 0");
        uint256 currentPrice = getCurrentPrice();
        require(msg.value >= currentPrice, "Bid amount is less than the current price");
        
        if (msg.value > highestBid) {
            highestBidder = msg.sender;
            highestBid = msg.value;
        }

        emit NewBid(msg.sender, msg.value);
    }

    function endAuction() public onlyOwner auctionNotEnded {
        require(block.timestamp >= auctionEndTime, "Auction time has not yet ended");
        
        auctionEnded = true;

        if (highestBidder != address(0)) {
            owner.transfer(highestBid);
            emit AuctionEnded(highestBidder, highestBid);
        }
    }

    // Function to retrieve any remaining funds from the contract (after the auction ends)
    function withdrawFunds() public onlyOwner {
        require(auctionEnded, "Auction must have ended");
        require(highestBidder == address(0), "Funds can only be withdrawn if there's no winner");
        payable(owner).transfer(address(this).balance);
    }
}










