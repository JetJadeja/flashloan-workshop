# <h1 align="center"> Penn Flashloan Workshop </h1>

**Contracts for my Flashloan workshop at UPenn on November 12th**

## Introduction to Flashloans
Flash loans are uncollateralized loans in which a user borrows and returns funds in the same transaction. If the user is unable to return the funds before the end of the transaction, the contract will simply revert. This means that the user will not lose any money and will simply go back to their original balance, with the only cost being the gas fee paid by the user. 

Due to their low-risk, simple nature, flash loans have become increasingly popular in the DeFi space. Being to the go-to way to borrow large sums of money without having to put up any collateral, they have been used to speculate on the price of various assets, to arbitrage between exchanges, and to fund liquidity pools.

For example, flash loans are heavily used in arbitrage opportunities. Users can take out a flash loan, use the funds to buy an asset at a lower price on one exchange, and then sell it on another exchange for a higher price. The user can then return the loan amount plus a small fee to the protocol and keep the profit, which, due to the size of the loan, can be significant.

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