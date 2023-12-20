// SPDX-License-Identifier: MIT

import "@openzeppelin/contracts/access/Ownable.sol";

pragma solidity 0.8.22;

interface IProfile{
    struct UserProfile{
        string displayName;
        string bio;
    }
    function getProfile (address _user) external view returns (UserProfile memory);
}

contract Twitter is Ownable{

    uint16 public MAX_LENGTH = 280;

    struct Tweet{
        uint256 id;
        address author;
        string content;
        uint256 timestamp;
        uint256 likes;
    }


    mapping(address => Tweet[]) public tweets;

    // profile contract
    IProfile profileContract;

    event tweetCreated(uint256 id, address author, string content, uint256 timestamp);
    event tweetLiked(address liker, address tweetAuthor, uint256 tweetID, uint256 newLikeCount);
    event tweetUnliked(address unliker, address tweetAuthor, uint256 tweetID, uint256 newLikeCount);

    constructor(address _profileContract) Ownable(msg.sender) {
        profileContract = IProfile(_profileContract);
    }

    modifier onlyRegistered(){
        IProfile.UserProfile memory UserProfileTemp = profileContract.getProfile(msg.sender);
        require(bytes(UserProfileTemp.displayName).length>0, "User not registered");
        _;
    }

    function createTweet(string memory _tweet) public onlyRegistered{

        require(bytes(_tweet).length <= MAX_LENGTH, "Tweet is too long");

        Tweet memory newTweet = Tweet({
            id: tweets[msg.sender].length,
            author: msg.sender,
            content: _tweet,
            timestamp: block.timestamp,
            likes: 0
        });
        tweets[msg.sender].push(newTweet);

        emit tweetCreated(newTweet.id, newTweet.author, newTweet.content, newTweet.timestamp);
    }

    function likeTweet(address author, uint256 id) external onlyRegistered{
        require(tweets[author][id].id == id, "Tweet does not exist");

        tweets[author][id].likes++;

        emit tweetLiked(msg.sender, author, id, tweets[author][id].likes);
    }

    function unlikeTweet(address author, uint256 id) external onlyRegistered{
        require(tweets[author][id].id == id, "Tweet does not exist");
        require(tweets[author][id].likes>0, "0 likes");

        tweets[author][id].likes--;

        emit tweetUnliked(msg.sender, author, id, tweets[author][id].likes);
    }

    function getTweet(uint _i) public view returns(Tweet memory){
        return tweets[msg.sender][_i];
    }

    function getAllTweets(address _owner) public view returns(Tweet[] memory){
        return tweets[_owner];
    }

    function changeTweetLength(uint16 newLength) public onlyOwner{
        MAX_LENGTH = newLength;
    }

    function getTotalLikes(address author) external view returns(uint256){
        Tweet[] memory arr = tweets[author];
        uint256 sum=0;
        for(uint i=0; i<arr.length; i++)
        {
            sum += arr[i].likes;
        }
        return sum;
    }

}