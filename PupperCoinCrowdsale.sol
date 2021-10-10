pragma solidity ^0.5.0;

import "./PupperCoin.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/Crowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/emission/MintedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/CappedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/validation/TimedCrowdsale.sol";
import "https://github.com/OpenZeppelin/openzeppelin-contracts/blob/release-v2.5.0/contracts/crowdsale/distribution/RefundablePostDeliveryCrowdsale.sol";

contract PupperCoinSale is Crowdsale, MintedCrowdsale, CappedCrowdsale, TimedCrowdsale, RefundablePostDeliveryCrowdsale {
    
    constructor(
        address payable wallet, // beneficiary of the sale
        PupperCoin token,       // create token of type PupperCoin
        uint saleCap,           // cap for CappedCrowdsale
        uint openTime,          // when to open the sale (in unix epoch seconds)
        uint closeTime,         // when to close the sale (in unix epoch seconds)
        uint fundingGoal        // goal required in ETH, otherwise funds can be reclaimed
    )
        CappedCrowdsale(saleCap)
        TimedCrowdsale(openTime, closeTime)
        RefundableCrowdsale(fundingGoal)
        Crowdsale(1, wallet, token) // hard-coding rate to 1, i.e. 1 wei = 1 token-bit
        public
    {
        // constructor can stay empty
    }
}

contract PupperCoinSaleDeployer {

    address public pupper_sale_address; // address of the Sale contract
    address public token_address;       // address of PupperCoin
    
    uint saleCap;   // the cap for CappedCrowdsale
    uint openTime;  // on contract creation
    uint closeTime; // when sale closes
    uint fakeClose; // fake closeTime for testing purposes only
    
    constructor(
        string memory name,     // token name, i.e. AylwardCoin
        string memory symbol,   // token symbol, i.e. WARD
        address payable wallet, // address will receive ETH raised by sale
        uint fundingGoal        // the goal RefundablePostDeliveryCrowdsale
    )
        public
    {
        saleCap = fundingGoal;       // if we set up a funding goal, this should be the cap
        openTime = now;
        closeTime = now + 24 weeks;  // closes in 24 weeks
        fakeClose = now + 10 minutes; // closes in 10 minutes ... for testing only
        
        PupperCoin token = new PupperCoin(name, symbol, 0);  // name, symbol, supply
        token_address = address(token);
        
        PupperCoinSale pupper_sale = new PupperCoinSale(wallet, token, saleCap, openTime, closeTime, fundingGoal);
        pupper_sale_address = address(pupper_sale);
        
        // the great thing about the "deployer" pattern is that one can make the Coinsale contract, i.e. PupperCoinSale a minter
        // then have the PupperCoinSaleDeployer renounce its minter role
        // in other words, create the token and sale ... then set them free into the wild :)
        token.addMinter(pupper_sale_address);
        token.renounceMinter();
    }
}
