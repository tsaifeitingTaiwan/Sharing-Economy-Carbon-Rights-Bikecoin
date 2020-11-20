
const BikeCoin = artifacts.require("BikeCoin");

module.exports = function(deployer) {
  deployer.deploy(BikeCoin);
};
