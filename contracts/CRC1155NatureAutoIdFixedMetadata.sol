// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@confluxfans/contracts/token/CRC1155/presets/CRC1155PresetAutoId.sol";
import "@confluxfans/contracts/token/CRC1155/extensions/CRC1155Metadata.sol";
import "@confluxfans/contracts/InternalContracts/InternalContractsHandler.sol";
import "@openzeppelin/contracts/utils/Strings.sol";

contract CRC1155NatureAutoIdFixedMetadata is AccessControlEnumerable, CRC1155Enumerable, CRC1155Metadata, InternalContractsHandler {
    using Counters for Counters.Counter;
    using Strings for uint256;

    // Counter to auto generate token ID.
    Counters.Counter private _tokenIdTracker;
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant PAUSER_ROLE = keccak256("PAUSER_ROLE");

    //tokenId => metadata
    mapping(uint256 => string) public tokenMetaData;
    //tokenId => FeatureCode, the Feature code is generally md5 code for resource files such as images or videos.
    mapping(uint256 => uint256) public tokenFeatureCode;

    constructor(
        string memory name_,
        string memory symbol_
        //string memory uri_
    ) CRC1155Metadata(name_, symbol_) ERC1155(""){
        _setupRole(DEFAULT_ADMIN_ROLE, _msgSender());

        _setupRole(MINTER_ROLE, _msgSender());
        _setupRole(PAUSER_ROLE, _msgSender());
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
    // function setURI(string memory newuri) public virtual {
    //     require(hasRole(DEFAULT_ADMIN_ROLE, _msgSender()), "CRC1155NatureAutoIdFixedMetadata: must have admin role to set URI");
    //     _setURI(newuri);
    // }

    /**
     * @dev See {IERC1155MetadataURI-uri}.
     *
     * This implementation returns the same URI for *all* token types. It relies
     * on the token type ID substitution mechanism
     * https://eips.ethereum.org/EIPS/eip-1155#metadata[defined in the EIP].
     *
     * Clients calling this function must replace the `\{id\}` substring with the
     * actual token type ID.
     */
    function uri(uint256 _tokenId) public view virtual override(ERC1155, IERC1155MetadataURI) returns (string memory) {
        //return string(abi.encodePacked(ERC1155.uri(tokenId), tokenId.toString(), ".json"));
        require(_tokenId > 0, "_tokenId must > 0.");
        require(_tokenId <= _tokenIdTracker.current(), "_tokenId must < amount minted.");
        return tokenMetaData[_tokenId];
    }

    /**
     * @dev Creates `amount` new tokens for `to`, of token type `id`.
     *
     * See {ERC1155-_mint}.
     *
     * Requirements:
     *
     * - the caller must have the `MINTER_ROLE`.
     */
    // function mint(
    //     address to,
    //     uint256 amount,
    //     bytes memory data
    // ) public virtual {
    //     require(hasRole(MINTER_ROLE, _msgSender()), "CRC1155NatureAutoIdFixedMetadata: must have minter role to mint");
    //     _mint(to, _tokenIdTracker.current()+1, amount, data);
    //     _tokenIdTracker.increment();
    // }

    // 下方函数已固定为非同质化铸造，即每个id的数量只有1个。如果需要同质化业务，请自行更换为上方注释掉的原来的函数。
    function mint(
        address to,
        string memory _metadata,
        bytes memory data
    ) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "CRC1155NatureAutoIdFixedMetadata: must have minter role to mint");
        uint256 tokenId = _tokenIdTracker.current()+1;
        tokenMetaData[tokenId] = _metadata;
        _mint(to, tokenId, 1, data);
        _tokenIdTracker.increment();
    }

    /**
     * @dev xref:ROOT:erc1155.adoc#batch-operations[Batched] variant of {mint}.
     */
    // function mintBatch(
    //     address to,
    //     uint256[] memory amounts,
    //     bytes memory data
    // ) public virtual {
    //     require(hasRole(MINTER_ROLE, _msgSender()), "CRC1155NatureAutoIdFixedMetadata: must have minter role to mint");
    //     uint256[] memory tokenIds = new uint256[](amounts.length);
    //     for (uint256 i = 0; i < amounts.length; i++) {
    //         tokenIds[i] = _tokenIdTracker.current()+1;
    //         _tokenIdTracker.increment();
    //     }
    //     _mintBatch(to, tokenIds, amounts, data);
    // }
    
    // 下方函数已固定为非同质化铸造，即每个id的数量只有1个。如果需要同质化业务，请自行更换为上方注释掉的原来的函数。
    function mintBatch(
        address to,
        string[] calldata _metadatas,
        bytes memory data
    ) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "CRC1155NatureAutoIdFixedMetadata: must have minter role to mint");
        uint256 _length = _metadatas.length;
        uint256[] memory tokenIds = new uint256[](_length);
        uint256[] memory amounts = new uint256[](_length);
        for (uint256 i = 0; i < _length; i++) {
            tokenIds[i] = _tokenIdTracker.current() + 1;
            tokenMetaData[tokenIds[i]] = _metadatas[i];
            _tokenIdTracker.increment();
            amounts[i] = 1;
             
        }
        _mintBatch(to, tokenIds, amounts, data);
    }


    //chy:简化的批量铸造方法，直接给to账户铸造amount个顺延id的nft，每个id数量都是1。
    function batchAddItemByNumber(address _to, string[] calldata _metadatas)
        public
    {
        require(hasRole(MINTER_ROLE, _msgSender()), "CRC1155NatureAutoIdFixedMetadata: must have minter role to mint");
        uint256 _length = _metadatas.length;
        for (uint i = 0; i < _length; i++) {
            tokenMetaData[_tokenIdTracker.current()+1] = _metadatas[i];
            _mint(_to, _tokenIdTracker.current()+1, 1, "");
            _tokenIdTracker.increment();
        }
    }

    //chy:批量空投方法，给一组账户，分别空投1个顺延id的nft。如果需要每个id有不同的数量，自行修改代码。
    function batchAddItemByAddress(address[] calldata _initialOwners, string[] calldata _metadatas) 
        public
    {
        require(hasRole(MINTER_ROLE, _msgSender()), "CRC1155NatureAutoIdFixedMetadata: must have minter role to mint");
        require(_initialOwners.length == _metadatas.length, "Owners or Metadatas's length mismatch");
        
        uint256 _length = _initialOwners.length;
        for (uint i = 0; i < _length; i++) {
            tokenMetaData[_tokenIdTracker.current()+1] = _metadatas[i];
            _mint(_initialOwners[i], _tokenIdTracker.current()+1, 1, "");
            _tokenIdTracker.increment();
        }
    }

    //Optional functions：The feature code can only be set once for each id, and then it can never be change again。
    function setTokenFeatureCode(uint256 tokenId, uint256 featureCode) public virtual {
        require(hasRole(MINTER_ROLE, _msgSender()), "CRC721NatureAutoId: must have minter role to mint");
        require(tokenFeatureCode[tokenId] == 0, "CRC721NatureAutoId: token Feature Code is already set up");
        tokenFeatureCode[tokenId] = featureCode;
    }

    /**
     * @dev See {IERC165-supportsInterface}.
     */
    function supportsInterface(bytes4 interfaceId) public view virtual override(AccessControlEnumerable, CRC1155Enumerable, IERC165) returns (bool) {
        return AccessControlEnumerable.supportsInterface(interfaceId) || CRC1155Enumerable.supportsInterface(interfaceId);
    }
}
