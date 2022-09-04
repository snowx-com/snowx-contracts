// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/utils/Strings.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./MinimalProxy.sol";
import "./SnowXToken.sol";

contract SnowXTokenFactory is Ownable, MinimalProxy {
    address constant private proxyAddress = 0x455543629856e40aC3cCeC56C365e9D9bD3fd713;
    string private baseURI = "https://nfts.snowx.com/";
    address[] private allNfts;
    mapping(address => address[]) private nfts;

    function createNFTCollection(
        string calldata _name, 
        string calldata _symbol, 
        uint8 _royaltyFeePercent
    ) external returns (address) {
        address cloneAddr = createClone(proxyAddress);
        string memory uri = string.concat(baseURI, Strings.toHexString(uint160(cloneAddr), 20), "/");
        SnowXToken(cloneAddr).initialize(msg.sender, _name, _symbol, uri, _royaltyFeePercent);
        allNfts.push(cloneAddr);
        nfts[msg.sender].push(cloneAddr);
        return cloneAddr;
    }

    function setBaseURI(string calldata _uri) public onlyOwner {
        baseURI = _uri;
    }

    function getCollections() external view returns (address[] memory) {
        return allNfts;
    }

    function getMyCollections() external view returns (address[] memory) {
        return nfts[msg.sender];
    }

}