var A = artifacts.require("./Migrations.sol");
var B = artifacts.require("./NTOKTokenContract.sol");

module.exports = function(deployer) {
    deployer.deploy(A).then(function() {
      return deployer.deploy(B);
    });
};