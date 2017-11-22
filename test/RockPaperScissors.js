const RockPaperScissors = artifacts.require("./RockPaperScissors.sol");
const PromisifyWeb3 = require("./promisifyWeb3.js");
// const web3.utils = require("web3.utils");
PromisifyWeb3.promisify(web3);
// const Promise = require("bluebird");

contract('RockPaperScissors', accounts => {
	let owner = accounts[0];
	let Alice = accounts[1];
	let Bob = accounts[2];
    let ante = 8000000000000000;

    beforeEach(() => {
        return RockPaperScissors.new(Alice, Bob, ante, { from: owner })
            .then(_instance => {
                instance = _instance;	
            })
    });

    it("should be owned by owner", () => {
        return instance.owner({from: owner})
            .then(_owner => {
                assert.strictEqual(_owner, owner, "Contract is not owned by owner");
        }) 
    });

    it("should return a correctly-hashed hand", () => {
        let hand = 1;
        return instance.handHasher.call(hand, {from: Alice})
            .then(_hash => {
                assert.strictEqual(_hash, "0x5fe7f977e71dba2ea1a68e21057beebb9be2ac30c6410aa38d4f3fbe41dcffd2", "Player's hand wasn't hashed or returned correctly");
            })
    });

    it("should let owner freeze all key functions", () => {
        return instance.freeze(true, {from: owner})
            .then(() => {
                return instance.frozen()
            })
            .then(_frozen => {
                assert.strictEqual(_frozen.toString(10), "true", "the freezeRay is not working!")
            })
    })

    it("should decide the match fairly", () => {
        return instance.referee.call(1, 1)
            .then(returnValue => {
                assert.strictEqual(returnValue.toString(10), "2", "referee() is not being fair");
            })    
    })

    it("should decide the match fairly", () => {
        return instance.referee.call(3, 3)
            .then(returnValue => {
                assert.strictEqual(returnValue.toString(10), "2", "referee() is not being fair");
            })    
    }) 

    it("should decide the match fairly", () => {
        return instance.referee.call(1, 2)
            .then(returnValue => {
                assert.strictEqual(returnValue.toString(10), "1", "referee() is not being fair");
            })    
    })

    it("should decide the match fairly", () => {
        return instance.referee.call(1, 3)
            .then(returnValue => {
                assert.strictEqual(returnValue.toString(10), "3", "referee() is not being fair");
            })    
    })

    it("should decide the match fairly", () => {
        return instance.referee.call(2, 3)
            .then(returnValue => {
                assert.strictEqual(returnValue.toString(10), "1", "referee() is not being fair");
            })    
    })

    // it("should allow a player to withdraw their winnings", async() => {
    //     let startBalance;
    //     let winnings;
    //     let gasPrice;
    //     let gasUsed;
    //     let txFee;
    //     let endBalance;
    //     let testAmount = 8000000000000000
    //     let secretA = "subway tile bespoke skateboard salvia"
    //     let secretB = "poke thundercats vegan tousled gluten"
    //     let hashedPlayA = web3.sha3(secretA, 1);
    //     let hashedPlayB = web3.sha3(secretB, 3);
    //     console.log(hashedPlayA);
    //     console.log(hashedPlayB);
    //     startBalance = await web3.eth.getBalance(Bob);
    //     await instance.playSecretHand(hashedPlayA, {from: Alice, value: testAmount});
    //     await instance.playSecretHand(hashedPlayB, {from: Bob, value: testAmount});
    //     txObj = await instance.withdraw({from: Bob});         
    //     gasUsed = txObj.receipt.gasUsed;
    //     winnings = txObj.logs[0].args.amount;
    //     tx = await web3.eth.getTransactionPromiseMined(txObj.tx);
    //     console.log(tx);
    //     gasPrice = tx.gasPrice;
    //     txFee = gasPrice.times(gasUsed);
    //     endBalance = await web3.eth.getBalancePromise(Bob)
    //     console.log("startBal: " + web3.fromWei(startBalance, "ether").toString(10));
    //     console.log("Winnings: " + web3.fromWei(winnings, "ether").toString(10));
    //     console.log("gasUsed: " + web3.fromWei(gasUsed, "ether").toString(10));
    //     console.log("gasPrice: " + web3.fromWei(gasPrice, "ether").toString(10));
    //     console.log("txFee: " + web3.fromWei(txFee, "ether").toString(10));
    //     console.log("endBalance: " + web3.fromWei(endBalance, "ether").toString(10));
    //     return instance.contestants.call(0, {from: Bob})
    //     .then(_data => {
    //         console.log(_data);
    //         // assert.strictEqual(_funds[0].toString(10), "0", "players hand should have been set to 0");
    //         // assert.strictEqual(_funds[1].toString(10), "0", "players winnings should have been set to 0");
    //         assert.strictEqual(startBalance.plus(winnings).minus(txFee).toString(10), endBalance.toString(10), "Bob didn't get his ether")
    //         })
    // })
})

