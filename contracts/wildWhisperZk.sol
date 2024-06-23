// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
import "./impostorVerifier.sol";
import "./killProofVerifier.sol";
import "./sabotageVerifier.sol";
import "./taskVerifier.sol";
contract WildWhisperZk {
    impostorVerifier public immutable _impostorVerifier;
    killProofVerifier public immutable _killProofVerifier;
    sabotageVerifier public immutable _sabotageVerifier;
    taskVerifier public immutable _taskVerifier;
    constructor(address __impostorVerifier, address __killProofVerifier, address __sabotageVerifier, address __taskVerifier) {
        _impostorVerifier = impostorVerifier(__impostorVerifier);
        _killProofVerifier = killProofVerifier(__killProofVerifier);
        _sabotageVerifier = sabotageVerifier(__sabotageVerifier);
        _taskVerifier = taskVerifier(__taskVerifier);
    }
    function verifyImpostorProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input
    ) public view returns (bool) {
        return _impostorVerifier.verifyProof(a, b, c, input);
    }
    function verifyKillProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input
    ) public view returns (bool) {
        return _killProofVerifier.verifyProof(a, b, c, input);
    }
    function verifySabotageStartProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input
    ) public view returns (bool) {
        return _sabotageVerifier.verifyProof(a, b, c, input);
    }
    function verifyTaskProof(
        uint[2] memory a,
        uint[2][2] memory b,
        uint[2] memory c,
        uint[1] memory input
    ) public view returns (bool) {
        return _taskVerifier.verifyProof(a, b, c, input);
    }
}