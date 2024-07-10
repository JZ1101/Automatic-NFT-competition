// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

interface IERC20 {
    function transfer(address to, uint amount) external returns (bool);
}


contract ArtReward {
    uint public totalSupply  ;
    string public name ="GoodArtist";
    string public symbol ="GA";
    uint256 public claimed;//bool is more expensive
    uint256 public decimals = 6;// same as USDT
    mapping(address=>uint256) public Balance;
    event Transfer(address _sender,address _receiver,uint256 _amount);
    event TokensClaimed(address claimedAddress, uint256 amount);
    function balanceOf(address a) external view returns(uint b){
        b = Balance[a];
    }
    constructor(){
            /*
            First:5 tokens
            Second: 3 tokens
            Third: 2 tokens
            Maintainor: 1 token
            Topic rolling every week, 52 weeks per year
            572 token per year
            */
        totalSupply = 572 * (10 **  decimals );
        claimed = 0;
        
    }
    
    function claim() public{
        require(claimed==0,"Tokens have already been claimed.");
        Balance[msg.sender]=totalSupply;
        claimed+=1;
        emit TokensClaimed(msg.sender, totalSupply);
    }

    function transfer(address _receiver,uint _amount) public returns(bool success){
        require(Balance[msg.sender]>_amount,"Insufficient balance.");
        Balance[msg.sender] -=_amount;
        Balance[_receiver]+=_amount;
        emit Transfer(msg.sender,_receiver,_amount);
        success = true;
        
    }
}