var RockPaperScissors = artifacts.require("./RockPaperScissors.sol");

// let anteAmount = 10;

// module.exports = function(deployer) {
//   deployer.deploy(RockPaperScissors, anteAmount);
// };

module.exports = function(deployer) {
  deployer.deploy(RockPaperScissors);
};
