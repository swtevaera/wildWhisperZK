const snarkjs = require("snarkjs");

const fs = require("fs");

const roleWasmImpostor = "../circom/zk/impostor_js/impostor.wasm";
const finalKeyImpostor = "../circom/zk/zkey/impostor_final.zkey";

const roleWasmSabotage = "../circom/zk/sabotage_js/sabotage.wasm";
const finalKeySabotage = "../circom/zk/zkey/sabotage_final.zkey";
const verificationKeyPathSabotage = "../circom/zk/sabotage_verification_key.json";

async function run() {

    // Inputs for Circuit
    // Impostor inputs
    // Generate random values for secret and nonce Impostor
    const secretImpostor = 1;   // 1 is secret value for impostor
    const nonceImpostor = Math.floor(Math.random() * (2**248)); // Random integer within range [0, 2^248)
    console.log("Secret Impostor:", secretImpostor);
    console.log("Nonce Impostor:", nonceImpostor);

    const inputImpostor = { secret: BigInt(secretImpostor), nonce: BigInt(nonceImpostor) };
    var { proof, publicSignals } = await snarkjs.groth16.fullProve(inputImpostor, roleWasmImpostor, finalKeyImpostor);
    const proofImpostor = proof;
    const publicSignalsImpostor = publicSignals;

    console.log("Proof Impostor: ",proofImpostor);
    console.log(JSON.stringify(proofImpostor, null, 1));
    console.log("input Impostor", inputImpostor);
    console.log("Public Inputs Impostor", publicSignalsImpostor);

    // Sabotage Active Proof Circuit
    const sabotageIndex = 0;
    const inputSabotage = { sabotage_index: BigInt(sabotageIndex), impostor_proof_nonce:BigInt(nonceImpostor),impostor_proof_secret: BigInt(secretImpostor),impostor_commitement:publicSignalsImpostor[0]};
    var { proof, publicSignals} = await snarkjs.groth16.fullProve(inputSabotage, roleWasmSabotage, finalKeySabotage);
    const proofSabotage = proof;
    const publicSignalsSabotage = publicSignals;

    console.log("Proof Sabotage: ");
    console.log(JSON.stringify(proofSabotage, null, 1));
    console.log("input Sabotage", inputSabotage);
    console.log("Public Inputs Sabotage", publicSignalsSabotage);


    const solidityCallData = await snarkjs.groth16.exportSolidityCallData(proofSabotage,publicSignalsSabotage);
    console.log("solidityCallData",solidityCallData);
    const vKey = JSON.parse(fs.readFileSync(verificationKeyPathSabotage));
    const res = await snarkjs.groth16.verify(vKey, [`${publicSignalsSabotage}`], proofSabotage);


    console.log("Result", res);

    if (res === true) {
        console.log("Verification OK");
    } else {
        console.log("Invalid proof");
    }

}

// run();
run().then(() => {
    process.exit(0);
});