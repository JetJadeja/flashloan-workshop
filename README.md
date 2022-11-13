# <h1 align="center"> Penn Flashloan Workshop </h1>

**Contracts for my Flashloan workshop at UPenn on November 12th**

## Introduction to Flashloans
Flash loans are uncollateralized loans in which a user borrows and returns funds in the same transaction. If the user is unable to return the funds before the end of the transaction, the contract will simply revert. This means that the user will not lose any money and will simply go back to their original balance, with the only cost being the gas fee paid by the user. 

Due to their low-risk, simple nature, flash loans have become increasingly popular in the DeFi space. Being to the go-to way to borrow large sums of money without having to put up any collateral, they have been used to speculate on the price of various assets, to arbitrage between exchanges, and to fund liquidity pools.

For example, flash loans are heavily used in arbitrage opportunities. Users can take out a flash loan, use the funds to buy an asset at a lower price on one exchange, and then sell it on another exchange for a higher price. The user can then return the loan amount plus a small fee to the protocol and keep the profit, which, due to the size of the loan, can be significant.

### Contracts

#### **SimpleFlashLender.sol**

This is the most basic flash lender contract. It only has a single function, `borrow(uint256 amount, IFlashLender borrower)`, which executes a flash loan. There are no fees charged on flash borrows. Deposits occur through raw ERC20 transfers and, since there is no `withdraw()` function, liquidity providers cannot withdraw their funds. 


 
#### **IntermediateFlashLender.sol**

This is slightly more complex than the `SimpleFlashLender` contract. It now allows liquidity providers to deposit and withdraw funds through the `deposit(uint256)` and `withdraw(uint256)` functions. There are also fees charged during flash loans, *but* they can only be collected by the owner, who is the deployer of the contract. Liquidity providers are only entitled to their original deposits.

 
#### **AdvancedFlashLender.sol**

While this contract isn't yet ready for production use, it has a variety of feature that should (and would) be used in a flash lending protocol. This contract uses an "IOU" (aka share) based system to keep track of user balance. Essentially, liquidity providers are minted shares when they deposit tokens into the contract. As the contract starts to accrue more tokens through fees, the value of their shares increase in value and they are therefore able to withdraw more. 

For example, if you deposit 10 tokens into the contract when the total balance is at 100 tokens, you'll be minted 10% of the token supply. As the contract's token balance increases, the value of your shares increase. So, once the contract has a balance of 1000 tokens, your shares (which represent 10% of the token supply) will enable you to unlock 100 tokens.

## Getting Started

Clone this template by running:
```sh
git clone https://github.com/JetJadeja/flashloan-workshop.git
```

Ensure to have foundry installed. You can easily install it by running:
```sh
curl -L https://foundry.paradigm.xyz | bash
```

Then, run foundryup in a new terminal session or after reloading your PATH. You can run foundryup by simply doing:
```sh
foundryup
```

## Compiling and testing the codebase.
To compile the codebase, you can run:

```sh
forge build
```

To test the codebase, you can run:

```sh
forge test
```