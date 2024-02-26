import { HardhatUserConfig } from 'hardhat/config';
import { HardhatNetworkUserConfig } from 'hardhat/types';
import '@nomicfoundation/hardhat-toolbox';
import 'hardhat-contract-sizer';
import { config } from 'dotenv';

const { MNEMONIC, INFURA_ID_PROJECT } = config().parsed || {};

const EVM_VERSION = 'paris';

const hardhatConfig: HardhatUserConfig = {
  solidity: {
    version: '0.8.20',
    settings: {
      evmVersion: EVM_VERSION,
      optimizer: {
        enabled: true,
        runs: 1_000_000,
      },
      metadata: {
        bytecodeHash: 'none',
      },
    },
  },
  networks: {
    hardhat: {
      allowUnlimitedContractSize: true,
    } as HardhatNetworkUserConfig,
    localGeth: {
      url: `http://127.0.0.1:8545`,
      chainId: 1337,
      gas: 10000000,
    },
    mainnet: {
      url: `https://mainnet.infura.io/v3/${INFURA_ID_PROJECT}`,
      accounts: [`0x${MNEMONIC || '1000000000000000000000000000000000000000000000000000000000000000'}`],
    },
  },
};

export default hardhatConfig;
