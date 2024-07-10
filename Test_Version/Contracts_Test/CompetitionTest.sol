// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;
//13 April re-edit

interface IERC721 {
    // checking ownership
    function ownerOf(uint256 tokenId) external view returns (address owner);
}
interface IReward { 
    //person
    function transfer(address to, uint amount) external returns (bool);
    function claim() external;
}
contract Competition {
    string[] public topics = [ "News", "Freestyle","Animal"];// hot topics 
    uint256 public currentTermId; // Current active term ID
    IReward public tokenTrader;
    uint256 public initialStartTime; // Track the start time of the first term

    // Each term has its own id, topic and NFTlist for the term
    struct CompetitionTerm {
        uint256 id;
        string topic;
        address[] currentNFTList; // Track all NFTs that have been voted for in this term
    }
    // top layer
    mapping(uint256 => CompetitionTerm) public terms;
    // Mapping from termId => (nftAddress => voteCount)
    mapping(uint256 => mapping(address => uint256)) public votes; 
    // one vote max from one user for each NFT
    // termId => (nftAddress => (userAddress => hasVoted))
    mapping(uint256 => mapping(address => mapping(address => bool))) public hasVoted; 

    
    // nftAddress => tokenId
    // for futre check in ownership
    mapping(address => uint)public NFT_ID;
    
    constructor( ) {
        tokenTrader = IReward(0x1923AD9F3448A502810508eb7C78eD37bAD763fe);// reward token contract
        tokenTrader.claim(); // this contract should hold all the tokens
        initialStartTime = block.timestamp; // Set the initial time
        
        startNewTerm(); // Initialize the first term
    }


    function startNewTerm() private { // can be accessed only from this contract
        currentTermId++;
        uint256 topicIndex = currentTermId % topics.length;
        CompetitionTerm storage term = terms[currentTermId];
        term.id = currentTermId;
        term.topic = topics[topicIndex];
    }

    event VoteNotification(address indexed voter, address indexed nftAddress, uint256 termId);
    function vote( address nftAddress) external  {
        bool exists = false;
        for(uint i = 0; i < terms[currentTermId].currentNFTList.length; i++) {
            if(terms[currentTermId].currentNFTList[i] == nftAddress) {
                exists = true;
                break;
            }
        }
        require(exists,"You voted for a not exist nft");
        require(!hasVoted[currentTermId][nftAddress][msg.sender], "You have already voted for this NFT.");

        votes[currentTermId][nftAddress]++;
        hasVoted[currentTermId][nftAddress][msg.sender] = true;
        emit VoteNotification(msg.sender, nftAddress,currentTermId);// vote notification

    }

    event NFTPublishNotification(address indexed nftAddress, uint256 tokenId, uint256 termId);
    function publish(address nftAddress,uint tokenId)external  {// can only publish to current termID
        require(isOwner(nftAddress, tokenId, msg.sender), "Caller is not the owner of the NFT");
        NFT_ID[nftAddress] = tokenId;
        // Check if this NFT address is already in the currentNFTList array to avoid duplicates
        
        bool exists = false;
        for(uint i = 0; i < terms[currentTermId].currentNFTList.length; i++) {
            if(terms[currentTermId].currentNFTList[i] == nftAddress) {
                exists = true;
                require(!exists,"NFT already exist");
                break;
            }
        }
        if(!exists) {// can publish
            terms[currentTermId].currentNFTList.push(nftAddress);
            emit NFTPublishNotification(nftAddress, tokenId, currentTermId);
        }

    }

    function determineWinners(uint256 _termId) public view returns (address[3] memory winners, uint256[3] memory votesCount) {
        for (uint i = 0; i < terms[_termId].currentNFTList.length; i++) {
            address nftAddress = terms[_termId].currentNFTList[i];
            uint256 voteCount = votes[_termId][nftAddress];
            // Logic to track top 3 addresses and their vote counts
            for(uint j = 0; j < 3; j++) {
                if(voteCount > votesCount[j]) {
                    // Check from first place
                    for(uint k = 2; k > j; k--) {
                        // Move one place back
                        winners[k] = winners[k-1];
                        votesCount[k] = votesCount[k-1];
                    }
                    winners[j] = nftAddress;
                    votesCount[j] = voteCount;
                    break;
                }
            }
        }
    }
         
    event TermEndNotification(uint256 termId, string topic);
    event TermStartNotification(uint256 termId, string topic);
    event RewardNotification(address indexed recipient, uint256 amount, uint256 termId);
    function endTerm() external  {
        uint256 termPeriod = 12 minutes;
        uint256 expectedEndTime = initialStartTime + currentTermId*termPeriod;
        require(block.timestamp >= expectedEndTime,"Deadline has not passed deadline is calculated by expectedEndTime = initialStartTime + currentTermId*termPeriod");
        // Deadline passed
        address[3] memory winners;
        (winners,)=determineWinners(currentTermId);
        uint[] memory rewardAmounts = new uint[](3);
        rewardAmounts[0] = 5 * 10**6; // Reward for 1st
        rewardAmounts[1] = 3 * 10**6; // Reward for 2nd
        rewardAmounts[2] = 2 * 10**6; // Reward for 3rd
        address owner;
        
        for (uint i = 0; i < winners.length; i++) {
            if(winners[i]!=address(0)){
                owner = IERC721(winners[i]).ownerOf(NFT_ID[winners[i]]);
                if(owner != address(0)) {
                tokenTrader.transfer(owner, rewardAmounts[i]);
                emit RewardNotification(owner, rewardAmounts[i], currentTermId);
            }
            }
             
            
        }
        emit TermEndNotification(currentTermId, terms[currentTermId].topic);
        startNewTerm();
        // Reward the good heart people for ending the term
        // effect interaction rule applied
        tokenTrader.transfer(msg.sender, 1 * 10**6);
        emit TermStartNotification(currentTermId, terms[currentTermId].topic);
    }
    
    function isOwner(address nftContract, uint256 tokenId, address owner) public view returns (bool) {
        //use ERC721 interface to check the ownership of the nft
        address currentOwner = IERC721(nftContract).ownerOf(tokenId);
        return currentOwner == owner;
    }

    
    function getCurrentTermNFTs() external  view returns (address[] memory) {
        // Function to retrieve the list of all NFTs for the current term
        return terms[currentTermId].currentNFTList;
    }
    function getTermNFTs(uint256 _termId) external  view returns (address[] memory) {
        // Function to retrieve the list of all NFTs for the specific term
        return terms[_termId].currentNFTList;
    }
    
    function getNFTVoteCount(uint256 _termId, address nftAddress) external  view returns (uint256) {
        return votes[_termId][nftAddress];
    }
    function GetCurrentTopNFT(uint256 _termId) external  view returns (address[3] memory winners, uint256[3] memory votesCount) {
        //same as determine winners
        for (uint i = 0; i < terms[_termId].currentNFTList.length; i++) {
            address nftAddress = terms[_termId].currentNFTList[i];
            uint256 voteCount = votes[_termId][nftAddress];
            
            // Logic to track top 3 addresses and their vote counts
            for(uint j = 0; j < 3; j++) {
                if(voteCount > votesCount[j]) {
                    // Check from first place
                    for(uint k = 2; k > j; k--) {
                        // Move one place back
                        winners[k] = winners[k-1];
                        votesCount[k] = votesCount[k-1];
                    }
                    winners[j] = nftAddress;
                    votesCount[j] = voteCount;
                    break;
                }
            }
        }
    }


}