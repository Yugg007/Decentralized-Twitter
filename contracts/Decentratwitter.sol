//SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "hardhat/console.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";

contract Decentratwitter is ERC721URIStorage {
    uint256 public tokenCount;
    uint256 public postCount;
    mapping(uint256 => Post) public posts;
    mapping(address => uint256) public profiles;            // address --> nft id

    struct Post {
        uint256 id;
        string hash;
        uint256 tipAmount;
        address payable author;
    }

    event PostCreated(
        uint256 id,
        string hash,
        uint256 tipAmount,
        address payable author
    );

    event PostTipped(
        uint256 id,
        string hash,
        uint256 tipAmount,
        address payable author
    );

    constructor() ERC721("Decentratwitter", "DAPP") {}              //constructor call for base call and for inhertence class also.


    //Set tokenCount as nftId and tokenURI as ipfsHash(cid)
    function mint(string memory _tokenURI) external returns (uint256) {
        tokenCount++;
        _safeMint(msg.sender, tokenCount);
        _setTokenURI(tokenCount, _tokenURI);
        setProfile(tokenCount);
        return (tokenCount);
    }

    //Set address -> NFT
    function setProfile(uint256 _id) public {
        require(
            ownerOf(_id) == msg.sender,
            "Must own the nft you want to select as your profile"
        );
        profiles[msg.sender] = _id;
    }


    function uploadPost(string memory _postHash) external {

        require(balanceOf(msg.sender) > 0, "Must own a decentratwitter nft to post" );      // Check that the user owns an nft
        require(bytes(_postHash).length > 0, "Cannot pass an empty hash");      // Make sure the post hash exists

        postCount++;

        posts[postCount] = Post(postCount, _postHash, 0, payable(msg.sender));        // Add post to the contract
        emit PostCreated(postCount, _postHash, 0, payable(msg.sender));        // Trigger an event
    }

    function tipPostOwner(uint256 _id) external payable {

        require(_id > 0 && _id <= postCount, "Invalid post id");        // Make sure the id is valid

        Post memory _post = posts[_id];
        require(_post.author != msg.sender, "Cannot tip your own post");

        _post.author.transfer(msg.value);        // Pay the author by sending them Ether
        _post.tipAmount += msg.value;        // Increment the tip amount
        posts[_id] = _post;        // Update the image
        emit PostTipped(_id, _post.hash, _post.tipAmount, _post.author);        // Trigger an event
    }


    function getAllPosts() external view returns (Post[] memory _posts) {
        _posts = new Post[](postCount);
        for (uint256 i = 0; i < _posts.length; i++) {
            _posts[i] = posts[i + 1];
        }
    }


    function getMyNfts() external view returns (uint256[] memory _ids) {
        _ids = new uint256[](balanceOf(msg.sender));
        uint256 currentIndex;
        uint256 _tokenCount = tokenCount;
        for (uint256 i = 0; i < _tokenCount; i++) {
            if (ownerOf(i + 1) == msg.sender) {
                _ids[currentIndex] = i + 1;
                currentIndex++;
            }
        }
    }
}
