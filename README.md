<!-- @format -->

# 💳 GHO Tunes - Recurring Payments on Aave Protocol

Gho Tunes introduces a novel payment model within the Aave Protocol ecosystem, built upon the GHO stablecoin. This system leverages GHO Credit delegation and Chainlink cron-based automation to establish robust recurring payments directly on the blockchain.

### Core Technology:

1. **GHO Credit Delegation**: Users allocate a specific amount of their GHO tokens to the GHO Tunes contract, enabling automatic recurring payments without manual intervention.
2. **Chainlink Cron Upkeeps**: This decentralized oracle service triggers scheduled payments based on predefined intervals, ensuring timely deductions for chosen subscription tiers.

---

This app is an example of such recurring payments model in form of a simple music streaming service. Users can subscribe to a monthly plan and pay in GHO tokens. The subscription is automatically renewed every month.

GHO Tunes uses Audius, a decentralized music platform that curates and hosts independent artists' work.

![Music Streaming App](https://storage.googleapis.com/ethglobal-api-production/projects%2Fi252t%2Fimages%2FSCR-20240121-ofxw.png)

Currently there are three Subscription Tiers:

1. **Free**: GHO Tokens per month
2. **Silver**: 5 GHO Tokens per month
3. **Gold**: 10 GHO Tokens per month

---

## How it works 🛠️

GHO Tunes offers three distinct methods for subscribing, providing flexibility and catering to users' existing liquidity positions. Here's a detailed breakdown of the underlying process:

### Pay with ETH

1. User specifies the subscription tier and send ether equivalent to the GHO Borrow Value. Along with that the user also sends wETH and GHO delegation signatures.
2. The provided ETH is converted to wETH through a designated gateway and the amount is delegated to the Aave Pool.
3. The gateway supplies the wETH to the Aave Protocol on the user's behalf, creating a borrow position equivalent to the chosen subscription tier (0, 5, or 10 GHO tokens).
4. Then the subscription amount (0,5,10 GHO Tokens) are credit delegated to the Tunes smart contract to initiate the subscription.
5. The smart contract borrows the first month's GHO tokens from Aave based on the chosen tier and user's delegated permissions.
6. A unique dynamic Subscription NFT is minted with, containing details about the tier, start date, and duration.
7. An Custom ERC-6551 Token Bound Account (TBA) is created, linked to the NFT and responsible for handling subsequent monthly payments.
8. A new CRON-based upkeep is created via Chainlink automation, triggering the TBA to pay the subscription amount every month.

### Pay with GHO Tokens

This is similar to the ETH flow, except that the user does not send ETH or any signatures. The GHO tokens are already approved for the Tunes contract and the user only needs to send the tier.

### Pay with Credit Delegation (user has already delegated GHO Tokens)

This method is similar to the ETH flow, except that the user does not send ETH or any signatures. The GHO tokens are already delegated to the Tunes contract and the user only needs to send the tier. Once the user calls the subscribe function, the Tunes contract will borrow the first month's GHO tokens from Aave based on the chosen tier and user's delegated permissions.

---

## How Subscriptions Work? 📅

The subscription is based on a custom ERC-721 NFT. The NFT contains the following information:

- Subscription Tier
- Subscription Price
- Valid Until (Timestamp)

Whenever a user subscribes, a new NFT is minted and the user is assigned a Custom ERC-6551 Token Bound Account (TBA).

The Upkeep is created for the TBA and it is responsible for paying the subscription amount every month.

Whenever the upkeep runs, the TBA calls the Tunes contract and the amount of GHO Tokens are borrowed on behalf of the user. The borrowed tokens are then used to pay the subscription amount.

If the upkeep fails, the user is dropped to the free tier and the upkeep is paused. The user can then subscribe again.

---

## Deployed Contract Addresses (Sepolia Testnet) 📝

- **GHOTunes**: Entrypoint contract for the Platform - [0x766EcD241899AbA389a999D01527afd7B55F999D](https://sepolia.etherscan.io/address/0x766EcD241899AbA389a999D01527afd7B55F999D)
- **AccountRegistry**: Custom ERC-6551 Token Bound Account Registry - [0xB2aF159C02B708F3270929d6D2b0E01b415CBFaB](https://sepolia.etherscan.io/address/0xB2aF159C02B708F3270929d6D2b0E01b415CBFaB)
- **GHOTunesAccount**: Custom ERC-6551 Token Bound Account Implementation - [0x02945dd450060CC5ac2ED433574F1Eb79B3AA592](https://sepolia.etherscan.io/address/0x02945dd450060CC5ac2ED433574F1Eb79B3AA592)
- **Token**: Dynamic Metadata ERC-721 Token - [0xfA40d87372C2fE09E36A7f544479FB290e20e02b](https://sepolia.etherscan.io/address/0xfA40d87372C2fE09E36A7f544479FB290e20e02b)

## FAQs ❓

#### Q. What happens if the upkeep fails?

If the upkeep fails, the current subscription will be cancelled and the user will be dropped to the free tier. The user can then subscribe again. This also pauses the upkeep contract so that it does not trigger again.

#### Q. Is Upkeep created if user creates a free account?

No, the upkeep is only created when the user subscribes to a paid tier. if the user migrates from free to paid a upkeep is crated only once.

#### Q. What happens to cron scheduling if the Upkeep Fails?

If the upkeep fails the user will be dropped to the free tier and upkeep will be paused. Whenever the user subscribes again, the upkeep will be updated. eg - If a user's upkeep is meant to run on 20th of each month but it fails and then the user resubscribes on 25th, the upkeep will be updated to run on 25th of each month.

#### Q. What happens to Dynamic NFTs?

Whenever the upkeep runs, whether it is successful or not, the NFT is updated with the new subscription date. This is done so that the user can always check the next payment date.

#### Q. Can user change subscriptions?

Yes, the user can change subscriptions at any time. If the user is on a paid tier and wants to migrate to a higher tier, he/she can call the contract and the subscription will be updated from the next Cron run.

And when the upkeep runs, the subscription amount is updated based on the new tier and NFT is updated with the new subscription date and tier.

---

## Screenshots 📸

<table>
  <tr>
    <td valign="top" width="50%">
      <br>
      <img src="https://storage.googleapis.com/ethglobal-api-production/projects%2Fi252t%2Fimages%2FSCR-20240121-ogve.png" alt="Homepage" >
    </td>
    <td valign="top" width="50%">
      <br>
      <img src="https://storage.googleapis.com/ethglobal-api-production/projects%2Fi252t%2Fimages%2FSCR-20240121-ofra.png" alt="Pricing" >
    </td>
  </tr>
</table>

<table>
  <tr>
    <td valign="top" width="50%">
      <br>
      <img src="https://storage.googleapis.com/ethglobal-api-production/projects%2Fi252t%2Fimages%2FSCR-20240121-ofsv.png" alt="SCR-20231208-cyyh" alt="Subscribe Modal" >
    </td>
    <td valign="top" width="50%">
      <br>
      <img src="https://storage.googleapis.com/ethglobal-api-production/projects%2Fi252t%2Fimages%2FSCR-20240121-ogzu.png" alt="Tests" >
    </td>
  </tr>
</table>

---

## How to run the project locally

Make sure you have Node.js, pnpm and Foundry installed on your system.

## Getting Started 🚀

### 📝 Smart Contract

To get started with GHOTunes smart contracts, follow these steps:

1. Navigate to the `contracts` directory and locate the contracts under the `src` folder.
2. Install the necessary dependencies by running the following command:
   ```bash
   forge install && pnpm install
   ```
3. To compile the contracts, run the following command:

   ```bash
    forge compile
   ```

4. To run tests, run the following command:
   ```bash
   forge test
   ```
5. To run deploy script, you can run the following command

   ```bash
   source .env

   forge script --chain-id 11155111 script/Deploy.s.sol:Deploy --rpc-url $SEPOLIA_URL --broadcast --verify -vvvv
   ```

### 📱 GHOTunes Frontend

To get started with the Frontend app, follow these steps:
Navigate to the `app` directory and install the necessary dependencies by running the following command:

```bash
pnpm install
```

Create a new file called `.env.local` in the root directory of the `app`. Fill out all the required environment variables as per the `.env.example` file.

Once you have filled in the environment variables in the `.env.local` file, you can start the development server by running the following command:

```bash
pnpm run dev
```

Go to http://localhost:3000 to view the app.

---
