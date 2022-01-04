// SPDX-License-Identifier: UNLICENSED

pragma solidity ^0.8.0;

import "hardhat/console.sol";

contract WavePortal {
    uint256 totalWaves;

    // This variable will be used to generate a random number
    uint256 private seed;

    // event to emit when new waves are created
    event NewWave(address indexed from, uint256 timestamp, string message);

    mapping(address => uint256) public waveCount;
    mapping(address => uint256) public lastWavedAt;

    struct Wave {
        address waver; // The address of the user who waved
        string message; //The message sent by the user
        uint256 timestamp; //The time stamp when the user waved
    }

    Wave[] waves;

    constructor() payable {
        console.log("We have been constructed!");
        /** Set the initial seed */
        seed = (block.timestamp + block.difficulty) % 100;
    }

    function wave(string memory _message) public {
        /** Making sure the msg.sender can only send one message in 15 minutes */
        require(
            lastWavedAt[msg.sender] + 30 seconds < block.timestamp,
            "Wait 30 seconds before waving again"
        );

        lastWavedAt[msg.sender] = block.timestamp;

        totalWaves++;
        waveCount[msg.sender]++;
        console.log("%s sent a wave", msg.sender);
        console.log(
            "%s has till now sent %d waves",
            msg.sender,
            waveCount[msg.sender]
        );

        waves.push(Wave(msg.sender, _message, block.timestamp));

        /** Generate a new seed for the next user that sends a wave */
        seed = (block.difficulty + block.timestamp + seed) % 100;

        console.log("Random # generated : %d", seed);

        /** Give a 50% chance that the user wins the prize */
        if (seed <= 50) {
            console.log("%s won the prize!", msg.sender);
            uint256 prizeAmount = 0.0001 ether;
            require(
                prizeAmount <= address(this).balance,
                "Trying to withdraw more than the contract has"
            );

            (bool success, ) = (msg.sender).call{value: prizeAmount}("");
            require(success, "Failed to withdraw money from the contract");
        }

        emit NewWave(msg.sender, block.timestamp, _message);
    }

    function getTotalWaves() public view returns (uint256) {
        console.log("We have %d total waves", totalWaves);
        return totalWaves;
    }

    function getAllWaves() public view returns (Wave[] memory) {
        return waves;
    }

    function getUserWaveCount() public view returns (uint256) {
        console.log("%s has sent %d waves", msg.sender, waveCount[msg.sender]);
        return waveCount[msg.sender];
    }
}
