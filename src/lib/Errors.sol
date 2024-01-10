// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

library Errors {
    error MetaPersona_InvalidGeneticalDataInput(string genes);
    error MetaPersona_InvalidInputString();
    error MetaPersona_InvalidInputCharacter();
    error MetaPersona_InvalidFunctionArgs();
    error MetaPersona_InvalidHexChar();
    error MetaPersona_InvalidInputGeneticData();

    error MetaPersona_PersonaNotFound();
    error MetaPersona_PersonaNotOwnedByYou();

    error MetaPersona_WrongGender();
    error MetaPersona_IncompatiblePersonas();

    error MetaPersona_InvalidInput();
    error MetaPersona_MaxCrossoversReached();

    error MetaPersona_NotMutable();
    error MetaPersona_InvalidChromosome();
    error MetaPersona_InvalidGeneticCombination();
}
