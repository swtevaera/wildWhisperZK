const snarkjs = require("snarkjs");

const fs = require("fs");

// current directory 
const roleWasmImpostor = "../circom/zk/impostor_js/impostor.wasm";
const finalKeyImpostor = "../circom/zk/zkey/impostor_final.zkey";

const roleWasmCrewmate = "../circom/zk/crewmate_js/crewmate.wasm";
const finalKeyCrewmate = "../circom/zk/zkey/crewmate_final.zkey";

const roleWasmKillProof = "../circom/zk/killproof_js/killproof.wasm";
const finalKeyKillProof = "../circom/zk/zkey/killproof_final.zkey";
const verificationKeyPathKillProof = "../circom/zk/killproof_verification_key.json";

async function run() {

    // Inputs for Circuit
    // Crewmate inputs
    // Generate random values for secret and nonce Crewmate
    const secretCrewmate = 0;   // 0 is secret value for impostor
    const nonceCrewmate = Math.floor(Math.random() * (2**248)); // Random integer within range [0, 2^248)
    console.log("Secret Crewmate:", secretCrewmate);
    console.log("Nonce Crewmate:", nonceCrewmate);

    const inputCrewmate = { secret: BigInt(secretCrewmate), nonce: BigInt(nonceCrewmate) }; 
    var { proof, publicSignals } = await snarkjs.groth16.fullProve(inputCrewmate, roleWasmCrewmate, finalKeyCrewmate);
    const proofCrewmate = proof;
    const publicSignalsCrewmate = publicSignals;

    console.log("Proof Crewmate: ",proofCrewmate);
    console.log(JSON.stringify(proofCrewmate, null, 1));
    console.log("input Crewmate", inputCrewmate);
    console.log("Public Inputs Crewmate", publicSignalsCrewmate);

    // Impostor inputs
    // Generate random values for secret and nonce Impostor
    const secretImpostor = 1;   // 0 is secret value for impostor
    const nonceImpostor = Math.floor(Math.random() * (2**248)); // Random integer within range [0, 2^248)
    console.log("Secret Impostor:", secretImpostor);
    console.log("Nonce Impostor:", nonceImpostor);

    const inputImpostor = { secret: BigInt(secretImpostor), nonce: BigInt(nonceImpostor) }; 
    var { proof, publicSignals } = await snarkjs.groth16.fullProve(inputImpostor, roleWasmImpostor, finalKeyImpostor);
    const publicSignalsImpostor = publicSignals;
    const proofImpostor = proof;
    console.log("Proof Impostor: ");
    console.log(JSON.stringify(proofImpostor, null, 1));
    console.log("input Impostor", inputImpostor);
    console.log("Public Inputs Impostor", publicSignalsImpostor);


    // Kill Proof Circuit
    const inputKillProof = { impostor_proof_nonce: BigInt(nonceImpostor), impostor_proof_secret: BigInt(secretImpostor), impostor_commitement:publicSignalsImpostor[0],crewmate_proof_nonce:BigInt(nonceCrewmate),crewmate_proof_secret: BigInt(secretCrewmate),crewmate_commitement:publicSignalsCrewmate[0]}; 
    var { proof, publicSignals} = await snarkjs.groth16.fullProve(inputKillProof, roleWasmKillProof, finalKeyKillProof);
    const proofKillProof = proof;
    const publicSignalsKillProof = publicSignals;

    console.log("Proof KillProof: ");
    console.log(JSON.stringify(proofKillProof, null, 1));
    console.log("input KillProof", inputKillProof);
    console.log("Public Inputs KillProof", publicSignalsKillProof);


    const solidityCallData = await snarkjs.groth16.exportSolidityCallData(proofKillProof,publicSignalsKillProof);
    console.log("solidityCallData",solidityCallData);
    const vKey = JSON.parse(fs.readFileSync(verificationKeyPathKillProof));
    // const res = await snarkjs.groth16.verify(
    //     {_vk_verifier: vKey, _publicSignals:[""], _proof: proofKillProof}
    // );
    
    // console.log("Result", res);

    // if (res === true) {
    //     console.log("Verification OK");
    // } else {
    //     console.log("Invalid proof");
    // }

}

// run();
run().then(() => {
    process.exit(0);
});