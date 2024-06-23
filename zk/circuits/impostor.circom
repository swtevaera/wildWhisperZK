pragma circom 2.0.3;

include "../../node_modules/circomlib/circuits/pedersen.circom";

template Impostor() {
    // Private inputs
    signal input nonce; // Nonce used in commitment
    
    signal input secret; // The secret role of the player (1 for Impostor) 
    
    // Pedersen commitment
    signal output commitment; // Commitment to the secret role

    // Ensure secret is 1 for impostor
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

component main = Impostor();
