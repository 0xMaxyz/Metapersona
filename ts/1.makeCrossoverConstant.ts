import { ethers } from "ethers";

const numberOfCrossovers: number[] = [3, 4, 5, 6, 7, 8, 9, 10];
// const numberOfCrossovers: number[] = [
//   3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18,
// ];

function encodePackedValues(values: number[]): string {
  const packedData = ethers.solidityPacked(
    Array(values.length).fill("uint8"),
    values
  );
  return packedData;
}

const encodedData = encodePackedValues(numberOfCrossovers);

console.log("Encoded data:", encodedData);
