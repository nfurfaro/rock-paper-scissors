pragma solidity ^0.4.6;

import "./Owned.sol";

contract Freezable is Owned {
    
    bool public frozen;

    event LogFreeze(address sender, bool isFrozen);

    modifier freezeRay() {
        require(!frozen);
        _;
    }

    function freeze(bool _freeze)
        onlyOwner
        returns (bool success) {
            frozen = _freeze;
            LogFreeze(msg.sender, frozen);
            return true;
    }
}