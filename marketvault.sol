// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Address.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/Context.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/utils/math/SafeMath.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/master/contracts/token/ERC20/IERC20.sol";
import "/contracts/AMT.sol";
import "/contracts/Master.sol";

contract MARKETVAULT is Context{
    AMT immutable amt;
    IERC20 immutable backingCoin;
    uint256 public sellRate; //
    uint256 constant ceros = 10**18;
    address immutable private adminWallet;
    uint256 fee;

    constructor(address addrAMT, address addrBackingCoin, uint256 _sellRate, uint256 _fee,address _adminWallet){
        amt = AMT(addrAMT);
        backingCoin = IERC20(addrBackingCoin);
        sellRate = _sellRate;
        fee = _fee;
        adminWallet = _adminWallet;
    }

    //view functions
    function getBackRate() public view returns (uint256){
        return amt.totalSupply()/backingCoin.balanceOf(address(this));
    }

    //general functions

    //backing withdrawl function (liquidation of AMT for BBTC)
    function backingWithdrawl(uint256 amount) public {
        require(amount < amt.balanceOf(msg.sender), "not enought amt");
        amt.burnFrom(msg.sender, amount);
        uint256 backRate = getBackRate();
        backingCoin.transfer(msg.sender, (amount*(100-fee))/(backRate*100));
        backingCoin.transfer(msg.sender,(amount*fee)/(backRate*100));
    }

    //Buy function

    function buy(uint256 amount) public {
        require(amount < backingCoin.balanceOf(msg.sender), "not enought bBTC");
        require(amount * sellRate < amt.balanceOf(address(this)), "not enought AMT on sell");

        backingCoin.transferFrom(msg.sender, adminWallet, amount);
        amt.transfer(msg.sender, amount * sellRate);
    }

    //Function to charge on sell AMT
    function charge(uint256 snapId, address master_) public{
        Master master = Master(master_);
        uint256 amount = master.charge(snapId);
        backingCoin.transfer(msg.sender,amount);
    }

}
