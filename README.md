# GHO Tunes - Recurring Payments on Aave Protocol

Take payments from user in from of the following.

1. In form of ETH Tokens w/ thirdweb payments for card payments.
2. In form of credit delegation from Aave pool

After user sends token the following happens:

the contract will have two functions

1. depositAndPay: This will be used when payments are in ETH tokens. It will do the following:
   - mint the nft for the user and create a ERC 6551 Token bound account with owner as user.
   - send the eth to the new created token bound account.
   - deposit the eth to aave address pool.
   - credit delegate from aave pool for GHO tokens to the main contract.
   - store the address of the ERC-6551 token bound account in the main contract.

## How to run
