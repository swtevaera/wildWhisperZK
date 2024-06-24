// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./killProofVerifier.sol";
import "./sabotageVerifier.sol";
import "./taskVerifier.sol";
contract WildWhisperZk {
    error ProofAlreadyUsed();
    killProofVerifier public immutable _killProofVerifier;
    sabotageVerifier public immutable _sabotageVerifier;
    taskVerifier public immutable _taskVerifier;

    mapping(bytes32 => bool) public isAlreadyVerifiedProof;

    constructor(address __killProofVerifier, address __sabotageVerifier, address __taskVerifier) {
        _killProofVerifier = killProofVerifier(__killProofVerifier);
        _sabotageVerifier = sabotageVerifier(__sabotageVerifier);
        _taskVerifier = taskVerifier(__taskVerifier);
    }

    function verifyKillProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input
    ) public view returns (bool) {
        bytes32 proofHash = keccak256(abi.encodePacked(a, b, c, input));
        if(verifiedProofs[proofHash]) revert ProofAlreadyUsed();
        bool isValid = _killProofVerifier.verifyProof(a, b, c, input);
        if(isValid) verifiedProofs[proofHash] = true;
        return isValid;
    }
    function verifySabotageStartProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input
    ) public view returns (bool) {
        bytes32 proofHash = keccak256(abi.encodePacked(a, b, c, input));
        if(verifiedProofs[proofHash]) revert ProofAlreadyUsed();
        bool isValid = _sabotageVerifier.verifyProof(a, b, c, input);
        if(isValid) verifiedProofs[proofHash] = true;
        return isValid;
    }
    function verifyTaskProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input
    ) public view returns (bool) {
        bytes32 proofHash = keccak256(abi.encodePacked(a, b, c, input));
        if(verifiedProofs[proofHash]) revert ProofAlreadyUsed();
        bool isValid =  _taskVerifier.verifyProof(a, b, c, input);
        if(isValid) verifiedProofs[proofHash] = true;
        return isValid;
    }
}