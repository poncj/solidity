// SPDX-License-Identifier: MIT
pragma solidity ^0.8.12; // string concat

contract RockPaperScissors {    

    // 1 BNB = 10^18 wei
    // 1 BNB = 10^9 gwei
    // 0.01 BNB = 10000000 gwei
    // 0.001 BNB = 1000000 gwei

    // minimum is 100000 gwei or 10^15 wei

    mapping(uint8 => string) private label;
    mapping(uint8 => uint8) private target;

    uint64 public minBet = 10e13 wei;
    
    address private owner;

    constructor() payable {
        owner = msg.sender;
        
        label[0] = "Rock";
        label[1] = "Paper";
        label[2] = "Scissors";

        target[0] = 2;
        target[1] = 0;
        target[2] = 1;
    }

    event GamePlayed(address player, bool isWinner, string details, string _optionByPlayer, string _optionByContract);
    event WithdrawnEvent(uint256 withrowed, uint256 currentBalance);
    event RefillEvent(uint256 recieved, uint256 currentBalance);

    function playGame(uint8 _optionByPlayer) internal returns(uint256 amount) {

        if (_optionByPlayer > 2 || _optionByPlayer < 0) {
            revert("Error. Bad option");
        }

        uint256 pseudoRandom = uint256(keccak256(abi.encodePacked(block.timestamp, block.number, msg.sender, uint8(173)))); // 173 - solt
        uint8 _optionByContract = uint8(pseudoRandom % 3);
        string memory details = '';
        
        if (target[_optionByPlayer] == _optionByContract) {
            
            details = string.concat(label[_optionByPlayer], " beats ");
            details = string.concat(details, label[_optionByContract]);
            details = string.concat("Player won! ", details);

            emit GamePlayed(msg.sender, true, details, label[_optionByPlayer], label[_optionByContract]);
            
            return msg.value * 2;

        } else if (_optionByPlayer == _optionByContract) {
            
            details = string.concat("Its a Draw! Both players chose ", label[_optionByPlayer]);

            emit GamePlayed(msg.sender, false, details, label[_optionByPlayer], label[_optionByContract]);
            
            return msg.value;
        }

        details = string.concat(label[_optionByContract], " beats ");
        details = string.concat(details, label[_optionByPlayer]);
        details = string.concat("Contract won! ", details);
        
        emit GamePlayed(msg.sender, false, details, label[_optionByPlayer], label[_optionByContract]);
        
        return 0;
    }

    function Rock() payable external beforeGameCheck returns(bool) {
        uint256 amount = playGame(0);
        if (amount > 0) {
            payable(msg.sender).transfer(amount);
            return true;
        }
        return false;
    }

    function Paper() payable external beforeGameCheck returns(bool) {
        uint256 amount = playGame(1);
        if (amount > 0) {
            payable(msg.sender).transfer(amount);
            return true;
        }
        return false;
    }

    function Scissors() payable external beforeGameCheck returns(bool) {
        uint256 amount = playGame(2);
        if (amount > 0) {
            payable(msg.sender).transfer(amount);
            return true;
        }
        return false;
    }

    function Withdraw(uint256 amount) external {
        require(msg.sender == owner, "Only owner can withdrow");

        uint256 addressBalance = uint256(address(this).balance);
        
        require(addressBalance > 0, "Contract balance is empty");
        require(amount - tx.gasprice > 0, "Gas is bigger than withdraw amount");
        
        amount = amount - tx.gasprice;
        
        require(addressBalance >= amount, "Contract balance less than requested amount");

        payable(owner).transfer(amount);

        emit WithdrawnEvent(amount, addressBalance - amount); // NOT accurate !!!
    }

    function Refill() payable external {
        require(msg.sender == owner, "Only owner can refill");
        require(msg.value > 0, "Value is empty");

        emit RefillEvent(msg.value, uint256(address(this).balance));
    }

    modifier beforeGameCheck() {
        require(msg.value >= minBet, "Minimum bet is 0.001 tBNB");
        require(address(this).balance >= msg.value*2, "Too big a bet. The contract will not be able to pay the winnings.");
        _;
    }
}
