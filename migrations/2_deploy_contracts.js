var RockPaperScissors = artifacts.require("./RockPaperScissors.sol");

let anteAmount = 10;
let _Alice = 0xa653157c9f2b34263f456953fd85de0211ce40e3;
let _Bob = 0xd996973097a0290ea7b025a5ad48863884c3bc30;

module.exports = function(deployer, network, accounts) {
  deployer.deploy(RockPaperScissors, _Alice, _Bob, anteAmount);
};

