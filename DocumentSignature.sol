// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract DocumentSignature {
    
    address[] private whitelist;
    mapping(address => bool) private signatures;
    string public documentHash;
    bool public documentSigned = false;
    
    address private owner;
    
    constructor() {
        owner = msg.sender;
        whitelist.push(owner);
    }
    
    // Проверка адреса на владельца
    function isOwner() public view returns(bool) {
        return msg.sender == owner;
    }

    // Добавление массива адресов в белый список
    function addArrayToWhitelist(address[] memory addressesToAdd) public { 
        require(!documentSigned, "Document is already signed");
        require(isOwner(), "Not owner");

        for (uint i = 0; i < addressesToAdd.length; i++) {
            addToWhitelist(addressesToAdd[i]);
        }
    }

    // Добавление адреса в белый список и установка подписи в false
    function addToWhitelist(address addressToAdd) internal {
        require(!documentSigned, "Document is already signed");
        require(isOwner(), "Not owner");
       
        if (!inWhitelist(addressToAdd)) {
            whitelist.push(addressToAdd);
            signatures[addressToAdd] = false;
        } else {
            emit AlreadyInWhitelist(addressToAdd, "Address already in whitelist");
        }
    }

    event AlreadyInWhitelist(address _address, string _message);

    // Удаления массива адресов из белого списка
    function removeArrayFromWhitelist(address[] memory addressesToRemove) public {
        require(!documentSigned, "Document is already signed");
        require(isOwner(), "Not owner");
       
        for (uint i = 0; i < addressesToRemove.length; i++) {
            removeFromWhitelist(addressesToRemove[i]);
        }
    }


    // Удаление адреса из белого списка и удаление подписи
    function removeFromWhitelist(address addressToRemove) internal {
        require(!documentSigned, "Document is already signed");
        require(isOwner(), "Not owner");
       
        for (uint i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == addressToRemove) {
                delete whitelist[i];

                whitelist[whitelist.length - 1] = whitelist[i];
                whitelist.pop();

                delete signatures[addressToRemove];
                break;
            }
        }
    }

    // Проверка адреса в белом листе
    function inWhitelist(address searchAddress) public view returns(bool) {
        for (uint i = 0; i < whitelist.length; i++) {
            if (whitelist[i] == searchAddress) {
                return true;
            }
        }
        return false;
    }


    // Подписание документа
    function signDocument() public {
        require(inWhitelist(msg.sender), "Address not whitelisted");
        require(!hasSignedDocument(msg.sender), "Address has already signed the document");
        
        signatures[msg.sender] = true;

        if (areAllSignaturesCollected()) {
            documentSigned = true;
        }
    }

    // Проверка, что адрес уже подписал документ
    function hasSignedDocument(address searchAddress) public view returns (bool) {
        return signatures[searchAddress];
    }

    // Проверка, что адрес уже подписал документ
    function getWhitelist() public view returns (address[] memory) {
        return whitelist;
    }

    // Проверка, что все адреса из белого списка подписали документ
    function areAllSignaturesCollected() public view returns (bool) {
        require(whitelist.length > 0, "Whitelist is empty");
        for (uint i = 0; i < whitelist.length; i++) {
            if (!signatures[whitelist[i]]) {
                return false;
            }
        }
        return true;
    }

    // Установка хэша документа
    function setDocumentHash(string memory hash) public {
        require(!documentSigned, "Document is already signed");
        require(msg.sender == owner, "Not owner");
        require(inWhitelist(msg.sender), "Access violation!");
        documentHash = hash;
    }

    // Отзыв подписи
    function cancelSignature() public {
        require(inWhitelist(msg.sender), "Access violation!");
        documentSigned = false;
        
        delete signatures[msg.sender];
        
        for (uint i = 0; i < whitelist.length; i++) {
            signatures[whitelist[i]] = false;
        }
    }
}
