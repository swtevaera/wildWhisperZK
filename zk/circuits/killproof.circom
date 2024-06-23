pragma circom 2.0.3;

include "../../node_modules/circomlib/circuits/pedersen.circom";
include "../../node_modules/circomlib/circuits/binsum.circom";
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

template KillProof() {
    signal input impostor_proof_nonce;
    signal input impostor_proof_secret;
    signal input impostor_commitement;
    signal input crewmate_proof_nonce;
    signal input crewmate_proof_secret;
    signal input crewmate_commitement;

    component impostor = Impostor();
    impostor.nonce <== impostor_proof_nonce;
    impostor.secret <== impostor_proof_secret;
    impostor.commitment === impostor_commitement;

    component crewmate = Crewmate();
    crewmate.nonce <== crewmate_proof_nonce;
    crewmate.secret <== crewmate_proof_secret;
    crewmate.commitment === crewmate_commitement;
}

component main = KillProof();
