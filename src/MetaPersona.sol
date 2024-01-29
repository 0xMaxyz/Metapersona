// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "./lib/Genetics.sol";

contract MetaPersona is ERC1155, AccessControl {
    bytes32 public constant SPAWN_ROLE = keccak256("SPAWN_ROLE");

    uint256 public constant METAPERSONATOKEN = 0;
    uint256 public constant ADAM = 1;
    uint256 public constant EVE = 2;
    uint256 public personaId;

    uint256 private seed;

    constructor(address admin, string memory uri, uint256 _seed) ERC1155(uri) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(SPAWN_ROLE, admin);

        // initialize storage
        seed = _seed;
        personaId = 1;
    }

    function setURI(string memory newuri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(newuri);
    }

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    // Persona

    event Genesis(uint256 indexed timestamp);

    mapping(uint256 => Genetics.Chromosome[2]) chromosomesN;

    function _makeNewPersona(address _owner, uint256 _personaId) private returns (uint256) {
        _mint(_owner, _personaId, 1, "");
        return _personaId;
    }

    function _revertIfNotOwned(address _ownerAddress, uint256 _personaId) private view {
        if (balanceOf(_ownerAddress, _personaId) != 1) {
            revert MetaPersona_PersonaNotFound();
        }
    }

    function getChromosomesN(address _owner, uint256 _personaId)
        external
        view
        virtual
        returns (Genetics.Chromosome[2] memory)
    {
        return _getChromosomesN(_owner, _personaId);
    }

    function _getChromosomesN(address _owner, uint256 _personaId)
        private
        view
        returns (Genetics.Chromosome[2] memory)
    {
        _revertIfNotOwned(_owner, _personaId);

        return chromosomesN[_personaId];
    }

    // spawning
    event NewPersonaBorn(uint256 indexed _personaId, address indexed receiver);

    function _spawn(
        uint256 _personaId1,
        uint256 _personaId2,
        address _personaOwner1,
        address _personaOwner2,
        address _receiver
    ) private returns (uint256) {
        // make sure that these persona's are owned by the input owners, otherwise revert
        _revertIfNotOwned(_personaOwner1, _personaId1);
        _revertIfNotOwned(_personaOwner2, _personaId2);

        // check if one is female and one is a male
        Genetics.Gender persona1Gender = Genetics.getGender(chromosomesN[_personaId1]);
        Genetics.Gender persona2Gender = Genetics.getGender(chromosomesN[_personaId2]);

        if (
            (persona1Gender == Genetics.Gender.Female && persona2Gender == Genetics.Gender.Male)
                || (persona1Gender == Genetics.Gender.Male && persona2Gender == Genetics.Gender.Female)
        ) {
            Random.RandomArgs memory rArgs;
            uint256 rand;

            rArgs.Prevrandao = block.prevrandao;
            rArgs.Sender = msg.sender;
            rArgs.Timestamp = block.timestamp;
            // spawnable
            // get gametes
            Genetics.Chromosome[4] memory persona1_gametes;
            Genetics.Chromosome[4] memory persona2_gametes;

            (persona1_gametes, rand) = ChromosomeLib.meiosis(chromosomesN[_personaId1], seed, rArgs);
            (persona2_gametes, rand) = ChromosomeLib.meiosis(chromosomesN[_personaId2], rand, rArgs);

            // randomly select 1 gamete from each
            uint256 gamete1_index = Random.random(rand, rArgs);
            uint256 gamete2_index = Random.random(gamete1_index, rArgs);

            seed = gamete2_index; // update seed state value

            Genetics.Chromosome memory selected_gamet1 = persona1_gametes[gamete1_index % 4];
            Genetics.Chromosome memory selected_gamet2 = persona2_gametes[gamete2_index % 4];

            uint256 newPersonaId = _makeNewPersona(_receiver, personaId++);
            _copyChromosomeToStorage(newPersonaId, [selected_gamet1, selected_gamet2]);

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
    ) external virtual onlyRole(SPAWN_ROLE) {
        // make Adam persona
        Genetics.Chromosome memory adam_p;
        Genetics.Chromosome memory adam_m;

        Genetics.Chromosome memory eve_p;
        Genetics.Chromosome memory eve_m;

        adam_p.autosomes = _adam_p_a;
        adam_p.y = _adam_p_y;

        adam_m.autosomes = _adam_m_a;
        adam_m.x = _adam_m_x;

        eve_p.autosomes = _eve_p_a;
        eve_p.x = _eve_p_x;

        eve_m.autosomes = _eve_m_a;
        eve_m.x = _eve_m_x;

        _makeNewPersona(msg.sender, ADAM);
        _copyChromosomeToStorage(ADAM, [adam_p, adam_m]);

        // make Eve persona

        _makeNewPersona(msg.sender, EVE);
        _copyChromosomeToStorage(EVE, [eve_p, eve_m]);

        emit Genesis(block.timestamp);
        personaId += 2;
    }

    function spawn(uint256 _personaId1, uint256 _personaId2, address _personaOwner, address _receiver)
        external
        returns (uint256)
    {
        return _spawn(_personaId1, _personaId2, _personaOwner, _personaOwner, _receiver);
    }

    function _copyChromosomeToStorage(uint256 _personaId, Genetics.Chromosome[2] memory _chr) private {
        // check that if this personaId has chromosomes, if it has, revert
        if (
            chromosomesN[_personaId][0].y > 0
                && (chromosomesN[_personaId][0].x[0] > 0 || chromosomesN[_personaId][0].x[1] > 0)
        ) {
            revert MetaPersona_InvalidGeneticCombination();
        }

        // x and y
        chromosomesN[_personaId][0].y = _chr[0].y;
        chromosomesN[_personaId][0].x[0] = _chr[0].x[0];
        chromosomesN[_personaId][0].x[1] = _chr[0].x[1];
        chromosomesN[_personaId][1].y = _chr[1].y;
        chromosomesN[_personaId][1].x[0] = _chr[1].x[0];
        chromosomesN[_personaId][1].x[1] = _chr[1].x[1];
        // autosomes
        for (uint256 i = 0; i < 37; i++) {
            chromosomesN[_personaId][0].autosomes[i] = _chr[0].autosomes[i];
            chromosomesN[_personaId][1].autosomes[i] = _chr[1].autosomes[i];
        }
    }

    function spawn(
        uint256 _personaId1,
        uint256 _personaId2,
        address _personaOwner1,
        address _personaOwner2,
        address _receiver,
        Genetics.Chromosome[2] calldata _chr
    ) external onlyRole(SPAWN_ROLE) returns (uint256) {
        _revertIfNotOwned(_personaOwner1, _personaId1);
        _revertIfNotOwned(_personaOwner2, _personaId2);

        uint256 newPersonaId = _makeNewPersona(_receiver, personaId++);
        _copyChromosomeToStorage(newPersonaId, _chr);

        emit NewPersonaBorn(newPersonaId, _receiver);

        return newPersonaId;
    }

    function addSpawner(address _spawner) external onlyRole(SPAWN_ROLE) {
        if (!hasRole(SPAWN_ROLE, _spawner)) {
            grantRole(SPAWN_ROLE, _spawner);
        }
    }

    function removeSpawner(address _spawner) external onlyRole(SPAWN_ROLE) {
        if (hasRole(SPAWN_ROLE, _spawner)) {
            revokeRole(SPAWN_ROLE, _spawner);
        }
    }
}
