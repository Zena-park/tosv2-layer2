// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import { ICrossDomainMessenger } from "../../libraries/bridge/ICrossDomainMessenger.sol";

contract CrossDomainEnabledStorage {

    /*************
     * Variables *
     *************/

    // Messenger contract used to send and recieve messages from the other domain.
    address public messenger;

    /**
     * Enforces that the modified function is only callable by a specific cross-domain account.
     * @param _sourceDomainAccount The only account on the originating domain which is
     *  authenticated to call this function.
     */
    modifier onlyFromCrossDomainAccount(address _sourceDomainAccount) {
        require(
            msg.sender == messenger,
            "OVM_XCHAIN: messenger contract unauthenticated"
        );

        require(
            ICrossDomainMessenger(messenger).xDomainMessageSender() == _sourceDomainAccount,
            "OVM_XCHAIN: wrong sender of cross-domain message"
        );

        _;
    }
}
