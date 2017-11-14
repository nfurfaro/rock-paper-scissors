pragma solidity ^0.4.6;


contract RockPaperScissors {
    address public owner;
    address public player;
    address public Alice;
    address public Bob;
    uint public ante;
    uint public playersReady;
    uint public gameStatus;


    struct PlayerData {
        uint winnings;
        uint hand;
    }

    mapping(address => PlayerData) contestants; 
    
    event LogPlay(address player, uint deposit,  string codes, uint play);
    event LogGameState(uint _playersReady, uint balance, string codes, uint _gameStatus);
    event LogWinnings(string alices, uint amount1, string bobs, uint amount2);
    event LogWithdrawl(address withdrawer, uint amount);

    function RockPaperScissors()
        public
    {
        owner = msg.sender;
        //remix
        // Alice = 0x14723a09acff6d2a60dcdf7aa4aff308fddc160c;
        // Bob = 0x4b0897b0513fdc7c541b6d9d7e929c4e5364d2db;
        //testrpc
        Alice = 0xa653157c9f2b34263f456953fd85de0211ce40e3;
        Bob = 0xd996973097a0290ea7b025a5ad48863884c3bc30;
        // ante = _anteAmount;
        ante = 10;
    }

    modifier isAliceOrBob() {
        require(msg.sender == Alice || msg.sender == Bob);
        _;
    }

    modifier meetsRequirements() {
        require(msg.value == ante);
        require(contestants[msg.sender].hand == 0);
        _;
    }

    function play(uint _hand)
        isAliceOrBob
        meetsRequirements 
        public 
        payable 
        returns (bool hasPlayed)
    {
        require(_hand != 0);
        if(playersReady == 0) {
            playersReady++;
            contestants[msg.sender].hand = _hand;
            LogPlay(msg.sender, msg.value, "(1 = rock, 2 = paper, 3 = scissors)", _hand);
            LogGameState(playersReady, this.balance, "(For Alice:  0 = undecided, 1 = Lose , 2 = draw, 3 = win)",  gameStatus);
            return true;
        } else if(playersReady == 1) {
            playersReady++;
            contestants[msg.sender].hand = _hand;
            LogPlay(msg.sender, msg.value, "(1 = rock, 2 = paper, 3 = scissors)", _hand);
            referee();
            LogGameState(playersReady, this.balance, "(For Alice:  0 = undecided, 1 = Lose , 2 = draw, 3 = win)",  gameStatus);
            playersReady = 0;
            contestants[Alice].hand = 0;
            contestants[Bob].hand = 0;
            if(gameStatus == 2) {
                gameStatus = 0;
                contestants[Alice].winnings += ante;
                contestants[Bob].winnings += ante;
                LogWinnings("Alice's winnings:", contestants[Alice].winnings, "Bob's winnings:", contestants[Bob].winnings);
                return true;
            } else {
                gameStatus = 0;
                contestants[msg.sender].winnings += ante * 2;
                LogWinnings("Alice's winnings:", contestants[Alice].winnings, "Bob's winnings:", contestants[Bob].winnings);
                return true;
            }
        }

    } 
    
    function withdraw()
        isAliceOrBob
        public
        returns (bool success)
    {
        require(contestants[msg.sender].winnings != 0);
        uint amount = contestants[msg.sender].winnings;
        LogWithdrawl(msg.sender, amount);
        msg.sender.transfer(amount);
        return true;
    }
   
    function referee() 
        internal 
    {
        require(playersReady == 2);
        uint A = contestants[Alice].hand;
        uint B = contestants[Bob].hand;
        if(A == 1) {
            if(B == 1) gameStatus = 2;
            if(B == 2) gameStatus = 1;
            if(B == 3) gameStatus = 3;
        } else if(A == 2) {
            if(B == 2) gameStatus = 2;
            if(B == 3) gameStatus = 1;
            if(B == 1) gameStatus = 3;
        } else if(A == 3) {
            if(B == 3) gameStatus = 2;
            if(B == 1) gameStatus = 1;
            if(B == 2) gameStatus = 3;
        }
    }

    function getLogs() public {
        LogGameState(playersReady, this.balance, "(For Alice:  0 = undecided, 1 = Lose , 2 = draw, 3 = win)",  gameStatus);
        LogWinnings("Alice's winnings:", contestants[Alice].winnings, "Bob's winnings:", contestants[Bob].winnings);
    }
}