// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/introspection/IERC165.sol";
import "@openzeppelin/contracts/token/ERC721/IERC721.sol";
import "@openzeppelin/contracts/interfaces/IERC1271.sol";
import "@openzeppelin/contracts/utils/cryptography/SignatureChecker.sol";
import "../interfaces/IERC6551Account.sol";
import "../interfaces/IERC6551Executable.sol";

// Aave V3
import { IPool } from "@aave/core-v3/contracts/interfaces/IPool.sol";
import { IPoolAddressesProvider } from "@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
import { AaveV3Sepolia } from "aave-address-book/AaveV3Sepolia.sol";

// Token
import { GHOTunes } from "../GhoTunes.sol";

interface IAccount {
    function performUpkeep() external;
    function initialize(address _forwarder, address _tunes) external;
}

contract GHOTunesAccount is IAccount, IERC165, IERC1271, IERC6551Account, IERC6551Executable {
    uint256 public state;
    IPoolAddressesProvider public aaveAddressesProvider =
        IPoolAddressesProvider(address(AaveV3Sepolia.POOL_ADDRESSES_PROVIDER));
    IPool public aavePool = IPool(address(AaveV3Sepolia.POOL));

    address public forwarder;
    address public tunes;

    event RenewSuccess(uint256 tokenId);

    modifier onlyOnce() {
        require(forwarder == address(0), "GHOTunesAccount: already initialized");
        _;
    }

    modifier onlyForwarder() {
        require(msg.sender == forwarder, "GHOTunesAccount: only forwarder");
        _;
    }

    function initialize(address _forwarder, address _tunes) external onlyOnce {
        require(_forwarder != address(0), "GHOTunesAccount: invalid forwarder");
        forwarder = _forwarder;
        tunes = _tunes;
    }

    function performUpkeep() external onlyForwarder {
        (, address tokenContract, uint256 tokenId) = token();
        GHOTunes ghoTunes = GHOTunes(tunes);
        try ghoTunes.renew(tokenId) {
            emit RenewSuccess(tokenId);
        } catch {
            ghoTunes.handleRenewFail(tokenId);
        }
    }

    receive() external payable { }

    function execute(
        address to,
        uint256 value,
        bytes calldata data,
        uint256 operation
    )
        external
        payable
        returns (bytes memory result)
    {
        require(_isValidSigner(msg.sender), "Invalid signer");
        require(operation == 0, "Only call operations are supported");

        ++state;

        bool success;
        (success, result) = to.call{ value: value }(data);

        if (!success) {
            assembly {
                revert(add(result, 32), mload(result))
            }
        }
    }

    function isValidSigner(address signer, bytes calldata) external view returns (bytes4) {
        if (_isValidSigner(signer)) {
            return IERC6551Account.isValidSigner.selector;
        }

        return bytes4(0);
    }

    function isValidSignature(bytes32 hash, bytes memory signature) external view returns (bytes4 magicValue) {
        bool isValid = SignatureChecker.isValidSignatureNow(owner(), hash, signature);

        if (isValid) {
            return IERC1271.isValidSignature.selector;
        }

        return "";
    }

    function supportsInterface(bytes4 interfaceId) external pure returns (bool) {
        return (
            interfaceId == type(IERC165).interfaceId || interfaceId == type(IERC6551Account).interfaceId
                || interfaceId == type(IERC6551Executable).interfaceId
        );
    }

    function token() public view returns (uint256, address, uint256) {
        bytes memory footer = new bytes(0x60);

        assembly {
            extcodecopy(address(), add(footer, 0x20), 0x4d, 0x60)
        }

        return abi.decode(footer, (uint256, address, uint256));
    }

    function owner() public view returns (address) {
        (uint256 chainId, address tokenContract, uint256 tokenId) = token();
        if (chainId != block.chainid) return address(0);

        return IERC721(tokenContract).ownerOf(tokenId);
    }

    function _isValidSigner(address signer) internal view returns (bool) {
        return signer == owner();
    }
}
