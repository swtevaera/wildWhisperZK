#!/bin/sh
set -e

# --------------------------------------------------------------------------------
# Phase 2
# ... circuit-specific stuff

# if zk/zkey does not exist, make folder
[ -d zk/zkey ] || mkdir zk/zkey

# Compile circuits
circom zk/circuits/killproof.circom -o zk/ --r1cs --wasm


#Setup
yarn snarkjs groth16 setup zk/killproof.r1cs zk/ptau/pot15_final.ptau zk/zkey/killproof_final.zkey

# # Generate reference zkey
yarn snarkjs zkey new zk/killproof.r1cs zk/ptau/pot15_final.ptau zk/zkey/killproof_0000.zkey

# # Ceremony just like before but for zkey this time
yarn snarkjs zkey contribute zk/zkey/killproof_0000.zkey zk/zkey/killproof_0001.zkey \
    --name="First killproof contribution" -v -e="$(head -n 4096 /dev/urandom | openssl sha1)"

yarn snarkjs zkey contribute zk/zkey/killproof_0001.zkey zk/zkey/killproof_0002.zkey \
    --name="Second killproof contribution" -v -e="$(head -n 4096 /dev/urandom | openssl sha1)"

yarn snarkjs zkey contribute zk/zkey/killproof_0002.zkey zk/zkey/killproof_0003.zkey \
    --name="Third killproof contribution" -v -e="$(head -n 4096 /dev/urandom | openssl sha1)"

# #  Verify zkey
yarn snarkjs zkey verify zk/killproof.r1cs zk/ptau/pot15_final.ptau zk/zkey/killproof_0003.zkey

# # Apply random beacon as before
yarn snarkjs zkey beacon zk/zkey/killproof_0003.zkey zk/zkey/killproof_final.zkey \
    0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="killproof FinalBeacon phase2"


# # Optional: verify final zkey
yarn snarkjs zkey verify zk/killproof.r1cs zk/ptau/pot15_final.ptau zk/zkey/killproof_final.zkey

# # Export verification key
yarn snarkjs zkey export verificationkey zk/zkey/killproof_final.zkey zk/killproof_verification_key.json

# Export killproof verifier with updated name and solidity version
yarn snarkjs zkey export solidityverifier zk/zkey/killproof_final.zkey contracts/killproofVerifier.sol
# sed -i'.bak' 's/0.6.11;/0.8.11;/g' contracts/killproofVerifier.sol
sed -i'.bak' 's/contract Verifier/contract killproofVerifier/g' contracts/killproofVerifier.sol

# Export killproof verifier constract with updated name and solidity version

rm contracts/*.bak
