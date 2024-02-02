[![Tests](https://github.com/MetaPersona/Metapersona/actions/workflows/test.yml/badge.svg)](https://github.com/MetaPersona/Metapersona/blob/master/.github/workflows/test.yml)
# MetaPersona
## Project Description
The MetaPersona smart contract is a simplified model of human genome on blockchain!
We made a simple model of human chromosomes and then implemented it in solidity, each modeled human is called a Persona and each Persona is an NFT, we used Multi Token Standard ([ERC-1155](https://eips.ethereum.org/EIPS/eip-1155)) for this project so we could handle fungible and non-fungible tokens at same time with one contract. Lets first check some preliminary facts about chromosomes and then we'll get back to the MetaPersona.
### Chromosomes
Humans have 23 pair of chromosomes, 22 first pair of them are clled autosomes and both men and women have them, the 23rd pair are called sex chromosomes, females have 2 X chromosomes (XX) while men have one X and one Y chromosome (XY). Chromosomes are strands of DNA which itself consists of base pairs (double stranded dna), each base pair could have 4 combination (AT, TA, GC and CG). 
We all get our chromosomes from our parents, and we get one chromosome from each of our parents and inherit the genetical data from them, at meiosis, the chromosomes go through some steps and make gametes and then a gamete from male and a gamete from female could make a zygote and so on and so forth...
There are rougly around 3 billion base pairs in human genome, each base pair has 4 possible combination so if we want to make a better model we need to have 3e9 * 2 bits to save the possible base pairs, this is the minimum amount for a basic model which by the way does not consider the MT base pairs.
This was a very very concise description of the chromosomes and the way they combine to make a human being.
### Personas
We modeled chromosomes as structs in solidity
a chromosome struct is 
```solidity
struct Chromosome {
        uint256[37] autosomes;
        uint256[2] x;
        uint192 y;
    }
```
Our modeled chromosomes has a length of 10176 bits, this length is proportional to the real human chromosomes (that 3e9 base pairs), for arriving at this length we took the chromosome 21 as the reference chromosome and then calculated the length of other chromosomes according to their real length, then bucketized (devidable by 8) the values in uint256 and created the chromosome struct.

#### Genesis
The `MetaPersona.s.sol` deploys the contract and then runs a genesis function to make the Adam (male persona) and Eve (female persona) and mints them for contract deployer. then contract deployer could use `spawn` function to make new personas for himself/herself  or for a `_receiver` address,
#### Spawning
If anyone own two male and female Personas, then they could call the `spawn` function to spawn a new Persona. There are two `spawn` functions in the contract, one of them is only could be called by someone with `SPAWN_ROLE`, since the amount of calculation and data saving is alot in this contract, we made a companion api to lower the gas cost for Persona spawning, the meiosis (and crossover of chromosomes) are done offchain and then the web api spawns the Persona for requester, this way we lowered the gas cost by 50% comparing to onchain spawning.
#### Staking
Users could stake their Personas for some `METAPERSONA` token, the amount of `METAPERSONA` token generated for Personas is different and it depends on their genes, when a Persona is staked, it cannot spawn a new Persona. Users could use the `METAPERSONA` rewards to pay for fees and use it in Life Forge.
#### Life Forge
Not all users could have a pair of male and female Personas to spawn a new Persona, so they can use Life Forge, users could add their Personas to Life Forge to get some `METAPERSONA` tokens, and other users could pay them to spawn a new Persona using their Persona.
#### Functionality
All functionality is implemented in the smart contract and tests are written to check them, everyone could call external functions of the smart contract. There's a [website](https://www.metapersona.fun) which is designed using Blazor wasm, but it's not ready yet.
The code for [website](https://github.com/MetaPersona/MetaPersonaWeb) and (webapi)[https://github.com/MetaPersona/MetaPersonaApi] is available in their respective repos.
Both web and webapi projects could be deployed using docker, simply call the following command in the root of each project to build and compose them.
```shell
$ docker compose up -d
```
The api is deployed to this (address)[https://www.metapersona.fun/api] and it could be tested, e.g. call the following public anonymous endpoint to get the contract address
```shell
$ curl https://metapersona.fun/api/metapersona/contract
```
## Smart Contract
This is the MetaPersona contract, we used Foundry as the toolkit to work with the blockchain and testing, you could easily install the Foundry and then test the code, for installing the Foundry you could use Foundryup:
```shell
$ curl -L https://foundry.paradigm.xyz | bash
```
This will install Foundryup, then simply follow the instructions on-screen, which will make the foundryup command available in your CLI. The foundry book is the best source to work with foundry, you can find it [here](https://book.getfoundry.sh/).

After installing the Foundry, simply clone this project and build it.
```shell
$ git clone https://github.com/MetaPersona/Metapersona.git
```
### Build
You need to build the project first, when run for the first time, forge gets the required libraries first and then compiles the project.
```shell
$ forge build
```

### Test
Since we used openssl to generate random numbers in the test file (and deploy script), you have to use --ffi switch to allow commands to run.
The test script uses some environment variables, you could set them using the .env.example file (the instructions are [here](https://github.com/MetaPersona/Metapersona#set-environment-variables)).
```shell
$ forge test --ffi
```

### Deploy
If you want to deploy the contract yourself, first you need to set the environment variables:

#### Set environment variables

rename the `.env.example` file to `.env`

```shell
$ mv .env.example .env
```

Optionally remove the `.env.example`

```shell
$ rm .env.example
```

Set the environment variables in the `.env`, and then run

```shell
$ source .env
```


You could use `unset.env.sh` to unset the configured environment variables

```shell
$ source ./unset.env.sh
```
After setting the .env file, you could use the following command to deploy the contract:
```shell
$ forge script --ffi ./script/MetaPersona.s.sol --rpc-url $AREON_TESTNET_RPC_URL --private-key $PRIVATE_KEY 
```

The contract is deployed on Aeron Network [testnet](https://areonscan.com/contracts/0xc758b2ecd4bff53a2586f79ab9436617a884ca85).
