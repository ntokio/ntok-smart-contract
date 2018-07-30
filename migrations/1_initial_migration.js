var A = artifacts.require("./Migrations.sol");
var B = artifacts.require("./TutorNinjaToken.sol");

module.exports = function(deployer) {
    deployer.deploy(A).then(function() {
      return deployer.deploy(B);
    });
};