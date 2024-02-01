// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

import "@openzeppelin/contracts/token/ERC1155/ERC1155.sol";
import "@openzeppelin/contracts/access/AccessControl.sol";
import "@openzeppelin/contracts/utils/Strings.sol";
import "./lib/Genetics.sol";
import "./Errors.sol";

contract MetaPersona is ERC1155, AccessControl {
    using Strings for uint256;

    bytes32 public constant SPAWN_ROLE = keccak256("SPAWN_ROLE");
    uint256 public personaId;
    uint256 public genesisTimestamp;

    uint256 private constant METAPERSONATOKEN = 0;
    uint256 private constant ADAM = 1;
    uint256 private constant EVE = 2;
    int256 private _coolDownLength = 2 days;
    uint256 public minStakeDuration = 2 days;
    uint256 private seed;
    uint256 private _fixedStakeReward = 0.01 ether;

    mapping(address => uint256[]) private _personas;
    mapping(uint256 => uint256[]) private _children;
    mapping(uint256 => int256) private _coolDown;
    mapping(uint256 => Genetics.Gender) private _gender;
    mapping(uint256 => uint256[2]) private _parents;
    mapping(uint256 => Genetics.Chromosome[2]) private _chromosomes;

    mapping(uint256 => bool) private _staked;
    mapping(uint256 => uint256) private _stakedAt;

    event Genesis(uint256 indexed timestamp);
    event NewPersonaBorn(uint256 indexed _personaId, address indexed receiver);
    event PersonaStaked(uint256 indexed _personaId);
    event PersonaUnstaked(uint256 indexed _personaId, uint256 indexed reward);

    constructor(address admin, string memory _uri, uint256 _seed) ERC1155(_uri) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(SPAWN_ROLE, admin);

        // initialize storage
        seed = _seed;
        personaId = 1;
        // mint
    }

    modifier GenesisOnce() {
        require(genesisTimestamp == 0, "Genesis has happened before");

        _;

        genesisTimestamp = block.timestamp;
        emit Genesis(block.timestamp);

        personaId += 2;
        _personas[msg.sender].push(ADAM);
        _personas[msg.sender].push(EVE);

        _gender[ADAM] = Genetics.Gender.Male;
        _gender[EVE] = Genetics.Gender.Female;
    }

    // ---------------------------------- //
    //              Overrides             //
    // ---------------------------------- //

    function supportsInterface(bytes4 interfaceId) public view override(ERC1155, AccessControl) returns (bool) {
        return super.supportsInterface(interfaceId);
    }

    function uri(uint256 id) public view override returns (string memory) {
        if (id == 0) {
            revert MetaPersona_NoURI();
        }

        return string(abi.encodePacked(super.uri(id), id.toString()));
    }

    function safeTransferFrom(address from, address to, uint256 id, uint256 value, bytes memory data) public override {
        super.safeTransferFrom(from, to, id, value, data);
        if (id > 0) {
            // then the transfered token is a Persona, the required mappings shall be updated
            _transferPersona(from, to, id);
        }
    }

    function safeBatchTransferFrom(
        address from,
        address to,
        uint256[] memory ids,
        uint256[] memory values,
        bytes memory data
    ) public override {
        super.safeBatchTransferFrom(from, to, ids, values, data);
        for (uint256 i = 0; i < ids.length; i++) {
            if (ids[i] > 0) {
                _transferPersona(from, to, ids[i]);
            }
        }
    }

    // ---------------------------------- //
    //   Public and External Functions    //
    // ---------------------------------- //

    function setURI(string memory newuri) public onlyRole(DEFAULT_ADMIN_ROLE) {
        _setURI(newuri);
    }

    function getChromosomes(uint256 _personaId) external view returns (Genetics.Chromosome[2] memory) {
        return _getChromosomes(msg.sender, _personaId);
    }

    function getChromosomes(address _owner, uint256 _personaId)
        external
        view
        onlyRole(SPAWN_ROLE)
        returns (Genetics.Chromosome[2] memory)
    {
        return _getChromosomes(_owner, _personaId);
    }

    function SetCooldown(int256 _cdLength) external onlyRole(DEFAULT_ADMIN_ROLE) {
        _coolDownLength = _cdLength;
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
    ) external onlyRole(SPAWN_ROLE) GenesisOnce {
        uint256[2] memory emptyX;

        Genetics.Chromosome memory adam_p = _initializeChromosome(_adam_p_a, emptyX, _adam_p_y);
        Genetics.Chromosome memory adam_m = _initializeChromosome(_adam_m_a, _adam_m_x, 0);
        Genetics.Chromosome memory eve_p = _initializeChromosome(_eve_p_a, _eve_p_x, 0);
        Genetics.Chromosome memory eve_m = _initializeChromosome(_eve_m_a, _eve_m_x, 0);

        _makeNewPersona(msg.sender, ADAM);
        _copyChromosomeToStorage(ADAM, [adam_p, adam_m]);

        // make Eve persona

        _makeNewPersona(msg.sender, EVE);
        _copyChromosomeToStorage(EVE, [eve_p, eve_m]);
    }

    function genesis(Genetics.Chromosome[2] memory _adam, Genetics.Chromosome[2] memory _eve)
        external
        onlyRole(SPAWN_ROLE)
        GenesisOnce
    {
        _makeNewPersona(msg.sender, ADAM);
        _copyChromosomeToStorage(ADAM, _adam);

        // make Eve persona

        _makeNewPersona(msg.sender, EVE);
        _copyChromosomeToStorage(EVE, _eve);
    }

    function spawn(uint256 _personaId1, uint256 _personaId2, address _receiver) external returns (uint256) {
        // revert if _personaOwner does not own both personas
        _revertIfNotOwned(msg.sender, _personaId1);
        _revertIfNotOwned(msg.sender, _personaId2);
        // revert if staked
        _revertIfStaked(_personaId1);
        _revertIfStaked(_personaId2);
        return _spawn(_personaId1, _personaId2, msg.sender, msg.sender, _receiver);
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

        // revert if staked
        _revertIfStaked(_personaId1);
        _revertIfStaked(_personaId2);

        // Check cooldown
        _checkCooldown(_personaId1, _personaId2);

        uint256 newPersonaId = _makeNewPersona(_receiver, personaId++);
        _copyChromosomeToStorage(newPersonaId, _chr);

        emit NewPersonaBorn(newPersonaId, _receiver);

        _personas[_receiver].push(newPersonaId);
        _addChildAndSetParent(_personaId1, _personaId2, newPersonaId);
        (_personaId1, _personaId2, newPersonaId);

        // set gender
        Genetics.Gender childGender = Genetics.getGender(_chr);
        _gender[newPersonaId] = childGender;

        // set cooldown for daughter
        if (childGender == Genetics.Gender.Female) {
            _coolDown[newPersonaId] = int256(block.timestamp);
        }

        // set cooldown for mother
        _setCooldown(_personaId1, _personaId2);

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

    function stake(uint256 id) external {
        _stake(msg.sender, id);
    }

    function unstake(uint256 id) external {
        _unstake(msg.sender, id);
    }

    // ---------------------------------- //
    //           View Functions           //
    // ---------------------------------- //

    function getPersonas() external view returns (uint256[] memory) {
        return _getPersonas(msg.sender);
    }

    function getPersonas(address _addr) external view onlyRole(SPAWN_ROLE) returns (uint256[] memory) {
        return _getPersonas(_addr);
    }

    function getGender(uint256 _pId) external view returns (Genetics.Gender) {
        if (hasRole(SPAWN_ROLE, msg.sender)) {
            return _gender[_pId];
        }
        _revertIfNotOwned(msg.sender, _pId);
        return _gender[_pId];
    }

    function getChildren(uint256 _pid1, uint256 _pid2) external view returns (uint256[] memory) {
        if (hasRole(SPAWN_ROLE, msg.sender)) {
            return _getChildren(_pid1, _pid2);
        }
        if (balanceOf(msg.sender, _pid1) == 0 && balanceOf(msg.sender, _pid2) == 0) {
            revert MetaPersona_NotAuthorized();
        }
        return _getChildren(_pid1, _pid2);
    }

    function getParents(uint256 _pid) external view returns (uint256, uint256) {
        if (hasRole(SPAWN_ROLE, msg.sender)) {
            return _getParents(_pid);
        }
        _revertIfNotOwned(msg.sender, _pid);

        return _getParents(_pid);
    }

    // ---------------------------------- //
    //          Private functions         //
    // ---------------------------------- //

    function _getChromosomes(address _owner, uint256 _personaId) private view returns (Genetics.Chromosome[2] memory) {
        _revertIfNotOwned(_owner, _personaId);

        return _chromosomes[_personaId];
    }

    function _makeNewPersona(address _owner, uint256 _personaId) private returns (uint256) {
        _mint(_owner, _personaId, 1, "");
        return _personaId;
    }

    function _revertIfNotOwned(address _ownerAddress, uint256 _personaId) private view {
        if (balanceOf(_ownerAddress, _personaId) != 1) {
            revert MetaPersona_PersonaNotFound();
        }
    }

    function _revertIfStaked(uint256 id) private view {
        if (_staked[id]) {
            revert MetaPersona_CantSpawnWhenStaked();
        }
    }

    function _checkCooldown(uint256 _pid1, uint256 _pid2) private view {
        if (
            _gender[_pid1] == Genetics.Gender.Female && _coolDown[_pid1] > 0
                && int256(block.timestamp) - _coolDown[_pid1] <= _coolDownLength
        ) {
            revert MetaPersona_PersonaInCooldown();
        }
        if (
            _gender[_pid2] == Genetics.Gender.Female && _coolDown[_pid2] > 0
                && int256(block.timestamp) - _coolDown[_pid2] <= _coolDownLength
        ) {
            revert MetaPersona_PersonaInCooldown();
        }
    }

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
        Genetics.Gender persona1Gender = _gender[_personaId1];
        Genetics.Gender persona2Gender = _gender[_personaId2];

        if (
            (persona1Gender == Genetics.Gender.Female && persona2Gender == Genetics.Gender.Male)
                || (persona1Gender == Genetics.Gender.Male && persona2Gender == Genetics.Gender.Female)
        ) {
            // Check cooldown
            _checkCooldown(_personaId1, _personaId2);

            Random.RandomArgs memory rArgs;
            uint256 rand;

            rArgs.Prevrandao = block.prevrandao;
            rArgs.Sender = msg.sender;
            rArgs.Timestamp = block.timestamp;
            // spawnable
            // get gametes
            Genetics.Chromosome memory persona1_gamete;
            Genetics.Chromosome memory persona2_gamete;

            (persona1_gamete, rand) = ChromosomeLib.meiosis1Chr(_chromosomes[_personaId1], seed, rArgs);
            (persona2_gamete, rand) = ChromosomeLib.meiosis1Chr(_chromosomes[_personaId2], rand, rArgs);

            seed = rand; // update seed state value

            uint256 newPersonaId = _makeNewPersona(_receiver, personaId++);
            _copyChromosomeToStorage(newPersonaId, [persona1_gamete, persona2_gamete]);

            emit NewPersonaBorn(newPersonaId, _receiver);

            _personas[_receiver].push(newPersonaId);

            _addChildAndSetParent(_personaId1, _personaId2, newPersonaId);

            // set gender
            Genetics.Gender childGender = Genetics.getGender([persona1_gamete, persona2_gamete]);
            _gender[newPersonaId] = childGender;

            // set cooldown for daughter
            if (childGender == Genetics.Gender.Female) {
                _coolDown[newPersonaId] = int256(block.timestamp);
            }

            // set cooldown for mother
            _setCooldown(_personaId1, _personaId2);

            return newPersonaId;
        } else {
            revert MetaPersona_IncompatiblePersonas();
        }
    }

    function _addChild(uint256 _pid1, uint256 _pid2, uint256 childId) private {
        (uint256 smaller, uint256 larger) = _pid1 < _pid2 ? (_pid1, _pid2) : (_pid2, _pid1);
        uint256 key = uint256(keccak256(abi.encodePacked(smaller, larger)));
        _children[key].push(childId);
    }

    function _getChildren(uint256 _pid1, uint256 _pid2) private view returns (uint256[] memory) {
        (uint256 smaller, uint256 larger) = _pid1 < _pid2 ? (_pid1, _pid2) : (_pid2, _pid1);
        uint256 key = uint256(keccak256(abi.encodePacked(smaller, larger)));
        return _children[key];
    }

    function _setParents(uint256 _parent1, uint256 _parent2, uint256 _child) private {
        _parents[_child][0] = _parent1;
        _parents[_child][1] = _parent2;
    }

    function _getParents(uint256 _child) private view returns (uint256, uint256) {
        return (_parents[_child][0], _parents[_child][1]);
    }

    function _getPersonas(address _addr) private view returns (uint256[] memory) {
        return _personas[_addr];
    }

    function _setCooldown(uint256 _pId1, uint256 _pId2) private {
        // No cooldown is set for EVE
        if (_gender[_pId1] == Genetics.Gender.Female && _pId1 != EVE) {
            _coolDown[_pId1] = int256(block.timestamp);
        } else if (_gender[_pId2] == Genetics.Gender.Female && _pId2 != EVE) {
            _coolDown[_pId2] = int256(block.timestamp);
        }
    }

    function _copyChromosomeToStorage(uint256 _personaId, Genetics.Chromosome[2] memory _chr) private {
        // check that if this personaId has chromosomes, if it has, revert
        if (
            _chromosomes[_personaId][0].y > 0
                && (_chromosomes[_personaId][0].x[0] > 0 || _chromosomes[_personaId][0].x[1] > 0)
        ) {
            revert MetaPersona_InvalidGeneticCombination();
        }

        // x and y
        _copyChromosome(_personaId, 0, _chr[0]);
        _copyChromosome(_personaId, 1, _chr[1]);
        // autosomes
        for (uint256 i = 0; i < 37; i++) {
            _chromosomes[_personaId][0].autosomes[i] = _chr[0].autosomes[i];
            _chromosomes[_personaId][1].autosomes[i] = _chr[1].autosomes[i];
        }
    }

    function _copyChromosome(uint256 _personaId, uint256 _index, Genetics.Chromosome memory _source) private {
        _chromosomes[_personaId][_index].y = _source.y;
        _chromosomes[_personaId][_index].x[0] = _source.x[0];
        _chromosomes[_personaId][_index].x[1] = _source.x[1];
    }

    function _addChildAndSetParent(uint256 _parent1, uint256 _parent2, uint256 _child) private {
        _addChild(_parent1, _parent2, _child);
        _setParents(_parent1, _parent2, _child);
    }

    function _initializeChromosome(uint256[37] memory autosomes, uint256[2] memory x, uint192 y)
        private
        pure
        returns (Genetics.Chromosome memory)
    {
        return Genetics.Chromosome({autosomes: autosomes, x: x, y: y});
    }

    function _transferPersona(address from, address to, uint256 id) private {
        uint256 indexToRemove;
        for (uint256 i = 0; i < _personas[from].length; i++) {
            if (_personas[from][i] == id) {
                indexToRemove = i;
                break;
            }
        }

        _personas[from][indexToRemove] = _personas[from][_personas[from].length - 1];
        _personas[from].pop();

        _personas[to].push(id);
    }

    function _stake(address owner, uint256 id) private {
        _revertIfNotOwned(owner, id);

        if (_staked[id]) {
            revert MetaPersona_AlreadyStaked();
        }
        _staked[id] = true;
        _stakedAt[id] = block.timestamp;

        emit PersonaStaked(id);
    }

    function _unstake(address owner, uint256 id) private {
        _revertIfNotOwned(owner, id);

        if (!_staked[id]) {
            revert MetaPersona_NotStaked();
        }

        if (_stakedAt[id] + minStakeDuration >= block.timestamp) {
            revert MetaPersona_CantUnstakeUntil(_stakedAt[id] + minStakeDuration);
        }

        delete _staked[id];
        delete _stakedAt[id];

        // mint some MetaPersonas for owner
        uint256 reward = _fixedStakeReward + (4 * _getStakeMultiplier(id) * 1e14);

        _mint(owner, METAPERSONATOKEN, reward, "");
        emit PersonaUnstaked(id, reward);
    }

    function _getStakeMultiplier(uint256 id) private view returns (uint256) {
        uint256 partA = _chromosomes[id][0].autosomes[0] & 127;
        uint256 partB = _chromosomes[id][1].autosomes[0] & 127;
        return partA + partB + 1;
    }
}
