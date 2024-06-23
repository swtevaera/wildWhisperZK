const snarkjs = require("snarkjs");
const fs = require("fs");

// current directory 
const roleWasm = "../circom/zk/crewmate_js/crewmate.wasm";
const finalKey = "../circom/zk/zkey/crewmate_final.zkey";
const verificationKeyPath = "../circom/zk/crewmate_verification_key.json";

async function run() {
    // Generate random values for secret and nonce
    const secret = 0;   // 0 is secret value for crewmate
    const nonce = Math.floor(Math.random() * (2**248)); // Random integer within range [0, 2^248)

    console.log("Secret:", secret);
    console.log("Nonce:", nonce);

    const input = { secret: BigInt(secret), nonce: BigInt(nonce) }; 
    const { proof, publicSignals } = await snarkjs.groth16.fullProve(input, roleWasm, finalKey);


    console.log("Proof: ");
    console.log(JSON.stringify(proof, null, 1));
    console.log("Inputs", input);
    console.log("Public Inputs", publicSignals);
    const solidityCallData = await snarkjs.groth16.exportSolidityCallData(proof,publicSignals);
    console.log("solidityCallData",solidityCallData);
    const vKey = JSON.parse(fs.readFileSync(verificationKeyPath));

    const res = await snarkjs.groth16.verify(vKey, [`${publicSignals}`], proof);

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