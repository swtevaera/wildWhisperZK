pragma circom 2.0.5;

include "../../node_modules/circomlib/circuits/pedersen.circom";
include "../../node_modules/circomlib/circuits/comparators.circom";

/*StartSabotage:0*/

template Impostor() {
    signal input nonce;
    signal input secret;
    signal output commitment;

    secret === 1;

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
// hash component for hashing the sabotage 
// sabotages are defined in index as integers : 1...1
template Hash() {
    signal input index;
    signal output hash_result;

    component hasher = Pedersen(2);
    hasher.in[0] <== index;
    hasher.in[1] <== 0; // Pad with 0 to match Pedersen input size
    hash_result <== hasher.out[0];
}

// sabotage complete : create hash of the index and defined it as sabotage completed
template SabotageCompletion() {
    signal input sabotage_index;
    signal output sabotage_completed;

    component hash = Hash(); 
    hash.index <== sabotage_index;

    sabotage_completed <== hash.hash_result;
}

// SabotageVerification component 
// this is verify the sabotage 
template SabotageVerification() {
    signal input sabotage_completed;
    signal input sabotage_hashes;
    signal output sabotage_verified;
    
    // Initialize the verification result
    var is_sabotage_verified = 0;

    // Hash the completed sabotage
    component completed_hash = Hash();
    completed_hash.index <== sabotage_completed;

    // Define comparators and isEqual signals
    component comparator;
    signal is_equal;

    // Compare the hashed completed sabotage with each sabotage hash
    // Use isEqual function to compare signals
    comparator = IsEqual();
    comparator.in[0] <== completed_hash.hash_result;
    comparator.in[1] <== sabotage_hashes;
    is_equal <-- comparator.out;

    // Check if any of the isEqual signals is true
    is_sabotage_verified += is_equal;
    component isEqual = IsEqual();
    isEqual.in[0] <== is_sabotage_verified;
    isEqual.in[1] <== 1;
    // Set sabotage_verified to 1 if any isEqual signal is true    
    sabotage_verified <== isEqual.out;
}

template Sabotage() {
    signal input sabotage_index;
    signal input impostor_proof_nonce;
    signal input impostor_proof_secret;
    signal input impostor_commitement;
    signal output sabotage_verified;

    // hashed sabotages
    component hash;
   // Hash the sabotage index
        hash = Hash();
        hash.index <== 0;

    // Instantiate the SabotageComp
    component sabotageCompletion=SabotageCompletion(); 
    sabotageCompletion.sabotage_index <== sabotage_index;

     // Instantiate the SabotageVerification circuit
    component sabotageVerification = SabotageVerification();
    sabotageVerification.sabotage_completed <== sabotageCompletion.sabotage_completed;
    
    // Collect hash results from the hashed sabotages
    sabotageVerification.sabotage_hashes <== hash.hash_result;

    // Verification of impostor identity
    component impostor = Impostor();
    impostor.nonce <== impostor_proof_nonce;
    impostor.secret <== impostor_proof_secret;
    impostor.commitment === impostor_commitement;
    // Output the result of the sabotage verification
    sabotage_verified <== sabotageVerification.sabotage_verified;
}

// Create the circuit
component main = Sabotage();
