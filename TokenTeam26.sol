// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenTeam26 is ERC20 {

    address public owner;

    uint256 public mintValue = 10e17; // 1 ether or 1 token

    constructor() ERC20("TokenTeam26", "T26") {
        owner = msg.sender;
        _mint(owner, 10000 * mintValue);
    }
    
    
    // FOR TESTING PURPOSES
    function mintTenTokens() external {
        _mint(msg.sender, 10 * mintValue);
    }
}
