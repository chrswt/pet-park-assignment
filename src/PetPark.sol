//SPDX-License-Identifier: MIT
pragma solidity ^0.8.13;

contract PetPark {
    address public owner;

    mapping(AnimalType => uint256) public animalCounts;
    mapping(address => User) private users;

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

    struct User {
        uint8 age;
        Gender gender;
        AnimalType borrowedAnimal;
    }

    event Added(AnimalType indexed animalType, uint256 count);
    event Borrowed(AnimalType indexed animalType);
    event Returned(AnimalType indexed animalType);

    constructor() {
        owner = msg.sender;
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only owner can call this function");
        _;
    }

    modifier validAnimal(AnimalType animalType) {
        require(animalType != AnimalType.None, "Invalid animal type");
        _;
    }

    function add(AnimalType animalType, uint256 count) external onlyOwner {
        animalCounts[animalType] += count;
        emit Added(animalType, count);
    }

    function borrow(
        uint8 age,
        Gender gender,
        AnimalType animalType
    ) external validAnimal(animalType) {
        require(age > 0, "Age must be greater than zero");
        require(animalCounts[animalType] > 0, "Selected animal not available");

        User storage user = users[msg.sender];

        // If the user does not exist, create new details for the current user
        if (user.age == 0) {
            user.age = age;
            user.gender = gender;
        } else {
            require(
                user.borrowedAnimal == AnimalType.None,
                "Already adopted a pet"
            );
        }

        animalCounts[animalType] -= 1;
        user.borrowedAnimal = animalType;
        emit Borrowed(animalType);
    }
}
