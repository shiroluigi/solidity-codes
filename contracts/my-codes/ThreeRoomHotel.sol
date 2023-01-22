// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

//TODO: Make a hotel with 3 rooms and book the person who has paid
/* THIS IS MY FIRST CODE IN THIS LANGUAGE OR ENVIORNMENT SO THE CODE OF FAR FROM OPTIMIZED OR PERFECT */

contract main {
    address payable owner;
    //Struct to keep a record of the person who is booking
    struct Person {
        string PersonName;
        address PersonAddress;
    }
    //Event for logging purposes
    event occupy(address _senderAddress, uint256 _value);
    //Use enum to keep a record of vacant or occupied
    enum roomStatus {
        Vacant,
        Occupied
    }
    roomStatus internal status; //Declare the status as internal as it is not required to see outside the contract
    //using mapping for roomDetails to keep track of the status if the room [1,2,3]
    mapping(uint256 => roomStatus) internal roomDetails;
    //using mapping fo roomPersonDetails to keep track of the details of the person in the room
    mapping(uint256 => Person) public roomPersonDetails;

    constructor() {
        //Initialize the values of all the rooms as vacant
        roomDetails[1] = roomStatus.Vacant;
        roomDetails[2] = roomStatus.Vacant;
        roomDetails[3] = roomStatus.Vacant;
        //Storing the address of the owner in 'owner' address and then making it payable to accept ether. The person
        //who deployed the contract will be the owner
        owner = payable(msg.sender);
    }

    //Modifier to check whether the sent amount is right or not
    modifier cost(uint256 _amt) {
        require(msg.value == 1 ether, "Incorrect amount");
        _;
    }

    //function to handle the booking of room and making it occupied
    function bookRoom(string memory _name, uint256 roomNO)
        public
        payable
        cost(1 ether)
    {
        //Check if the room number that is entered is valid or not
        if (roomNO < 1 || roomNO > 3) {
            revert("Invalid number of room");
        }
        //book only if the room is empty else dont let them book
        require(roomDetails[roomNO] == roomStatus.Vacant, "Not vacant");
        roomDetails[roomNO] = roomStatus.Occupied;
        //Using call function to send money to the owner as owner.transfer(msg.value) doesnot seem to work
        (bool sent, bytes memory data) = owner.call{value: msg.value}("");
        require(sent, "failed to send eth");
        roomPersonDetails[roomNO] = Person(_name, msg.sender);
        //Logging what had happened using emit function
        emit occupy(msg.sender, msg.value);
    }

    //function to handle leaving of the room to free up space
    function leaveRoom(uint256 roomNo) public {
        //Check if the room number that is entered is valid or not
        if (roomNo < 1 || roomNo > 3) {
            revert("Invalid number of room");
        }
        //Check if the person trying to leave the room is the one who booked it or not
        require(
            roomPersonDetails[roomNo].PersonAddress == msg.sender,
            "You are not the owner"
        );
        roomDetails[roomNo] = roomStatus.Vacant;
        roomPersonDetails[roomNo] = Person("", address(0));
    }

    //function to check if a room is available to be booked or not
    function roomAvailibility(uint256 _rn) public view returns (string memory) {
        //Check if the room number that is entered is valid or not
        if (_rn < 1 || _rn > 3) {
            return "Invalid room no";
        }
        //Check if room is vacant or not and then return the result
        if (roomDetails[_rn] == roomStatus.Vacant) {
            return "Room is Vacant";
        }
        return "Room is not Vacant";
    }
}
