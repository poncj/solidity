// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";

contract TokenTeam26 is ERC20 {

    address public owner;

    uint256 public mintValue = 10e17;

    constructor() ERC20("TokenTeam26", "T26") {
        owner = msg.sender;
        _mint(owner, 10000 * (10 ** decimals()));
    }

    function mintTenTokens() external {
        _mint(msg.sender, mintValue);
    }
}
