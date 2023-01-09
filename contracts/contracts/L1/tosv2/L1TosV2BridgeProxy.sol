// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import { BaseProxy } from "../../proxy/BaseProxy.sol";
import { CrossDomainEnabledStorage } from "./CrossDomainEnabledStorage.sol";
import { L1TosV2BridgeStorage } from "./L1TosV2BridgeStorage.sol";


import { IL2ERC20Bridge } from "../../L2/messaging/IL2ERC20Bridge.sol";
import { ICrossDomainMessenger } from "../../libraries/bridge/ICrossDomainMessenger.sol";

// import { SafeERC20 } from "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";

import { Lib_PredeployAddresses } from "../../libraries/constants/Lib_PredeployAddresses.sol";

/**
 * @title L1TosV2BridgeProxy
 * @dev
 *
 */
contract L1TosV2BridgeProxy is CrossDomainEnabledStorage, BaseProxy, L1TosV2BridgeStorage {
    // using SafeERC20 for IERC20;

    /**********
     * Events *
     **********/
    event ETHDepositInitiated(
        address indexed _from,
        address indexed _to,
        uint256 _amount,
        bytes _data
    );

    /***************
     * Constructor *
     ***************/

    // This contract lives behind a proxy, so the constructor parameters will go unused.
    constructor() {
        messenger = address(0);
    }

    receive() external payable override onlyEOA nonZeroAddress(l2TosV2Treasury) {
         _initiateETHDeposit(msg.sender, l2TosV2Treasury, 200_000, bytes(""));
    }

    /**
     * @dev Performs the logic for deposits by storing the ETH and informing the L2 ETH Gateway of
     * the deposit.
     * @param _from Account to pull the deposit from on L1.
     * @param _to Account to give the deposit to on L2.
     * @param _l2Gas Gas limit required to complete the deposit on L2.
     * @param _data Optional data to forward to L2. This data is provided
     *        solely as a convenience for external contracts. Aside from enforcing a maximum
     *        length, these contracts provide no guarantees about its content.
     */
    function _initiateETHDeposit(
        address _from,
        address _to,
        uint32 _l2Gas,
        bytes memory _data
    ) internal {
        // Construct calldata for finalizeDeposit call
        bytes memory message = abi.encodeWithSelector(
            IL2ERC20Bridge.finalizeDeposit.selector,
            address(0),
            Lib_PredeployAddresses.OVM_ETH,
            _from,
            _to,
            msg.value,
            _data
        );

        // Send calldata into L2
        // slither-disable-next-line reentrancy-events
        ICrossDomainMessenger(messenger).sendMessage(l2TosV2Bridge, message, _l2Gas);

        // slither-disable-next-line reentrancy-events
        emit ETHDepositInitiated(_from, _to, msg.value, _data);
    }
}
