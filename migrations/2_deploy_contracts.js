var RockPaperScissors = artifacts.require("./RockPaperScissors.sol");



module.exports = function(deployer, network, accounts) {
	let anteAmount = 10;
    let _Alice = accounts[0];
    let _Bob = accounts[1];
    
    deployer.deploy(RockPaperScissors, _Alice, _Bob, anteAmount);
};

