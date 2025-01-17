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
        bool exists;
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

    function add(
        AnimalType animalType,
        uint256 count
    ) external onlyOwner validAnimal(animalType) {
        // Update state variables and emit Added event
        animalCounts[animalType] += count;
        emit Added(animalType, count);
    }

    function borrow(
        uint8 age,
        Gender gender,
        AnimalType animalType
    ) external validAnimal(animalType) {
        // Perform fail-fast data and inventory validation
        require(age > 0, "Age must be greater than zero");
        require(animalCounts[animalType] > 0, "Selected animal not available");

        User storage user = users[msg.sender];

        // If the user does not exist, create new details for the current user
        if (!user.exists) {
            user.age = age;
            user.gender = gender;
            user.exists = true;
        } else {
            // Check that the user's details are valid and unchanged
            require(user.age == age, "Invalid Age");
            require(user.gender == gender, "Invalid Gender");

            // Check that the user is not currently borrowing another animal
            require(
                user.borrowedAnimal == AnimalType.None,
                "Already adopted a pet"
            );
        }

        // Perform specific requirement tests
        if (gender == Gender.Male) {
            require(
                animalType == AnimalType.Dog || animalType == AnimalType.Fish,
                "Invalid animal for men"
            );
        } else if (gender == Gender.Female && age < 40) {
            require(
                animalType != AnimalType.Cat,
                "Invalid animal for women under 40"
            );
        }

        // Update state variables and emit Borrowed event
        animalCounts[animalType] -= 1;
        user.borrowedAnimal = animalType;
        emit Borrowed(animalType);
    }

    function giveBackAnimal() external {
        // Load user and check that user has borrowed an animal
        User storage user = users[msg.sender];
        require(user.borrowedAnimal != AnimalType.None, "No borrowed pets");

        // Update state variables and emit Returned event
        animalCounts[user.borrowedAnimal] += 1;
        user.borrowedAnimal = AnimalType.None;
        emit Returned(user.borrowedAnimal);
    }
}
