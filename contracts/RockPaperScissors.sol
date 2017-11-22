pragma solidity ^0.4.6;

import "./Freezable.sol";

contract RockPaperScissors is Freezable {
    address public Alice;
    address public Bob;
    uint public ante;
    uint8 public hashedHandsPlayed;
    uint8 public validHandsRevealed;
    uint8 gameStatus;
    uint stakes;


    struct PlayerData {
        uint winnings;
        uint8 revealedHand;
        bytes32 hashedHand;   
    }


    mapping(address => PlayerData) public contestants; 
    
    event LogPlay(uint8 _hashedHandsPlayed, address player, uint deposit, bytes32 _hashedHand);
    event logRevealedHand(address player, uint8 revealedHand);
    event LogOutcome(uint8 outcome);
    event LogWithdrawl(address withdrawer, uint amount);


    function RockPaperScissors(address _Alice, address _Bob, uint _anteAmount)
        public
    {
        ante = _anteAmount;
        Alice = _Alice;
        Bob = _Bob;
    }

    modifier isAliceOrBob() {
        require(msg.sender == Alice || msg.sender == Bob);
        _;
    }

    function handHasher(uint8 _hand)
        public
        pure
        returns(bytes32 hashedHand)
    {    
        require(_hand != 0);
        require(_hand < 4);
        return keccak256(_hand);
    }

    // input value is output from handHasher(), sent from the client.
    function playSecretHand(bytes32 _hashedHand)
        freezeRay
        isAliceOrBob 
        public 
        payable 
        returns (bool hasPlayed)
    {
        require(msg.value == ante);
        require(contestants[msg.sender].hashedHand == bytes32(0));
        require(hashedHandsPlayed <= 1);
        stakes += msg.value;
        if(hashedHandsPlayed == 0) {
            hashedHandsPlayed++;
            contestants[msg.sender].hashedHand = _hashedHand;
            LogPlay(hashedHandsPlayed, msg.sender, msg.value, _hashedHand);
            return true;
        } else if(hashedHandsPlayed == 1) {
            contestants[msg.sender].hashedHand = _hashedHand;
            hashedHandsPlayed++;
            // client can listen for `hashedHandsPlayed == 2` before enabling proveHand() step.
            LogPlay(hashedHandsPlayed, msg.sender, msg.value, _hashedHand);
            return true;
            } else return false;
    }

    function proveHand(uint8 _nakedHand)
        public
        freezeRay
        isAliceOrBob
        returns (bool validHand)
    {
        require(hashedHandsPlayed == 2);
        require(contestants[msg.sender].revealedHand == 0);
        if(keccak256(_nakedHand) == contestants[msg.sender].hashedHand) {
            contestants[msg.sender].revealedHand = _nakedHand;
            validHandsRevealed++;
            // switch to if, don't want it to throw if this is first player to reveal!
            require(validHandsRevealed == 2);
            gameController();
            logRevealedHand(msg.sender, _nakedHand);
            return true;
        } else 
            if(msg.sender == Alice) {
                gameStatus = 1;
                return false;
            } else if(msg.sender == Bob) {
                gameStatus = 3;
                return false;
            } else return false;
    }

    function gameController()
        freezeRay
        internal
        returns (bool success)
    {
        if(validHandsRevealed != 2) {
            return false;
        } else {
            gameStatus = referee(contestants[Alice].revealedHand, contestants[Bob].revealedHand);
            validHandsRevealed = 0;
            LogOutcome(gameStatus);
            hashedHandsPlayed = 0;
            contestants[Alice].hashedHand = bytes32(0);
            contestants[Bob].hashedHand = bytes32(0);
            if(gameStatus == 1) {
                contestants[Bob].winnings += stakes * 2;
                gameStatus = 0;
                return true;
            } else if(gameStatus == 2) {
                contestants[Alice].winnings += stakes / 2;
                contestants[Bob].winnings += stakes / 2;
                gameStatus = 0;
                return true;
            } else if(gameStatus == 3) {
                contestants[Alice].winnings += stakes * 2;
                gameStatus = 0;
                return true;    
            } else return false;
        }
    }

   // For Alice:  0 = undecided, 1 = Lose , 2 = draw, 3 = win
   // 1 = rock, 2 = paper, 3 = scissors
    function referee(uint8 A, uint8 B)
        public
        pure
        returns (uint8 returnValue) 
    {
        
        if(A == 1) {
            if(B == 1) return 2;
            if(B == 2) return 1;
            if(B == 3) return 3;
        } else if(A == 2) {
            if(B == 2) return 2;
            if(B == 3) return 1;
            if(B == 1) return 3;
        } else if(A == 3) {
            if(B == 3) return 2;
            if(B == 1) return 1;
            if(B == 2) return 3;
        } else {
            return 0;
        }
    }

    function withdraw()
        freezeRay
        public
        returns (bool success)
    {
        require(contestants[msg.sender].winnings != 0);
        uint amount = contestants[msg.sender].winnings;
        contestants[msg.sender].winnings = 0;
        msg.sender.transfer(amount);
        LogWithdrawl(msg.sender, amount);
        return true;
    }
}
 