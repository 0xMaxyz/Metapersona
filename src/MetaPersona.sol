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
    uint256 public PersonaId;
    uint256 public GenesisTimestamp;
    uint256 public SpawnFee = 0.001 ether;

    uint256 private constant METAPERSONATOKEN = 0;
    uint256 private constant ADAM = 1;
    uint256 private constant EVE = 2;
    uint256 private coolDownLength = 2 days;
    uint256 public MinStakeDuration = 2 days;
    uint256 private seed;
    uint256 private fixedStakeReward = 0.01 ether;
    uint256 private transferFee = 0.0001 ether;

    uint256 private testsSpawned = 0;
    mapping(address => uint256) public TestsSpawned;

    mapping(address => uint256[]) private personas;
    mapping(uint256 => uint256[]) private children;
    mapping(uint256 => uint256) private coolDown;
    mapping(uint256 => Genetics.Gender) private personaGenders;
    mapping(uint256 => uint256[2]) private personaParents;
    mapping(uint256 => Genetics.Chromosome[2]) private personaChromosomes;

    mapping(uint256 => bool) private personaStaked;
    mapping(uint256 => uint256) private personaStakedAt;
    mapping(uint256 => bool) private personaInLifeForge;
    mapping(uint256 => uint256) private lifeForgePricePerPersona;

    uint256[] private personasInLifeForge;

    event PersonaAddedToLifeForge(uint256 id);
    event PersonaLeftLifeForge(uint256 id);

    event Genesis(uint256 indexed timestamp);
    event NewPersonaBorn(uint256 indexed _personaId, address indexed receiver);
    event PersonaStaked(uint256 indexed _personaId);
    event PersonaUnstaked(uint256 indexed _personaId, uint256 indexed reward);
    event SpawnFeeChanged(uint256 indexed newFee);
    event CooldownChanged(uint256 indexed newCooldown);

    constructor(address admin, string memory _uri, uint256 _seed) ERC1155(_uri) {
        _grantRole(DEFAULT_ADMIN_ROLE, admin);
        _grantRole(SPAWN_ROLE, admin);

        // initialize storage
        seed = _seed;
        PersonaId = 1;
        // mint MP for deployer, used for testing
        _mint(msg.sender, METAPERSONATOKEN, 10_000 ether, "");
    }

    modifier GenesisOnce() {
        require(GenesisTimestamp == 0, "Genesis has happened before");

        _;

        GenesisTimestamp = block.timestamp;
        emit Genesis(block.timestamp);

        PersonaId += 2;
        personas[msg.sender].push(ADAM);
        personas[msg.sender].push(EVE);

        personaGenders[ADAM] = Genetics.Gender.Male;
        personaGenders[EVE] = Genetics.Gender.Female;
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

    function SetCooldown(uint256 _cdLength) external onlyRole(DEFAULT_ADMIN_ROLE) {
        coolDownLength = _cdLength;
        emit CooldownChanged(_cdLength);
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

    function setSpawnFee(uint256 _fee) external onlyRole(DEFAULT_ADMIN_ROLE) {
        SpawnFee = _fee;
        emit SpawnFeeChanged(_fee);
    }

    function spawn(uint256 _personaId1, uint256 _personaId2, address _receiver) external payable returns (uint256) {
        // revert if SpawnFee was not sent
        if (msg.value < SpawnFee) {
            revert MetaPersona_SpawnFeeRequired(SpawnFee);
        }
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

        return _spawnCore(_personaId1, _personaId2, _chr, _receiver);
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

    function addPersonaToLifeForge(uint256 _personaId, uint256 _forgePrice) external {
        _addPersonaToForge(msg.sender, _personaId, _forgePrice);
    }

    function addPersonaToLifeForge(address _personaOwner, uint256 _personaId, uint256 _forgePrice)
        external
        onlyRole(SPAWN_ROLE)
    {
        _addPersonaToForge(_personaOwner, _personaId, _forgePrice);
    }

    function removePersonaFromLifeForge(uint256 _id) external {
        _removePersonaFromForge(msg.sender, _id);
    }

    function removePersonaFromLifeForge(address _owner, uint256 _id) external onlyRole(SPAWN_ROLE) {
        _removePersonaFromForge(_owner, _id);
    }

    function useLifeForge(uint256 _id, address _idInForgeOwner, uint256 _idInForge) external {
        _useLifeForge(msg.sender, _id, _idInForgeOwner, _idInForge);
    }

    function useLifeForge(
        address _owner,
        uint256 _id,
        address _idInForgeOwner,
        uint256 _idInForge,
        Genetics.Chromosome[2] memory _chr
    ) external onlyRole(SPAWN_ROLE) {
        // be sure to call checkUseForgeConditions before calling this function
        _useLifeForgeAsSpawner(_owner, _id, _idInForgeOwner, _idInForge, _chr);
    }

    function checkUseForgeConditions(address _owner, uint256 _id, uint256 _idInForge)
        external
        view
        onlyRole(SPAWN_ROLE)
    {
        _checkUseForgeConditions(_owner, _id, _idInForge);
    }

    function spawnTestPersonas(address _receiver) public returns (uint256) {
        require(testsSpawned <= 400, "All test personas are spawned");
        require(TestsSpawned[_receiver] <= 2, "You received your test personas before");

        testsSpawned += 1;
        TestsSpawned[_receiver] += 1;

        return _spawnBase(1, 2, _receiver, false);
    }

    function canSpawnTestPersona(address _receiver) public view returns (bool) {
        return (testsSpawned <= 400) && (TestsSpawned[_receiver] <= 2);
    }

    function spawnTestPersonas(address _receiver, Genetics.Chromosome[2] memory _chr)
        public
        onlyRole(SPAWN_ROLE)
        returns (uint256)
    {
        require(testsSpawned <= 400, "All test personas are spawned");
        require(TestsSpawned[_receiver] <= 2, "You received your test personas before");

        testsSpawned += 1;
        TestsSpawned[_receiver] += 1;

        return _spawnCore(1, 2, _chr, _receiver);
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
            return personaGenders[_pId];
        }
        _revertIfNotOwned(msg.sender, _pId);
        return personaGenders[_pId];
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

    function getPersonasInLifeForge() external view returns (uint256[] memory) {
        return personasInLifeForge;
    }

    // ---------------------------------- //
    //          Private functions         //
    // ---------------------------------- //

    function _getChromosomes(address _owner, uint256 _personaId) private view returns (Genetics.Chromosome[2] memory) {
        _revertIfNotOwned(_owner, _personaId);

        return personaChromosomes[_personaId];
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
        if (personaStaked[id]) {
            revert MetaPersona_CantSpawnWhenStaked();
        }
    }

    function _revertIfInLifeForge(uint256 id) private view {
        if (personaInLifeForge[id]) {
            revert MetaPersona_PersonaInLifeForge();
        }
    }

    function _checkCooldown(uint256 _pid1, uint256 _pid2) private view {
        if (
            personaGenders[_pid1] == Genetics.Gender.Female && coolDown[_pid1] > 0
                && (coolDown[_pid1] + coolDownLength > block.timestamp)
        ) {
            revert MetaPersona_PersonaInCooldown();
        }
        if (
            personaGenders[_pid2] == Genetics.Gender.Female && coolDown[_pid2] > 0
                && (coolDown[_pid2] + coolDownLength > block.timestamp)
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

        return _spawnBase(_personaId1, _personaId2, _receiver, true);
    }

    function _checkValidMaleFemaleCombination(uint256 id1, uint256 id2) private view {
        bool condition = (personaGenders[id1] == Genetics.Gender.Female && personaGenders[id2] == Genetics.Gender.Male)
            || (personaGenders[id1] == Genetics.Gender.Male && personaGenders[id2] == Genetics.Gender.Female);
        if (!condition) {
            revert MetaPersona_IncompatiblePersonas();
        }
    }

    function _spawnBase(uint256 _personaId1, uint256 _personaId2, address _receiver, bool _runInitialTests)
        private
        returns (uint256)
    {
        if (_runInitialTests) {
            _checkValidMaleFemaleCombination(_personaId1, _personaId2);

            // Check cooldown
            _checkCooldown(_personaId1, _personaId2);
        }

        Random.RandomArgs memory rArgs;
        uint256 rand;

        rArgs.Prevrandao = block.prevrandao;
        rArgs.Sender = msg.sender;
        rArgs.Timestamp = block.timestamp;
        // get gametes
        Genetics.Chromosome memory persona1_gamete;
        Genetics.Chromosome memory persona2_gamete;

        (persona1_gamete, rand) = ChromosomeLib.meiosis1Chr(personaChromosomes[_personaId1], seed, rArgs);
        (persona2_gamete, rand) = ChromosomeLib.meiosis1Chr(personaChromosomes[_personaId2], rand, rArgs);

        seed = rand; // update seed state value

        return _spawnCore(_personaId1, _personaId2, [persona1_gamete, persona2_gamete], _receiver);
    }

    function _spawnCore(uint256 _personaId1, uint256 _personaId2, Genetics.Chromosome[2] memory _chr, address _receiver)
        private
        returns (uint256)
    {
        uint256 newPersonaId = _makeNewPersona(_receiver, PersonaId++);
        _copyChromosomeToStorage(newPersonaId, _chr);

        emit NewPersonaBorn(newPersonaId, _receiver);

        personas[_receiver].push(newPersonaId);

        _addChildAndSetParent(_personaId1, _personaId2, newPersonaId);

        // set gender
        Genetics.Gender childGender = Genetics.getGender(_chr);
        personaGenders[newPersonaId] = childGender;

        // set cooldown for daughter
        if (childGender == Genetics.Gender.Female) {
            coolDown[newPersonaId] = block.timestamp;
        }

        // set cooldown for mother
        _setCooldown(_personaId1, _personaId2);

        return newPersonaId;
    }

    function _addChild(uint256 _pid1, uint256 _pid2, uint256 childId) private {
        (uint256 smaller, uint256 larger) = _pid1 < _pid2 ? (_pid1, _pid2) : (_pid2, _pid1);
        uint256 key = uint256(keccak256(abi.encodePacked(smaller, larger)));
        children[key].push(childId);
    }

    function _getChildren(uint256 _pid1, uint256 _pid2) private view returns (uint256[] memory) {
        (uint256 smaller, uint256 larger) = _pid1 < _pid2 ? (_pid1, _pid2) : (_pid2, _pid1);
        uint256 key = uint256(keccak256(abi.encodePacked(smaller, larger)));
        return children[key];
    }

    function _setParents(uint256 _parent1, uint256 _parent2, uint256 _child) private {
        personaParents[_child][0] = _parent1;
        personaParents[_child][1] = _parent2;
    }

    function _getParents(uint256 _child) private view returns (uint256, uint256) {
        return (personaParents[_child][0], personaParents[_child][1]);
    }

    function _getPersonas(address _addr) private view returns (uint256[] memory) {
        return personas[_addr];
    }

    function _setCooldown(uint256 _pId1, uint256 _pId2) private {
        // No cooldown is set for EVE
        if (personaGenders[_pId1] == Genetics.Gender.Female && _pId1 != EVE) {
            coolDown[_pId1] = block.timestamp;
        } else if (personaGenders[_pId2] == Genetics.Gender.Female && _pId2 != EVE) {
            coolDown[_pId2] = block.timestamp;
        }
    }

    function _copyChromosomeToStorage(uint256 _personaId, Genetics.Chromosome[2] memory _chr) private {
        // check that if this PersonaId has chromosomes, if it has, revert
        if (
            personaChromosomes[_personaId][0].y > 0
                && (personaChromosomes[_personaId][0].x[0] > 0 || personaChromosomes[_personaId][0].x[1] > 0)
        ) {
            revert MetaPersona_InvalidGeneticCombination();
        }

        // x and y
        _copyChromosome(_personaId, 0, _chr[0]);
        _copyChromosome(_personaId, 1, _chr[1]);
        // autosomes
        for (uint256 i = 0; i < 37; i++) {
            personaChromosomes[_personaId][0].autosomes[i] = _chr[0].autosomes[i];
            personaChromosomes[_personaId][1].autosomes[i] = _chr[1].autosomes[i];
        }
    }

    function _copyChromosome(uint256 _personaId, uint256 _index, Genetics.Chromosome memory _source) private {
        personaChromosomes[_personaId][_index].y = _source.y;
        personaChromosomes[_personaId][_index].x[0] = _source.x[0];
        personaChromosomes[_personaId][_index].x[1] = _source.x[1];
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
        for (uint256 i = 0; i < personas[from].length; i++) {
            if (personas[from][i] == id) {
                indexToRemove = i;
                break;
            }
        }

        personas[from][indexToRemove] = personas[from][personas[from].length - 1];
        personas[from].pop();

        personas[to].push(id);
    }

    function _stake(address owner, uint256 id) private {
        _revertIfNotOwned(owner, id);
        _revertIfInLifeForge(id);

        if (personaStaked[id]) {
            revert MetaPersona_AlreadyStaked();
        }
        personaStaked[id] = true;
        personaStakedAt[id] = block.timestamp;

        emit PersonaStaked(id);
    }

    function _unstake(address owner, uint256 id) private {
        _revertIfNotOwned(owner, id);

        if (!personaStaked[id]) {
            revert MetaPersona_NotStaked();
        }

        if (personaStakedAt[id] + MinStakeDuration >= block.timestamp) {
            revert MetaPersona_CantUnstakeUntil(personaStakedAt[id] + MinStakeDuration);
        }

        delete personaStaked[id];
        delete personaStakedAt[id];

        // mint some MetaPersonas for owner
        uint256 reward = fixedStakeReward + (4 * _getStakeMultiplier(id) * 1e14);

        _mint(owner, METAPERSONATOKEN, reward, "");
        emit PersonaUnstaked(id, reward);
    }

    function _getStakeMultiplier(uint256 id) private view returns (uint256) {
        uint256 partA = personaChromosomes[id][0].autosomes[0] & 127;
        uint256 partB = personaChromosomes[id][1].autosomes[0] & 127;
        return partA + partB + 1;
    }

    function _addPersonaToForge(address owner, uint256 id, uint256 price) private {
        // revert if not owned by owner
        _revertIfNotOwned(owner, id);
        // revert if staked
        _revertIfStaked(id);
        // revert if in forge
        if (personaInLifeForge[id]) {
            revert MetaPersona_AlreadyInForge(id);
        }

        personaInLifeForge[id] = true;
        lifeForgePricePerPersona[id] = price;
        personasInLifeForge.push(id);

        emit PersonaAddedToLifeForge(id);
    }

    function _removePersonaFromForge(address owner, uint256 id) private {
        // revert if not owned by owner
        _revertIfNotOwned(owner, id);
        // revert if in forge
        if (!personaInLifeForge[id]) {
            revert MetaPersona_PersonaNotInForge(id);
        }

        delete personaInLifeForge[id];
        delete lifeForgePricePerPersona[id];

        // remove id from personasInLifeForge
        uint256 idIndex;
        for (uint256 i = 0; i < personasInLifeForge.length; i++) {
            if (personasInLifeForge[i] == id) {
                idIndex = i;
                break;
            }
        }
        personasInLifeForge[idIndex] = personasInLifeForge[personasInLifeForge.length - 1];
        personasInLifeForge.pop();

        emit PersonaLeftLifeForge(id);
    }

    function _useLifeForge(address owner, uint256 id, address idInForgeOwner, uint256 idInForge) private {
        _checkUseForgeConditions(owner, id, idInForge);

        // transfer tokens
        _safeTransferFrom(owner, idInForgeOwner, METAPERSONATOKEN, lifeForgePricePerPersona[idInForge], "");
        _burn(owner, METAPERSONATOKEN, transferFee); // burn the transfer fee
        // can spawn a new persona
        _spawnBase(id, idInForge, owner, false);
    }

    function _useLifeForgeAsSpawner(
        address _owner,
        uint256 _id,
        address _idInForgeOwner,
        uint256 _idInForge,
        Genetics.Chromosome[2] memory _chr
    ) private onlyRole(SPAWN_ROLE) {
        // the checks shall be run by the spawner before, otherwise it may revert or transfer without authorization from owner
        _safeTransferFrom(_owner, _idInForgeOwner, METAPERSONATOKEN, lifeForgePricePerPersona[_idInForge], "");
        _burn(_owner, METAPERSONATOKEN, transferFee); // burn the transfer fee
        // can spawn a new persona
        _spawnCore(_id, _idInForge, _chr, _owner);
    }

    function _checkForRequiredBalance(address _payee, uint256 _requiredBalance) private view {
        if (balanceOf(_payee, METAPERSONATOKEN) < transferFee + _requiredBalance) {
            revert MetaPersona_NotEnoughMetaPersonaToken();
        }
    }

    function _checkUseForgeConditions(address _owner, uint256 _id, uint256 _idInForge) private view {
        _revertIfNotOwned(_owner, _id);
        _revertIfStaked(_id);
        if (!personaInLifeForge[_idInForge]) {
            revert MetaPersona_PersonaNotInForge(_idInForge);
        }
        // check for enough token
        _checkForRequiredBalance(_owner, lifeForgePricePerPersona[_idInForge]);
        // check for compatibility and cooldown
        _checkValidMaleFemaleCombination(_id, _idInForge);
        _checkCooldown(_id, _idInForge);
    }

    receive() external payable {
        // recieve tokens sent to contract without calldata
    }
    fallback() external payable {
        // recieve tokens sent to contract
    }
}
