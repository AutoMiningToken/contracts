// SPDX-License-Identifier: MIT

pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/ERC20.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/access/Ownable.sol";

contract bBTC is ERC20, Ownable{
    string nameForDeploy = "testBBTC";
    string symbolForDeploy = "TBBTC";
    constructor (string memory _name, string memory _symbol) ERC20(nameForDeploy,symbolForDeploy){}
    
    function mint(address account, uint256 amount) public onlyOwner(){
        _mint(account,amount);
    }
}