// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

contract SigUtils {
    bytes32 internal DOMAIN_SEPARATOR;

    constructor(bytes32 _DOMAIN_SEPARATOR) {
        DOMAIN_SEPARATOR = _DOMAIN_SEPARATOR;
    }

    bytes32 public constant PERMIT_TYPEHASH =
        keccak256("DelegationWithSig(address delegatee,uint256 value,uint256 nonce,uint256 deadline)");

    struct Permit {
        address owner;
        address spender;
        uint256 value;
        uint256 nonce;
        uint256 deadline;
    }

    function getStructHash(Permit memory _permit) internal pure returns (bytes32) {
        return keccak256(abi.encode(PERMIT_TYPEHASH, _permit.spender, _permit.value, _permit.nonce, _permit.deadline));
    }

    function getTypedDataHash(Permit memory _permit) public view returns (bytes32) {
        return keccak256(abi.encodePacked("\x19\x01", DOMAIN_SEPARATOR, getStructHash(_permit)));
    }
}
