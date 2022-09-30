//SPDX-License-Identifier: KK
pragma solidity 0.8.13;


contract KKING_Locker {
    // time until locked
    uint public locked_until;
    address public ownerz;
    address public lpToken;

    event lockTimeUpdated (uint newUnlock);
    event withdrawz(uint amount);
    event lockerCreated(address indexed owner, address indexed tokenLocked, uint lockUntil);

    constructor(uint _locked_until, address own, address lpA) {
        locked_until = _locked_until;
        ownerz = own;
        lpToken = lpA;
        emit lockerCreated(own, lpA, _locked_until);
    }
    modifier onlyOwnerz{
        require(msg.sender == ownerz, "you are not the owner");
        _;
    }
    // update timer once it's over
    function updateLock(uint _newTime) external onlyOwnerz {
        require(locked_until <= _newTime && _newTime>block.timestamp,"new date cannot be in the past");
        locked_until = _newTime;
        emit lockTimeUpdated(_newTime);
    } 
    // withdraw if timer is expired
    function withdraw() public onlyOwnerz {
        require(block.timestamp > locked_until,"You cannot withdraw yet. (Time)");
        uint256 balance = BEPz20(lpToken).balanceOf(address(this));
        require(balance > 0,"This token is not there.");
		require(BEPz20(lpToken).transfer(ownerz, balance),"transfer error.");
        emit withdrawz(balance);
    }
}
abstract contract BEPz20 {
    function balanceOf(address tokenOwner) virtual external view returns (uint256);
    function transfer(address receiver, uint256 numTokens) virtual public returns (bool);
}
