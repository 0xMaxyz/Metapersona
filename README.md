[![Tests](https://github.com/MetaPersona/Metapersona/actions/workflows/test.yml/badge.svg)](https://github.com/MetaPersona/Metapersona/blob/master/.github/workflows/test.yml)
## MetaPersona
# Project Description


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
The test script uses some environment variables, you could set them using the .env.example file (the instructions are below).
```shell
$ forge test --ffi
```

### Deploy
If you want to deploy the contract yourself, first you need to set the environment variables:

## Set environment variables

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
