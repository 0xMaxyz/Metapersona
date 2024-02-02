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
We modeled chromosomes 


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
