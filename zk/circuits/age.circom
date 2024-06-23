pragma circom 2.0.3;

include "../../node_modules/circomlib/circuits/comparators.circom";

template age(){
    signal input age;  // private signal 
    signal input ageLimit;  // public signal
    signal output isAgeAboveLimit;  //output signal

    component greaterThan = GreaterEqThan(7);
    greaterThan.in[0] <== age;
    greaterThan.in[1] <== ageLimit;
    
    isAgeAboveLimit <== greaterThan.out;

}

component main{public [ageLimit]} = age();
