// SPDX-License-Identifier: MIT
/**
 * @title UserAccessControl
 * @dev A smart contract for managing user access control.
 * @custom:dev-run-script deploy.js
 */
pragma solidity ^0.8.0;

contract UserAccessControl {
    
    address payable public owner;
    uint16 private constant ACCESS_CODE_LENGTH = 4;
    uint256 public applicationFee = 0.0 ether; // Adjust the fee as needed

    address[] public allowedAddresses;

    mapping(address => bool) public allowedUsers;
    mapping(address => uint16) public accessCodes;

    event UserAllowed(address indexed user, uint16 accessCode);
    event UserNotAllowed(address indexed user);
    event EtherReceived(address indexed from, uint256 amount);
    event EtherTransferred(address indexed to, uint256 amount);

    constructor() {
        owner = payable(msg.sender);

        // Allow the specified addresses during contract deployment
        //allowUser(put a valid adress);
        
        // Disallow the specified address during contract deployment
        //disallowUser(put an adress);
    }

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can call this function");
        _;
    }

    function allowUser(address user) internal onlyOwner {
        allowedUsers[user] = true;
        allowedAddresses.push(user);
        uint16 code = _generateRandomCode();
        accessCodes[user] = code;
        emit UserAllowed(user, code);
    }

    function disallowUser(address user) internal onlyOwner {
        allowedUsers[user] = false;
        for (uint i = 0; i < allowedAddresses.length; i++) {
            if (allowedAddresses[i] == user) {
                delete allowedAddresses[i]; // Remove the address from the list
                break;
            }
        emit UserNotAllowed(user);
    }
    }

    function checkUser(address user) external view returns (bool, uint16) {
        require(allowedUsers[user], "User is not allowed to use the application");
        return (true, accessCodes[user]);
    }

    function payApplicationFee() external payable {
        require(msg.value == applicationFee, "Incorrect application fee");
        emit EtherReceived(msg.sender, msg.value);
        owner.transfer(applicationFee);
        emit EtherTransferred(owner, applicationFee);
    }

    function _generateRandomCode() private view returns (uint16) {
        return uint16(uint(keccak256(abi.encodePacked(block.timestamp, msg.sender))) % 10000);
    }
}
