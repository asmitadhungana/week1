#!/bin/bash

cd contracts/circuits

mkdir SudokuModified

if [ -f ./powersOfTau28_hez_final_17.ptau ]; then
    echo "powersOfTau28_hez_final_17.ptau already exists. Skipping."
else
    echo 'Downloading powersOfTau28_hez_final_17.ptau'
    wget https://hermez.s3-eu-west-1.amazonaws.com/powersOfTau28_hez_final_17.ptau
fi

echo "Compiling: sudoku..."

# compile circuit

circom sudokuModified.circom --r1cs --wasm --sym -o SudokuModified
snarkjs r1cs info SudokuModified/SudokuModified.r1cs

# Start a new zkey and make a contribution

if [ -f ./SudokuModified/verification_key.json ]; then
    echo "verification_key.json already exists. Skipping."
else
    snarkjs plonk setup SudokuModified/SudokuModified.r1cs powersOfTau28_hez_final_17.ptau SudokuModified/circuit_final.zkey #circuit_0000.zkey
    snarkjs zkey export verificationkey SudokuModified/circuit_final.zkey SudokuModified/verification_key.json
fi

# Generate solidity contract
snarkjs zkey export solidityverifier SudokuModified/circuit_final.zkey ../SudokuModifiedVerifier.sol

cd ../..