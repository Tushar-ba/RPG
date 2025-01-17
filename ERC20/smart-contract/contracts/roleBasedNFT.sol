// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;
import "@openzeppelin/contracts-upgradeable/token/ERC721/ERC721Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC721/extensions/ERC721URIStorageUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/OwnableUpgrable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "./Interface/IRPGtoken20.sol";

contract roleBaseNFT is Initializable ,ERC721Upgradeable, ERC721URIStorageUpgradeable, OwnableUpgrable, AccessControlUpgradeable{
    IRPGtoken20 public musicalToken;
    bytes public ADMIN_ROLE = keccak256("ADMIN_ROLE");
    bytes public MINTER_ROLE = keccak256("MINTER_ROLE");

    uint256 public nextTokenId;
     enum Role {
            King,
            Queen,
            joker,
            Commoners,
            Prisoner
        }

    struct nftDetails{
        address _owner;
        Role role;
        uint256 tokenId;
        bool existis;
    }

    mapping(address=>nftDetails) public details;

    function initialize() initializer public {
        __Ownable_init(msg.sender);
        grantRole(ADMIN_ROLE,msg.sender);
        grantRole(MINTER_ROLE,msg.sender);
        tokenContract = IRPGtoken20(tokenContractAddress);
    }

    function getURIForRole(Role role) internal pure returns (string memory) {
    if (role == Role.King) {
        return "QmX4kj8z4zKmX9KzejxJ5YZzXWqxFM6HRMG8CTjkyfhqG6";
    } else if (role == Role.Queen) {
        return "QmY7hz8zLPmX9LzejxJ5YZzXWqxFM6HRMG8CTjkyfhqG7";
    } else if (role == Role.joker) {
        return "QmZ9kj8z4zKmX9KzejxJ5YZzXWqxFM6HRMG8CTjkyfhqG8";
    } else if (role == Role.Commoners) {
        return "QmA2kj8z4zKmX9KzejxJ5YZzXWqxFM6HRMG8CTjkyfhqG9";
    } else if (role == Role.Prisoner) {
        return "QmB4kj8z4zKmX9KzejxJ5YZzXWqxFM6HRMG8CTjkyfhqG0";
    }
    return "QmDefaultHash";
    }   

    function safeMint(address _to, Role role)  public payable {
        (uint _balance, bool isActive) = musicalToken.getDetails();
        if(balance > musicalToken.FEE_AMOUNT){
            revert InsufficientFunds();
        }
        if(isActive && balanceOf == musicalToken.FEE_AMOUNT){
        uint256 tokenId = nextTokenId++;
        _safeMint(_to, tokenId);
        string memory roleURI = getURIForRole(role);
        _setTokenURI(tokenId, roleURI);
        details[_to] = nftDetails({
            _owner: _to,
            role: role,
            tokenId: tokenId,
            existis: true
        });
        emit NFTminted(tokenId,_to,role);
        }
    }

    function getNFTdetails() public returns(address,Role,uint256,bool) {
        nftDetails memory info = details(msg.sender);
        return (info.address,info.Role,info.uint256,info.bool)
    }
    
    function tokenURI(uint256 tokenId) public view override(ERC721Upgradeable, ERC721URIStorageUpgradeable) returns (string memory) {
        return super.tokenURI(tokenId);
    }
     function supportsInterface(
        bytes4 interfaceId
    )
        public
        view
        override(ERC721Upgradeable, ERC721URIStorageUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }
}