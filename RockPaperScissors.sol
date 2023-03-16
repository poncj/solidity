// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12; // string concat

contract RockPaperScissors {    

    // 1 BNB = 10^18 wei
    // 1 BNB = 10^9 gwei
    // 0.01 BNB = 10000000 gwei
    // 0.001 BNB = 1000000 gwei
    // 1 bnb = 10^9 gwei
    // minimum is 1000000 gwei or 10^15 wei


    mapping(uint8 => string) private label;
    mapping(uint8 => uint8) private target;

    uint64 public minBet = 10e14 wei;

    constructor() payable {
        label[0] = "Rock";
        label[1] = "Paper";
        label[2] = "Scissors";

        target[0] = 2;
        target[1] = 0;
        target[2] = 1;
    }

    event GamePlayed(address player, bool isWinner, string details);

    function playGame(uint8 _optionByPlayer) payable public returns(bool) {
        require(_optionByPlayer <=2, "Choose: 0 - Rock, 1 - Paper, 2 - Scissors");
        require(msg.value >= minBet, "Minimum bet is 0.001 tBNB");
        require(address(this).balance >= msg.value*2, "Too big a bet. The contract will not be able to pay the winnings.");
        
        uint8 _optionByContract = uint8(block.timestamp % 3);

        string memory details = '';
        
        if (target[_optionByPlayer] == _optionByContract) {
            
            payable(msg.sender).transfer(msg.value * 2);
            
            details = string.concat(label[_optionByPlayer], " beats ");
            details = string.concat(details, label[_optionByContract]);
            details = string.concat("Player won! ", details);

            emit GamePlayed(msg.sender, true, details);
            return true;

        } else if (_optionByPlayer == _optionByContract) {

            details = string.concat("Its a Draw! Both players chose ", label[_optionByPlayer]);
            emit GamePlayed(msg.sender, false, details);
            return false;

        } else {

            details = string.concat(label[_optionByContract], " beats ");
            details = string.concat(details, label[_optionByPlayer]);
            details = string.concat("Contract won! ", details);
            
            emit GamePlayed(msg.sender, false, details);
            return false;
        }
    }

}
