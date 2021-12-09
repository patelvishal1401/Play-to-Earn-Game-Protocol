// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract NFTGAMEPLAY is ERC721, Ownable {

    enum type_character { PROFESSOR, LISBON }

    uint nextId = 0;

    struct Character {
        uint8 attack;
        uint8 defense;
        uint life;
        uint32 experience;
        uint lastHeal;
        uint lastFight;
        type_character typeCharacter;
    }

    mapping(uint => Character) private _characterDetails;

    constructor(string memory name, string memory symbol) ERC721(name, symbol) {

    }

    function getTokenDetails(uint _tokenId) public view returns(Character memory) {
        return _characterDetails[_tokenId];
    }

    function mint(type_character _typeCharacter) public {
        require(balanceOf(msg.sender) <= 4, "Already create max characters.");
        require(_typeCharacter == type_character.PROFESSOR || _typeCharacter == type_character.LISBON, "Not valid");
        if(_typeCharacter == type_character.PROFESSOR) {
            Character memory thisCharacter = Character(20, 15, 100, 1, block.timestamp, block.timestamp, type_character.PROFESSOR);
            _characterDetails[nextId] = thisCharacter;
            _safeMint(msg.sender, nextId);
            nextId++;
        }
        if(_typeCharacter == type_character.LISBON) {
            Character memory thisCharacter = Character(13, 25, 80, 1, block.timestamp, block.timestamp, type_character.LISBON);
            _characterDetails[nextId] = thisCharacter;
            _safeMint(msg.sender, nextId);
            nextId++;
        }
    }

    function heal(uint _tokenId) public {
        require(ownerOf(_tokenId) == msg.sender, "You cannot heal an other Character than yours.");
        Character storage thisCharacter = _characterDetails[_tokenId];
        require(thisCharacter.lastHeal + 60 < block.timestamp, "To soon to heal.");
        require(thisCharacter.life > 0, "Cant't heal someone that is dead.");
        thisCharacter.lastHeal = block.timestamp;
        thisCharacter.life += 50;
    }

    function fight(uint _tokenId1, uint _tokenId2) public payable {
        require(_characterDetails[_tokenId1].lastFight + 60 < block.timestamp && _characterDetails[_tokenId2].lastFight + 60 < block.timestamp, "Must wait before next fight");
        require(ownerOf(_tokenId1) == msg.sender, "Not your character");
        require(ownerOf(_tokenId1) != ownerOf(_tokenId2), "You cannot fight your own character.");
        require(_characterDetails[_tokenId1].life > 0 && _characterDetails[_tokenId2].life > 0, "You can only fight living character.");

        //Calculs
        uint substractLifeToCharacter2 = (_characterDetails[_tokenId1].attack * _characterDetails[_tokenId1].experience) - (_characterDetails[_tokenId2].defense / 4);
        uint substractLifeToCharacter1 = (_characterDetails[_tokenId2].attack * _characterDetails[_tokenId2].experience) - (_characterDetails[_tokenId1].defense / 4);

        //timestamp
        _characterDetails[_tokenId1].lastFight = block.timestamp;
        _characterDetails[_tokenId2].lastFight = block.timestamp;

        // Character 1 kills character 2, character 2 cannot reply
        if(_characterDetails[_tokenId2].life - substractLifeToCharacter2 <= 0) {
            _characterDetails[_tokenId2].life = 0;
            _characterDetails[_tokenId1].experience++;
        }
        else {
            // Character 1 does not kill character 2, but character 2 replies and kills it
            if(_characterDetails[_tokenId2].life - substractLifeToCharacter2 > 0 && _characterDetails[_tokenId1].life - substractLifeToCharacter1 <= 0) {
                _characterDetails[_tokenId2].life -= substractLifeToCharacter2;
                _characterDetails[_tokenId1].life = 0;
                _characterDetails[_tokenId2].experience++;
            }
            // Character 1 does not kill character 2 and that character 2 replies without killing character 1
            else {
                _characterDetails[_tokenId2].life -= substractLifeToCharacter2;
                _characterDetails[_tokenId1].life -= substractLifeToCharacter1;
                if(substractLifeToCharacter1 > substractLifeToCharacter2) {
                    _characterDetails[_tokenId2].experience++;
                }
                else if(substractLifeToCharacter2 > substractLifeToCharacter1) {
                    _characterDetails[_tokenId1].experience++;
                }
                else {
                    _characterDetails[_tokenId1].experience++;
                    _characterDetails[_tokenId2].experience++;

                }
            }
        }
    }

    function _beforeTokenTransfer(address from, address to, uint tokenId) internal override {
        Character storage thisCharacter = _characterDetails[tokenId];
        require(thisCharacter.life > 0, "This character is dead and cannot be transfered.");
    }

}
