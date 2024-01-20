<!-- @format -->

# GHO Tunes - Recurring Payments on Aave Protocol

User can subscribe in following ways:

1. Pay ETH directly which will be deposited to Aave and GHO Tokens will be borrowed.
2. If user has already delegated credit, they can subscribe and GHO Tokens will be borrowed.
3. Pay directly in form of GHO Tokens.

After user sends token the following happens:

### Pay with ETH

1. ETH is converted to wETH through Gateway.
2. Approve Credit delegation to Gateway for WETH Debt tokens.
3. Approve Credit delegation of GHO Tokens for duration to Smart Contract.
4. Borrow GHO Tokens for first month on behalf of user.
5. Mint a Subscription NFT with details about the Subscription.
6. Create a ERC-6551 Token bound Account(TBA) linked to the NFT.
7. Create a new Time based Upkeep via Chainlink automation to run every month on the TBA Account.

### Pay with GHO Tokens

1. Approve Credit delegation of GHO Tokens for duration to Smart Contract.
2. Borrow GHO Tokens for first month on behalf of user.
3. Mint a Subscription NFT with details about the Subscription.
4. Create a ERC-6551 Token bound Account(TBA) linked to the NFT.
5. Create a new Time based Upkeep via Chainlink automation to run every month on the TBA Account.

### Pay with Credit Delegation(user has already delegated GHO Tokens)

1. Borrow GHO Tokens for first month on behalf of user.
2. Mint a Subscription NFT with details about the Subscription.
3. Create a ERC-6551 Token bound Account(TBA) linked to the NFT.
4. Create a new Time based Upkeep via Chainlink automation to run every month on the TBA Account.

Deploying GHOTunes with account 0xe269688F24e1C7487f649fC3dCD99A4Bf15bDaA1
AccountRegistry deployed at 0xB2aF159C02B708F3270929d6D2b0E01b415CBFaB
GHOTunesAccount deployed at 0x02945dd450060CC5ac2ED433574F1Eb79B3AA592
Token deployed at 0xfA40d87372C2fE09E36A7f544479FB290e20e02b
GHOTunes deployed at 0x766EcD241899AbA389a999D01527afd7B55F999D
