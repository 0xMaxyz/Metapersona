// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts-upgradeable/token/ERC1155/ERC1155Upgradeable.sol";
import "@openzeppelin/contracts-upgradeable/access/AccessControlUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155BurnableUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/token/ERC1155/extensions/ERC1155SupplyUpgradeable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/Initializable.sol";
import "@openzeppelin/contracts-upgradeable/proxy/utils/UUPSUpgradeable.sol";

import "./lib/Chromosome.sol";
import "./lib/Helpers.sol";

contract MetaPersona is
    Initializable,
    ERC1155Upgradeable,
    AccessControlUpgradeable,
    ERC1155BurnableUpgradeable,
    ERC1155SupplyUpgradeable,
    UUPSUpgradeable
{
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant GOD_ROLE = keccak256("GOD_ROLE");
    bytes32 public constant UPGRADER_ROLE = keccak256("UPGRADER_ROLE");

    // MetaPersona

    uint256 public constant ADAM = 1;
    uint256 public constant EVE = 2;

    uint256 private seed;

    /// @custom:oz-upgrades-unsafe-allow constructor
    constructor() {
        _disableInitializers();
    }

    function initialize(address admin, string memory uri) public initializer {
        __ERC1155_init(uri);
        __AccessControl_init();
        __ERC1155Burnable_init();
        __ERC1155Supply_init();
        __UUPSUpgradeable_init();

        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(GOD_ROLE, admin);
        _grantRole(UPGRADER_ROLE, admin);

        // initialize storage
        seed = 1;
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    // function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyRole(MINTER_ROLE) {
    //     _mint(account, id, amount, data);
    // }

    // function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
    //     public
    //     onlyRole(MINTER_ROLE)
    // {
    //     _mintBatch(to, ids, amounts, data);
    // }

    function _authorizeUpgrade(address newImplementation) internal override onlyRole(UPGRADER_ROLE) {}

    // The following functions are overrides required by Solidity.

    function _update(address from, address to, uint256[] memory ids, uint256[] memory values)
        internal
        override(ERC1155Upgradeable, ERC1155SupplyUpgradeable)
    {
        super._update(from, to, ids, values);
    }

    function supportsInterface(bytes4 interfaceId)
        public
        view
        override(ERC1155Upgradeable, AccessControlUpgradeable)
        returns (bool)
    {
        return super.supportsInterface(interfaceId);
    }

    // Persona

    event Genesis(uint256 indexed timestamp);

    mapping(uint256 => Chromosomes) chromosomesN;

    function _makeNewPersona(address owner, uint256 personaId) internal {
        _mint(owner, personaId, 1, "");
    }

    function _revertIfNotOwned(address _ownerAddress, uint256 _personaId) internal {
        if (balanceOf(_ownerAddress, _personaId) != 1) {
            revert Errors.MetaPersona_PersonaNotFound();
        }
    }

    function _genesisN(
        uint256[37] memory _adam_p_a,
        uint192 _adam_p_y,
        uint256[37] memory _adam_m_a,
        uint256[2] memory _adam_m_x,
        uint256[37] memory _eve_p_a,
        uint256[2] memory _eve_p_x,
        uint256[37] memory _eve_m_a,
        uint256[2] memory _eve_m_x
    ) internal onlyRole(GOD_ROLE) {
        uint256[2] memory emptyX;
        // make Adam persona
        Chromosomes adam = new Chromosomes(_adam_p_a, emptyX, _adam_p_y, _adam_m_a, _adam_m_x, uint192(0));

        _makeNewPersona(msg.sender, ADAM);
        chromosomesN[ADAM] = adam;

        // make Eve persona
        Chromosomes eve = new Chromosomes(_eve_p_a, _eve_p_x, uint192(0), _eve_m_a, _eve_m_x, uint192(0));
        _makeNewPersona(msg.sender, EVE);
        chromosomesN[EVE] = eve;

        emit Genesis(block.timestamp);
    }

    function getChromosomesN(address _owner, uint256 _personaId) external virtual returns (Chromosomes) {
        return _getChromosomesN(_owner, _personaId);
    }

    function _getChromosomesN(address _owner, uint256 _personaId) internal returns (Chromosomes) {
        _revertIfNotOwned(_owner, _personaId);

        return chromosomesN[_personaId];
    }

    // breeding

    // function _breed(
    //     uint256 _personaId1,
    //     uint256 _personaId2,
    //     address _personaOwner1,
    //     address _personaOwner2,
    //     address _receiver
    // ) internal returns (uint256 newPersonaId) {
    //     // make sure that these persona's are owned by the input owners, otherwise revert
    //     _revertIfNotOwned(_personaOwner1, _personaId1);
    //     _revertIfNotOwned(_personaOwner2, _personaId2);

    //     // check one is female and one is a male
    //     Genetics.Gender persona1Gender = _getGender(_personaOwner1, _personaId1);
    //     Genetics.Gender persona2Gender = _getGender(_personaOwner2, _personaId2);

    //     if (
    //         (persona1Gender == Genetics.Gender.Female && persona2Gender == Genetics.Gender.Male)
    //             || (persona1Gender == Genetics.Gender.Male && persona2Gender == Genetics.Gender.Female)
    //     ) {
    //         // breedable
    //         Chromosomes chr1 = chromosomesN[_personaId1];
    //         Chromosomes chr2 = chromosomesN[_personaId2];
    //         // get gametes
    //         uint256[39][4] memory chr1_gametes = Genetics.meiosisG(chr1.getDNA(1), chr1.getDNA(2), seed);
    //         uint256[39][4] memory chr2_gametes = Genetics.meiosisG(chr2.getDNA(1), chr2.getDNA(2), seed);

    //         // randomly select 1 gamete from each
    //         uint256 gamete1_index = Helpers.random(seed);
    //         uint256 gamete2_index = Helpers.random(gamete1_index);

    //         seed = gamete2_index;
    //     } else {
    //         revert Errors.MetaPersona_IncompatiblePersonas();
    //     }
    // }
}
