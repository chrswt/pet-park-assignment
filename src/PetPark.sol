//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
    address public owner;

    mapping(AnimalType => uint256) public animalCount;

    enum AnimalType {
        None,
        Fish,
        Cat,
        Dog,
        Rabbit,
        Parrot
    }

    enum Gender {
        Male,
        Female
    }

    event Added(AnimalType indexed animalType, uint256 count);
    event Borrowed(AnimalType indexed animalType);
    event Returned (AnimalType indexed animalType);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier validAnimal(AnimalType animalType) {
        require(animalType != AnimalType.None, "Invalid animal");
        _;
    }

    function add(AnimalType animalType, uint256 count) external onlyOwner {
        animalCount[animalType] += count;
        emit Added(animalType, count);
    }
}