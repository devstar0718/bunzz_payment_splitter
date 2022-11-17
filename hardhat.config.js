/**
 * @type import('hardhat/config').HardhatUserConfig
 */
require("@nomiclabs/hardhat-waffle");

module.exports = {
  solidity: {
    compilers: [
      {
        version: "0.8.0",
        settings: {
          optimizer: {
            enabled: true,
            runs: 200,
          },
        },
      },
    ],
    settings: {
      outputSelection: {
        "*": {
          "*": ["storageLayout"],
        },
      },
    },
  },
};
