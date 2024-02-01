// SPDX-License-Identifier: MIT
pragma solidity ^0.8.23;

error MetaPersona_InvalidGeneticalDataInput(string);
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
error MetaPersona_PersonaInCooldown();
error MetaPersona_PersonaIsMining();
error MetaPersona_NoURI();
error MetaPersona_NotAuthorized();
error MetaPersona_CantSpawnWhenStaked();
error MetaPersona_AlreadyStaked();
error MetaPersona_NotStaked();
error MetaPersona_CantUnstakeUntil(uint256);
