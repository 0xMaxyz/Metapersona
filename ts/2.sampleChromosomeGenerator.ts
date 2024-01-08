import { ethers } from "ethers";

interface Chromatid {
  DNA: BigInt[];
}

interface Chromosome {
  chromatid: Chromatid;
}

interface Chromosomes {
  chromosomes: Chromosome[];
}

function generateRandomBigInt(): BigInt {
  return ethers.toBigInt(Math.floor(Math.random() * 1000000));
}

function generateChromatid(): Chromatid {
  const DNA: BigInt[] = Array(39)
    .fill(0)
    .map(() => generateRandomBigInt());
  return { DNA };
}

function generateChromosome(): Chromosome {
  const chromatid = generateChromatid();
  return { chromatid };
}

function generateChromosomes(): Chromosomes {
  const chromosomes: Chromosome[] = Array(3)
    .fill(0)
    .map(() => generateChromosome());
  return { chromosomes };
}

