// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./Chromosome.sol";

contract MetaPersona is ERC1155, AccessControl, PersonaBase {
    bytes32 public constant URI_SETTER_ROLE = keccak256("URI_SETTER_ROLE");
    bytes32 public constant MINTER_ROLE = keccak256("MINTER_ROLE");
    bytes32 public constant GOD_ROLE = keccak256("GOD_ROLE");

    uint256 public constant METAPERSONATOKEN = 0;
    uint256 public constant ADAM = 1;
    uint256 public constant EVE = 2;
    uint256 public personaId;

    uint256 private seed;

    constructor(address admin, string memory uri) ERC1155(uri) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(GOD_ROLE, admin);
        _grantRole(MINTER_ROLE, admin);

        // initialize storage
        seed = 1;
        personaId = 1;
    }

    function setURI(string memory newuri) public onlyRole(URI_SETTER_ROLE) {
        _setURI(newuri);
    }

    function mint(address account, uint256 id, uint256 amount, bytes memory data) public onlyRole(MINTER_ROLE) {
        _mint(account, id, amount, data);
    }

    function mintBatch(address to, uint256[] memory ids, uint256[] memory amounts, bytes memory data)
        public
        onlyRole(MINTER_ROLE)
    {
        _mintBatch(to, ids, amounts, data);
    }

    // The following functions are overrides required by Solidity.

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    ///////////////////////////////////////////

    // Persona

    event Genesis(uint256 indexed timestamp);

    mapping(uint256 => Chromosomes) chromosomesN;

    function _makeNewPersona(address _owner, uint256 _personaId) internal returns (uint256) {
        _mint(_owner, _personaId, 1, "");
    }

    function _revertIfNotOwned(address _ownerAddress, uint256 _personaId) internal view {
        if (balanceOf(_ownerAddress, _personaId) != 1) {
            revert MetaPersona_PersonaNotFound();
        }
    }

    function getChromosomesN(address _owner, uint256 _personaId) external virtual returns (Chromosomes) {
        return _getChromosomesN(_owner, _personaId);
    }

    function _getChromosomesN(address _owner, uint256 _personaId) internal view returns (Chromosomes) {
        _revertIfNotOwned(_owner, _personaId);

        return chromosomesN[_personaId];
    }

    // breeding
    event NewPersonaBorn(uint256 indexed _personaId, address indexed receiver);

    function _breed(
        uint256 _personaId1,
        uint256 _personaId2,
        address _personaOwner1,
        address _personaOwner2,
        address _receiver
    ) internal returns (uint256) {
        // make sure that these persona's are owned by the input owners, otherwise revert
        _revertIfNotOwned(_personaOwner1, _personaId1);
        _revertIfNotOwned(_personaOwner2, _personaId2);

        // check one is female and one is a male
        Gender persona1Gender = chromosomesN[_personaId1].getGender();
        Gender persona2Gender = chromosomesN[_personaId2].getGender();

        if (
            (persona1Gender == Gender.Female && persona2Gender == Gender.Male)
                || (persona1Gender == Gender.Male && persona2Gender == Gender.Female)
        ) {
            // breedable
            Chromosomes chr1 = chromosomesN[_personaId1];
            Chromosomes chr2 = chromosomesN[_personaId2];
            // get gametes
            ChromosomeStructure[4] memory persona1_gametes = meiosis(chr1, seed);
            ChromosomeStructure[4] memory persona2_gametes = meiosis(chr2, seed);

            // randomly select 1 gamete from each
            uint256 gamete1_index = random(seed);
            uint256 gamete2_index = random(gamete1_index);
            seed = gamete2_index;

            ChromosomeStructure memory selected_gamet1 = persona1_gametes[gamete1_index % 4];
            ChromosomeStructure memory selected_gamet2 = persona2_gametes[gamete2_index % 4];

            // make new chromosomes
            Chromosomes newChr = new Chromosomes(
                selected_gamet1.autosomes,
                selected_gamet1.x,
                selected_gamet1.y,
                selected_gamet2.autosomes,
                selected_gamet2.x,
                selected_gamet2.y
            );

            uint256 newPersonaId = _makeNewPersona(_receiver, personaId++);
            chromosomesN[newPersonaId] = newChr;

            emit NewPersonaBorn(newPersonaId, _receiver);
            return newPersonaId;
        } else {
            revert MetaPersona_IncompatiblePersonas();
        }
    }

    function genesis(
        uint256[37] memory _adam_p_a,
        uint192 _adam_p_y,
        uint256[37] memory _adam_m_a,
        uint256[2] memory _adam_m_x,
        uint256[37] memory _eve_p_a,
        uint256[2] memory _eve_p_x,
        uint256[37] memory _eve_m_a,
        uint256[2] memory _eve_m_x
    ) external virtual onlyRole(GOD_ROLE) {
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
        personaId += 2;
    }

    function breed(
        uint256 _personaId1,
        uint256 _personaId2,
        address _personaOwner1,
        address _personaOwner2,
        address _receiver
    ) external virtual returns (uint256) {
        return _breed(_personaId1, _personaId2, _personaOwner1, _personaOwner2, _receiver);
    }
}
