pragma solidity ^0.5.0;

import "./PupperCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";


// @TODO: Inherit the crowdsale contracts
contract PupperCoinSale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, RefundablePostDeliveryCrowdsale {
    
    constructor(
        // @TODO: Fill in the constructor parameters!
        //uint rate,              // rate in token-bits
        address payable wallet, // beneficiary of the sale
        PupperCoin token,       // create token of type PupperCoin
        uint saleCap,           // cap for CappedCrowdsale
        uint openTime,          // when to open the sale (in unix epoch seconds)
        uint closeTime,         // when to close the sale (in unix epoch seconds)
        uint fundingGoal        // goal required in ETH, otherwise funds can be reclaimed
    )
        // @TODO: Pass the constructor parameters to the crowdsale contracts.
        CappedCrowdsale(saleCap)
        TimedCrowdsale(openTime, closeTime)
        RefundableCrowdsale(fundingGoal)
        Crowdsale(1, wallet, token)          // hard-coding my rate to 1, i.e. 1 wei = 1 token-bit
        public
    {
        // constructor can stay empty
    }
}

// onlyWhileOpen()   <-- How is this used?????
// claimRefund(address payable refundee)

contract PupperCoinSaleDeployer {

    address public pupper_sale_address; // address of the Sale contract
    address public token_address;       // address of PupperCoin
    
    uint saleCap;       // the cap for CappedCrowdsale
    //uint fundingGoal;   // the goal RefundablePostDeliveryCrowdsale
    //uint rate;
    uint openTime;
    uint closeTime;
    uint fakeClose;     // closeTime for testing purposes only
    

    constructor(
        // @TODO: Fill in the constructor parameters!
        string memory name,     // token name, i.e. WardCoin
        string memory symbol,   // token symbol, i.e. WARD
        address payable wallet, // address will receive ETH raised by sale
        uint fundingGoal        // the goal RefundablePostDeliveryCrowdsale
    )
        public
    {
        // set defaults for deployment
        //rate == 1;              // must default the rate of tokens to wei as 1-to-1
        saleCap = fundingGoal; // if we set up a funding goal, this should be the cap
        openTime = now;
        closeTime = now + 24 weeks;   // closes in 24 weeks
        fakeClose = now + 5 minutes; // closes in 10 minutes ... for testing only
        
        // @TODO: create the PupperCoin and keep its address handy
        PupperCoin token = new PupperCoin(name, symbol, 0);  // name, symbol, supply
        token_address = address(token);

        // @TODO: create the PupperCoinSale and tell it about the token, set the goal, and set the open and close times to now and now + 24 weeks.
        //PupperCoinSale pupper_sale = new PupperCoinSale(rate, wallet, token, saleCap, openTime, fakeClose, fundingGoal);
        PupperCoinSale pupper_sale = new PupperCoinSale(wallet, token, saleCap, openTime, fakeClose, fundingGoal);
        pupper_sale_address = address(pupper_sale);
        
        // make the PupperCoinSale contract a minter, then have the PupperCoinSaleDeployer renounce its minter role
        // in other words, create the token and sale and then set them free into the wild :)
        token.addMinter(pupper_sale_address);
        token.renounceMinter();
    }
}
