pragma circom 2.0.5;

include "../../node_modules/circomlib/circuits/pedersen.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";



template Crewmate() {
    signal input nonce;
    signal input secret;
    signal output commitment;

    secret === 0;

    component commitmentHasher = Pedersen(496);
    component nullifierBits = Num2Bits(248);
    component secretBits = Num2Bits(248);
    nullifierBits.in <== nonce;
    secretBits.in <== secret;
    for (var i = 0; i < 248; i++) {
        commitmentHasher.in[i] <== nullifierBits.out[i];
        commitmentHasher.in[i + 248] <== secretBits.out[i];
    }
    commitment <== commitmentHasher.out[0];
}
// hash component for hashing the task 
// tasks are defined in index as integers : 1...18
template Hash() {
    signal input index;
    signal output hash_result;

    component hasher = Pedersen(2);
    hasher.in[0] <== index;
    hasher.in[1] <== 0; // Pad with 0 to match Pedersen input size
    hash_result <== hasher.out[0];
}

// task complete : create hash of the index and defined it as task completed
template TaskCompletion() {
    signal input task_index;
    signal output task_completed;

    component hash = Hash(); 
    hash.index <== task_index;

    task_completed <== hash.hash_result;
}

// TaskVerification component 
// this is verify the task 
template TaskVerification() {
    signal input task_completed;
    signal input task_hashes[18];
    signal output task_verified;
    
    // Initialize the verification result
    var is_task_verified = 0;

    // Hash the completed task
    component completed_hash = Hash();
    completed_hash.index <== task_completed;

    // Define comparators and isEqual signals
    component comparator[18];
    signal is_equal[18];

    // Compare the hashed completed task with each task hash
    for (var i = 0; i < 18; i++) {
        // Use isEqual function to compare signals
        comparator[i] = IsEqual();
        comparator[i].in[0] <== completed_hash.hash_result;
        comparator[i].in[1] <== task_hashes[i];
        is_equal[i] <-- comparator[i].out;
    }

    // Check if any of the isEqual signals is true
    for (var i = 0; i < 18; i++) {
        is_task_verified += is_equal[i];
    }
    component isEqual = IsEqual();
    isEqual.in[0] <== is_task_verified;
    isEqual.in[1] <== 1;
    // Set task_verified to 1 if any isEqual signal is true    
    task_verified <== isEqual.out;
}





template Task() {
    signal input task_index;
    signal input crewmate_proof_nonce;
    signal input crewmate_proof_secret;
    signal input crewmate_commitement;
    signal output task_verified;


    // hashed tasks
    component hash[18];

    // Initialize the hashed task,
    for (var i = 0; i < 18; i++) {
        // Hash the task index
        hash[i] = Hash();
        hash[i].index <== i;
    }

    // Instantiate the TaskComp
    component taskCompletion=TaskCompletion(); 
    taskCompletion.task_index <== task_index;

     // Instantiate the TaskVerification circuit
    component taskVerification = TaskVerification();
    taskVerification.task_completed <== taskCompletion.task_completed;
    
    // Collect hash results from the hashed tasks
    signal task_hashes[18];
    for (var i = 0; i < 18; i++) {
        taskVerification.task_hashes[i] <== hash[i].hash_result;
    }

    // Verification of crewmate identity
    component crewmate = Crewmate();
    crewmate.nonce <== crewmate_proof_nonce;
    crewmate.secret <== crewmate_proof_secret;
    crewmate.commitment === crewmate_commitement;
    // Output the result of the task verification
    task_verified <== taskVerification.task_verified;
}

// Create the circuit
component main = Task();
