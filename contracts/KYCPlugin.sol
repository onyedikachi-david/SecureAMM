// SPDX-License-Identifier: GPL-2.0-or-later
pragma solidity ^0.8.4;

import {AlgebraPlugin, IAlgebraPlugin} from './base/AlgebraPlugin.sol';
import {IAlgebraPool} from '@cryptoalgebra/integral-core/contracts/interfaces/IAlgebraPool.sol';
import {PoolInteraction} from './libraries/PoolInteraction.sol';
import {PluginConfig, Plugins} from './types/PluginConfig.sol';

import './proof-of-identity/interfaces/IProofOfIdentity.sol';


contract KYCPlugin is AlgebraPlugin {
    error onlyPoolAllowed();
	event POIAddressUpdated(address indexed poiAddress);

	// ERRORS
	error WrongPOI__ZeroAddress();

	/**
	 * @notice Error to throw when an account does not have a Proof of Identity
	 * NFT.
	 */
	error KYC__NoIdentityNFT();

	/**
	 * @notice Error to throw when an account is suspended.
	 */
	error KYC__Suspended();

    PluginConfig private constant _defaultPluginConfig = PluginConfig.wrap(0); // does nothing

    /// @notice the Algebra Integral pool
    IAlgebraPool public immutable pool;

	IProofOfIdentity private _proofOfIdentity;


    modifier onlyPool() {
        _checkOnlyPool();
        _;
    }

    modifier onlyPermissioned(address account) {
		if (!_hasID(account)) revert KYC__NoIdentityNFT();

		if (!_isSuspended(account)) revert KYC__Suspended();

		// _checkUserTypeExn(account);
		_;
	}

    constructor(address _pool, address proofOfIdentity_) {
        pool = IAlgebraPool(_pool);
        _setPOIAddress(proofOfIdentity_);
    }

    function defaultPluginConfig() external pure override returns (uint8 pluginConfig) {
        return _defaultPluginConfig.unwrap();
    }

    /// @inheritdoc IAlgebraPlugin
    function beforeInitialize(address sender, uint160 sqrtPriceX96) external onlyPool returns (bytes4) {
        sender; // suppress warning
        sqrtPriceX96; //suppress warning

        PoolInteraction.changePluginConfigIfNeeded(pool, _defaultPluginConfig);
        return IAlgebraPlugin.beforeInitialize.selector;
	}
  function beforeSwap(address, address, bool, int256, uint160, bool, bytes calldata) external override onlyPool returns (bytes4) {
    // _writeTimepointAndUpdateFee();
    return IAlgebraPlugin.beforeSwap.selector;
  }
    /**
	 * @notice Sets the Proof of Identity contract address.
	 * @param poi The address for the Proof of Identity contract.
	 * @dev May revert with:
	 *  /^AccessControl: account (0x[0-9a-f]{40}) is missing role (0x[0-9a-f]{64})$/
	 * May revert with `WrongPOI__ZeroAddress`.
	 * May emit a `POIAddressUpdated` event.
	 */
	function _setPOIAddress(address poi) private {
		if (poi == address(0)) revert WrongPOI__ZeroAddress();
		_proofOfIdentity = IProofOfIdentity(poi);
		emit POIAddressUpdated(poi);
	}

	/**
	 * @notice Validates that a given `expiry` is greater than the current
	 * `block.timestamp`.
	 *
	 * @param expiry The expiry to check.
	 *
	 * @return True if the expiry is greater than the current timestamp, false
	 * otherwise.
	 */
	function _validateExpiry(uint256 expiry) private view returns (bool) {
		return expiry > block.timestamp;
	}

	/**
	 * @notice Returns whether an account holds a Proof of Identity NFT.
	 * @param account The account to check.
	 * @return True if the account holds a Proof of Identity NFT, else false.
	 */
	function _hasID(address account) private view returns (bool) {
		return _proofOfIdentity.balanceOf(account) > 0;
	}

	/**
	 * @notice Returns whether an account is suspended.
	 * @param account The account to check.
	 * @return True if the account is suspended, false otherwise.
	 */
	function _isSuspended(address account) private view returns (bool) {
		return _proofOfIdentity.isSuspended(account);
	}

    function _checkOnlyPool() internal view {
        if (msg.sender != address(pool)) revert onlyPoolAllowed();
    }
}
