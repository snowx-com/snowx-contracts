// SPDX-License-Identifier: MIT
pragma solidity ^0.8.4;

import "@openzeppelin/contracts/utils/Counters.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";

contract SnowXToken is Initializable, ERC721Upgradeable, OwnableUpgradeable {
    bytes4 private constant INTERFACE_ID_ERC2981 = 0x2a55205a;
    using Counters for Counters.Counter;
    Counters.Counter public numTokens;

    uint8 public royaltyFeePercent = 0;
    string public baseURI;

    function initialize(address _owner, string calldata _name, string calldata _symbol, string calldata _uri, uint8 _royaltyFeePercent) public initializer {
        __Ownable_init_unchained();
        __ERC721_init_unchained(_name, _symbol);
        baseURI = _uri;
        royaltyFeePercent = _royaltyFeePercent;
        transferOwnership(_owner);
    }

    function setBaseURI(string calldata _uri) public onlyOwner {
        baseURI = _uri;
    }

    function _baseURI() internal view virtual override returns (string memory) {
        return baseURI;
    }

    function mint(address to_) external onlyOwner() returns (uint256) {
        numTokens.increment();
        uint256 newItemId = numTokens.current();
        _mint(to_, newItemId);
        return(newItemId);
    }

    function royaltyInfo(uint256 _tokenId, uint256 _salePrice) external view returns (address receiver, uint256 royaltyAmount) {
        require(ownerOf(_tokenId) != address(0x0), "Royalty lookup for non-existent token");
        return (owner(), _salePrice * royaltyFeePercent / 100);
    }

    function supportsInterface(bytes4 interfaceId) public view virtual override(ERC721Upgradeable) returns (bool) {
        if(interfaceId == INTERFACE_ID_ERC2981) {
            return true;
        }
        return super.supportsInterface(interfaceId);
    }

    function burn(uint256 tokenId) public virtual {
        require(_isApprovedOrOwner(_msgSender(), tokenId), "ERC721: caller is not token owner or approved");
        _burn(tokenId);
    }
}