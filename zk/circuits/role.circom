pragma circom 2.0.3;

include "../../node_modules/circomlib/circuits/pedersen.circom";

template RoleAssignment() {
    // Private inputs
    signal input secret; // The secret role of the player (0 for Impostor, 1 for Crewmate) 
    signal input nonce; // Nonce used in commitment
    // Pedersen commitment
    signal output commitment; // Commitment to the secret role

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

component main = RoleAssignment();
