pragma solidity ^0.4.6;

import "./Freezable.sol";

contract RockPaperScissors is Freezable {
    address public Alice;
    address public Bob;
    uint public ante;
    uint8 public playsSubmitted;
    uint8 public validHandsRevealed;
    bool public safeToRevealHands;

    struct PlayerData {
        uint winnings;
        uint8 revealedHand;
        bytes32 hashedHand;    
    }


    mapping(address => PlayerData) public contestants; 
    
    event LogPlay(uint8 _playsSubmitted, address player, uint deposit, bytes32 _hashedHand, bool _safeToRevealHands);
    event logReveal(address player, uint8 revealedHand);
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

    function playSecretHand(bytes32 _hashedHand)
        freezeRay
        isAliceOrBob 
        public 
        payable 
        returns (bool hasPlayed)
    {   
        require(msg.value == ante);
        require(contestants[msg.sender].hashedHand == keccak256([0]));
        require(_hashedHand != 0);
        require(_hashedHand < 4);
        require(playsSubmitted <= 1);
        uint8 gameStatus;
        uint stakes;
        stakes += msg.value;
        if(playsSubmitted == 0) {
            playsSubmitted++;
            contestants[msg.sender].hashedHand = _hashedHand;
            LogPlay(playsSubmitted, msg.sender, msg.value, _hashedHand, safeToRevealHands);
            return true;
        } else if(playsSubmitted == 1) {
            contestants[msg.sender].hashedHand = _hashedHand;
            playsSubmitted++;
            safeToRevealHands = true;
            LogPlay(playsSubmitted, msg.sender, msg.value, _hashedHand, safeToRevealHands);
            // require(validateRevealedHand());
            require(validHandsRevealed == 2);
            gameStatus = referee(contestants[Alice].revealedHand, contestants[Bob].revealedHand);
            safeToRevealHands = false;
            LogOutcome(gameStatus);
            require(gameStatus != 0);
            playsSubmitted = 0;
            contestants[Alice].hashedHand = keccak256([0]);
            contestants[Bob].hashedHand = keccak256([0]);
            if(gameStatus == 2) {
                contestants[Alice].winnings += stakes / 2;
                contestants[Bob].winnings += stakes / 2;
                gameStatus = 0;
                return true;
            } else {
                contestants[msg.sender].winnings += stakes * 2;
                gameStatus = 0;
                return true;
            }
        }

    } 
    
    function revealHand(uint8 _hand, string _secret)
        public
        freezeRay
        isAliceOrBob
        returns (bool validHand) 
    {
        require(safeToRevealHands == true);
        bytes32 newHash = keccak256(_hand, _secret);
        require(newHash == contestants[msg.sender].hashedHand); 
            if(validHandsRevealed == 0) {
                contestants[msg.sender].revealedHand = _hand;
                validHandsRevealed++;
                logReveal(msg.sender, _hand);
                return true;
            } else if (validHandsRevealed == 1) {
                contestants[msg.sender].revealedHand = _hand;
                validHandsRevealed++;
                logReveal(msg.sender, _hand);
                return true;
            } else return false;  
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
 