# CDP Stablecoin Engine

A professional-grade implementation of a decentralized stablecoin system. This repository mimics the core logic of MakerDAO, enabling a "Mint-by-Debt" model. Users can lock their ETH in a vault to mint a pegged stablecoin (e.g., $USDX$), maintaining a minimum collateralization ratio to ensure system solvency.

## Core Features
* **Over-Collateralization:** Secure 150% minimum ratio to protect the peg.
* **Debt Accounting:** Tracks individual user positions and total system debt.
* **Liquidation Logic:** Publicly accessible functions to liquidate under-collateralized positions.
* **Oracle Integration:** Uses real-time price feeds to calculate Health Factors.

## Workflow
1. **Deposit & Mint:** Lock ETH and mint $USDX$ up to the borrowing limit.
2. **Repay & Unlock:** Burn $USDX$ to reclaim the locked ETH.
3. **Liquidate:** If ETH price drops, others can repay the debt to seize the collateral at a discount.

## Setup
1. `npm install`
2. Deploy `Stablecoin.sol` and the `CDPEngine.sol`.
