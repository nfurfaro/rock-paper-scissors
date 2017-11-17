pragma solidity ^0.4.6;


contract Owned {

    address public owner;

    event LogNewOwner(address oldowner, address newOwner);

    modifier onlyOwner() {
        require(msg.sender == owner);
        _;
    }

    function Owned() {
    	owner = msg.sender;
    }

    function changeOwner(address newOwner)
        onlyOwner
        returns (bool success) 
    {
    	require(newOwner != 0);
    	LogNewOwner(owner, newOwner);
    	owner = newOwner;
    	return true;
    }

}