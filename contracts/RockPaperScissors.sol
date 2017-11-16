pragma solidity ^0.4.6;


contract RockPaperScissors {
    bool public frozen;
    address public owner;
    address public Alice;
    address public Bob;
    uint public ante;
    uint public playersReady;
    // uint public gameStatus;


    struct PlayerData {
        uint winnings;
        uint hand;
    }

    mapping(address => PlayerData) contestants; 
    
    event LogPlay(address player, uint deposit, uint play);
    event LogGameOver(uint gameOutcome, uint AlicesWinnings, uint BobsWinnings);
    event LogWithdrawl(address withdrawer, uint amount);
    event LogFreeze(bool isFrozen);

    function RockPaperScissors(address _Alice, address _Bob, uint _anteAmount)
        public
    {
        owner = msg.sender;
        ante = _anteAmount;
        Alice = _Alice;
        Bob = _Bob;
    }

    modifier isAliceOrBob() {
        require(msg.sender == Alice || msg.sender == Bob);
        _;
    }

    modifier freezeRay() {
        require(!frozen);
        _;
    }

    function play(uint _hand)
        freezeRay
        isAliceOrBob 
        public 
        payable 
        returns (bool hasPlayed)
    {
        require(msg.value == ante);
        require(contestants[msg.sender].hand == 0);
        require(_hand != 0);
        require(_hand < 4);
        require(playersReady <= 1);
        uint gameStatus;
        uint stakes;
        stakes += msg.value;
        if(playersReady == 0) {
            playersReady++;
            contestants[msg.sender].hand = _hand;
            LogPlay(msg.sender, msg.value, _hand);
            return true;
        } else if(playersReady == 1) {
            playersReady++;
            contestants[msg.sender].hand = _hand;
            LogPlay(msg.sender, msg.value, _hand);
            gameStatus = referee();
            require(gameStatus != 0);
            playersReady = 0;
            contestants[Alice].hand = 0;
            contestants[Bob].hand = 0;
            if(gameStatus == 2) {
                contestants[Alice].winnings += stakes / 2;
                contestants[Bob].winnings += stakes / 2;
                LogGameOver(gameStatus, contestants[Alice].winnings, contestants[Bob].winnings);
                gameStatus = 0;
                return true;
            } else {
                contestants[msg.sender].winnings += stakes * 2;
                LogGameOver(gameStatus, contestants[Alice].winnings, contestants[Bob].winnings);
                gameStatus = 0;
                return true;
            }
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
   
   // For Alice:  0 = undecided, 1 = Lose , 2 = draw, 3 = win
   // 1 = rock, 2 = paper, 3 = scissors
    function referee()
        public
        constant
        returns (uint returnValue) 
    {
        require(playersReady == 2);
        uint A = contestants[Alice].hand;
        uint B = contestants[Bob].hand;
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

    function freezerSwitch(bool _freeze)
        returns (bool success) {
            require(msg.sender == owner);
            frozen = _freeze;
            LogFreeze(frozen);
            return true;
    }
}