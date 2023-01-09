// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;
import { Address } from "@openzeppelin/contracts/utils/Address.sol";
/**
 * @title L1TosV2BridgeStorage
 * @dev
 *
 */
contract L1TosV2BridgeStorage {

    /********************************
     * External Contract References *
     ********************************/

    address public l2TosV2Bridge;
    address public l1TosV2Treasury;
    address public l2TosV2Treasury;

    // Maps L1 token to L2 token to balance of the L1 token deposited
    mapping(address => mapping(address => uint256)) public deposits;

    /** @dev Modifier requiring sender to be EOA.  This check could be bypassed by a malicious
     *  contract via initcode, but it takes care of the user error we want to avoid.
     */
    modifier onlyEOA() {
        // Used to stop deposits from contracts (avoid accidentally lost tokens)
        require(!Address.isContract(msg.sender), "Account not EOA");
        _;
    }

    modifier nonZeroAddress(address account) {
        require(
            account != address(0),
            "zero address"
        );
        _;
    }
}
