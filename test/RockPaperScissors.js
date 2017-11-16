const RockPaperScissors = artifacts.require("./RockPaperScissors.sol");


contract('RockPaperScissors', accounts => {
	let owner = accounts[0];
	let Alice = accounts[1];
	let Bob = accounts[2];
    let ante = 8000000000000000;

    beforeEach(() => {
        return RockPaperScissors.new(Alice, Bob, ante, { from: owner }).then(_instance => {
            instance = _instance;	
        })
    });

    it("should be owned by owner", () => {
        return instance.owner({from: owner}).then(_owner => {
            assert.strictEqual(_owner, owner, "Contract is not owned by owner");
        }) 
    });

    it("should let Alice or Bob play", () => {
        return instance.play(1, {from: Alice, value: 8000000000000000}).then((txObj) => {
            assert.equal(txObj.logs[0].args.play.toString(10), "1", "Player's hand wasn't registered or interpreted correctly");
        })
    });

    it("should decide the match fairly", () => {
        return instance.play(1, {from: Alice, value: 8000000000000000}).then(() => {
            return instance.play(3, {from: Bob, value: 8000000000000000})
        }).then((txObj) => {
            assert.equal(txObj.logs[1].args.gameOutcome.toString(10), "3", "referee() is not being fair");
            assert.equal(txObj.logs[1].args.AlicesWinnings.toString(10), "0", "error with contract accounting");
            assert.equal(txObj.logs[1].args.BobsWinnings.toString(10), "16000000000000000", "error with contract accounting");
        })    
    })

    it("should allow a player to withdraw their winnings", () => {
        let startBalance;
        let winnings;
        let gasPrice;
        let gasUsed;
        let txFee;
        let endBalance;
        startBalance = web3.eth.getBalance(Bob);
        console.log("startBalance: " + startBalance.toString(10));
        return instance.play(1, {from: Alice, value: 8000000000000000}
        ).then(() => {
            return instance.play(3, {from: Bob, value: 8000000000000000})
        }).then(() => {
            return instance.withdraw({from: Bob})          
        }).then(txObj => {
            gasUsed = txObj.receipt.gasUsed;
            winnings = txObj.logs[0].args.amount
            console.log("Winnings: " + winnings.toString(10));
            return web3.eth.getTransaction(txObj.tx, (err, tx) => {
                gasPrice = tx.gasPrice;
                txFee = gasPrice.times(gasUsed);
                endBalance = web3.eth.getBalance(
                Bob);
                console.log("gasUsed: " + gasUsed);
                console.log("gasPrice: " + gasPrice);
                console.log("txFee: " + txFee.toString(10)); 
                console.log("endBalance: " + endBalance.toString(10));
                console.log("delta: " + endBalance.minus(startBalance).toString(10));
                assert.equal(startBalance.plus(winnings).minus(txFee).toString(10), endBalance.toString(10), "Bob didn't get his ether")
            })       
        })

    })
})




// web3.eth.getTransactionReceipt(transactionHash, function(err, transaction) {
//     console.info(transaction);    
//   })