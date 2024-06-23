const snarkjs = require("snarkjs");

const fs = require("fs");

const roleWasmCrewmate = "../circom/zk/crewmate_js/crewmate.wasm";
const finalKeyCrewmate = "../circom/zk/zkey/crewmate_final.zkey";

const roleWasmTask = "../circom/zk/task_js/task.wasm";
const finalKeyTask = "../circom/zk/zkey/task_final.zkey";
const verificationKeyPathTask = "../circom/zk/task_verification_key.json";

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

    // Kill Proof Circuit
    const taskIndex = 1;
    const inputTask = { task_index: BigInt(taskIndex), crewmate_proof_nonce:BigInt(nonceCrewmate),crewmate_proof_secret: BigInt(secretCrewmate),crewmate_commitement:publicSignalsCrewmate[0]}; 
    var { proof, publicSignals} = await snarkjs.groth16.fullProve(inputTask, roleWasmTask, finalKeyTask);
    const proofTask = proof;
    const publicSignalsTask = publicSignals;

    console.log("Proof Task: ");
    console.log(JSON.stringify(proofTask, null, 1));
    console.log("input Task", inputTask);
    console.log("Public Inputs Task", publicSignalsTask);


    const solidityCallData = await snarkjs.groth16.exportSolidityCallData(proofTask,publicSignalsTask);
    console.log("solidityCallData",solidityCallData);
    const vKey = JSON.parse(fs.readFileSync(verificationKeyPathTask));
    const res = await snarkjs.groth16.verify(vKey, [`${publicSignalsTask}`], proofTask);

    
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