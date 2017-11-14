const RockPaperScissors = artifacts.require("./RockPaperScissors.sol");
const chai = require('chai');
const assert = chai.assert;
const chaiAsPromised = require('chai-as-promised');
chai.use(chaiAsPromised);
const Promise = require("bluebird");


contract('RockPaperScissors', accounts => {
	let owner = accounts[0];
	let Alice = accounts[1];
	let Bob = accounts[2];

    beforeEach(() => {
        return RockPaperScissors.new({ from: owner }).then(_instance => {
            instance = _instance;	
        })
    });

    it("should be owned by owner", () => {
  	    return assert.eventually.strictEqual(Promise.resolve(instance.owner({from: owner})), owner, "Contract is not owned by owner");
    });

    it("should let Alice or Bob play", () => {
        instance.play(1, {from: Alice, value: 10}).then((txObj) => {
            console.log(txObj.logs[1].args);
        return assert.eventually.equal(Promise.resolve(txObj.logs[0].args.play.toString(10)), "1", "Player's hand wasn't registered or interpreted correctly");
        })
    });

    it("should decide the match fairly", () => {
        instance.play(1, {from: Alice, value: 10}).then(() => {
            return instance.play(3, {from: Bob, value: 10})
        }).then((txObj) => {
            console.log(txObj)
            // assert.equal(txObj.logs[0].args.play.toString(10), "1", "Player's hand wasn't registered or interpreted correctly");
        })    
    })

    
})
