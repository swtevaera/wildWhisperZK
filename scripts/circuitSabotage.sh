#!/bin/sh
set -e

# --------------------------------------------------------------------------------
# Phase 2
# ... circuit-specific stuff

# if zk/zkey does not exist, make folder
[ -d zk/zkey ] || mkdir zk/zkey

# Compile circuits
circom zk/circuits/sabotage.circom -o zk/ --r1cs --wasm


#Setup
yarn snarkjs groth16 setup zk/sabotage.r1cs zk/ptau/pot15_final.ptau zk/zkey/sabotage_final.zkey

# # Generate reference zkey
yarn snarkjs zkey new zk/sabotage.r1cs zk/ptau/pot15_final.ptau zk/zkey/sabotage_0000.zkey

# # Ceremony just like before but for zkey this time
yarn snarkjs zkey contribute zk/zkey/sabotage_0000.zkey zk/zkey/sabotage_0001.zkey \
    --name="First sabotage contribution" -v -e="$(head -n 4096 /dev/urandom | openssl sha1)"

yarn snarkjs zkey contribute zk/zkey/sabotage_0001.zkey zk/zkey/sabotage_0002.zkey \
    --name="Second sabotage contribution" -v -e="$(head -n 4096 /dev/urandom | openssl sha1)"

yarn snarkjs zkey contribute zk/zkey/sabotage_0002.zkey zk/zkey/sabotage_0003.zkey \
    --name="Third sabotage contribution" -v -e="$(head -n 4096 /dev/urandom | openssl sha1)"

# #  Verify zkey
yarn snarkjs zkey verify zk/sabotage.r1cs zk/ptau/pot15_final.ptau zk/zkey/sabotage_0003.zkey

# # Apply random beacon as before
yarn snarkjs zkey beacon zk/zkey/sabotage_0003.zkey zk/zkey/sabotage_final.zkey \
    0102030405060708090a0b0c0d0e0f101112131415161718191a1b1c1d1e1f 10 -n="sabotage FinalBeacon phase2"


# # Optional: verify final zkey
yarn snarkjs zkey verify zk/sabotage.r1cs zk/ptau/pot15_final.ptau zk/zkey/sabotage_final.zkey

# # Export verification key
yarn snarkjs zkey export verificationkey zk/zkey/sabotage_final.zkey zk/sabotage_verification_key.json

# Export sabotage verifier with updated name and solidity version
yarn snarkjs zkey export solidityverifier zk/zkey/sabotage_final.zkey contracts/sabotageVerifier.sol
# sed -i'.bak' 's/0.6.11;/0.8.11;/g' contracts/sabotageVerifier.sol
sed -i'.bak' 's/contract Verifier/contract sabotageVerifier/g' contracts/sabotageVerifier.sol

# Export sabotage verifier constract with updated name and solidity version

rm contracts/*.bak
