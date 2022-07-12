// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/utils/Address.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/utils/math/SafeMath.sol";
import "@openzeppelin/contracts/token/ERC20/IERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";
import "./AMT.sol";
import "./Master.sol";

contract marketvault is Context, Ownable{
    AMT immutable amt;
    IERC20 immutable backingCoin;
	IERC20 immutable buyCoin;
    uint256 public sellRate; //
    uint256 constant ceros = 10**18;
    address immutable private adminWallet;
    uint256 fee;
	Master master;

    constructor(address addrAMT, address addrBackingCoin, address addrBuyCoin, uint256 _sellRate, uint256 _fee,address _adminWallet){
        amt = AMT(addrAMT);
        backingCoin = IERC20(addrBackingCoin);
		buyCoin = IERC20(addrBuyCoin); //NEW LOGIC: We'll use different coins for buying and backing withdrawls
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
        backingCoin.transfer(adminWallet,(amount*fee)/(backRate*100));
    }

    //Buy function

    function buy(uint256 amount) public {
        require(amount < buyCoin.balanceOf(msg.sender), "not enought USDT");
        require(amount * sellRate < amt.balanceOf(address(this)), "not enought AMT on sell");

        buyCoin.transferFrom(msg.sender, adminWallet, amount);
        amt.transfer(msg.sender, amount * sellRate);
    }

    //Function to charge on sell AMT
	
	function setMaster(address master_) public onlyOwner{
		master = Master(master_); 
	}
	
	
	
    function charge(uint256 snapId) public onlyOwner{
        
        uint256 amount = master.charge(snapId);
        backingCoin.transfer(msg.sender,amount);
    }

}