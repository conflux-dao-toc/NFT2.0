// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@confluxfans/contracts/token/CRC721/extensions/CRC721Enumerable.sol";
import "@confluxfans/contracts/InternalContracts/InternalContractsHandler.sol";
import "@openzeppelin/contracts/access/AccessControlEnumerable.sol";

contract CRC721NatureAutoId is AccessControlEnumerable, CRC721Enumerable, InternalContractsHandler {
    using Strings for uint256;

    string private _URI;

    // Counter to auto generate token ID.
    uint256 private _currentTokenId;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    constructor(
        string memory name_,
        string memory symbol_,
        string memory uri_
    ) ERC721(name_, symbol_) {
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());

        setURI(uri_);

        _currentTokenId=1;
    }

    //simple code for add a account as minter
    function addMinter(address minter_) external {
        grantRole(MINTER_ROLE, minter_);
    }

    function removeMinter(address minter_) external {
        revokeRole(MINTER_ROLE, minter_);
    }

    /**
     * @dev Update the URI for all tokens.
     *
     * Requirements:
     *
     * - the caller must have the `DEFAULT_ADMIN_ROLE`.
     */
    function setURI(string memory newuri) public virtual {
        require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "CRC721NatureAutoId: must have admin role to set URI");
        _URI = newuri;
    }

    /**
     * @dev Base URI for computing {tokenURI}. If set, the resulting URI for each
     * token will be the concatenation of the `baseURI` and the `tokenId`. Empty
     * by default, can be overriden in child contracts.
     */
    function _baseURI() internal view virtual override returns (string memory) {
        return _URI;
    }

    /**
     * @dev See {IERC721Metadata-tokenURI}.
     */
    function tokenURI(uint256 tokenId) public view virtual override(ERC721)  returns (string memory) {
        require(_exists(tokenId), "ERC721Metadata: URI query for nonexistent token");

        string memory baseURI = _baseURI();
        return bytes(baseURI).length > 0 ? string(abi.encodePacked(baseURI, tokenId.toString(), ".json")) : "";
    }

    /**
     * @dev Creates a new token for `to`. Its token ID will be automatically
     * assigned (and available on the emitted {IERC721-Transfer} event), and the token
     * URI autogenerated based on the base URI passed at construction.
     *
     * See {ERC721-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    function mint(address to) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "CRC721NatureAutoId: must have minter role to mint");
        uint256 tokenId = _currentTokenId;
        _mint(to, tokenId);
        _currentTokenId = tokenId+1;
    }

    /**
     * @dev Batch version of mint function
     */
    function mintBatch(address to, uint256 amount) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "CRC721NatureAutoId: must have minter role to mint");
        uint256 tokenId = _currentTokenId;
        for (uint256 index = 0; index < amount; ++index) _mint(to, tokenId + index);
        _currentTokenId = tokenId + amount;
    }

    //chy:批量空投方法，给一组账户，分别空投1个顺延id的nft。
    function batchAddItemByAddress(address[] calldata _initialOwners) 
        public
    {
        require(hasRole(MINTER_ROLE, _msgSender()), "CRC721NatureAutoId: must have minter role to mint");
        uint256 _length = _initialOwners.length;
        uint256 tokenId = _currentTokenId;
        for (uint256 i = 0; i < _length; ++i) {
            _mint(_initialOwners[i], tokenId + i);
        }
        _currentTokenId = tokenId + _length;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, ERC721Enumerable) returns (bool) {
        return AccessControlEnumerable.supportsInterface(interfaceId) || ERC721Enumerable.supportsInterface(interfaceId);
    }
}