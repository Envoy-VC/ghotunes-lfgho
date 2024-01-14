# GHO Tunes - Recurring Payments on Aave Protocol

Take payments from user in from of the following.

1. In form of GHO Tokens
2. In form of ETH Tokens w/ thirdweb payments for card payments.
3. In form of credit delegation from Aave pool

After user sends token the following happens:

1. if payment is in GHO then
   1. GHO is transferred to the vault account
   2. NFT is Minted as per the payment and tier of subscription.
2. if payment is in ETH then
   1. ETH is deposited on Aave.
   2. GHO is borrowed from Aave.
   3. GHO is transferred to the vault account.
   4. NFT is minted as per the payment and tier of subscription
3. If payment is in credit delegation then
   1. GHO is borrowed from Aave keeping the asset from Collateral.
   2. GHO is transferred to the vault account.
   3. NFT is minted as per the payment and tier of subscription

## How to run
