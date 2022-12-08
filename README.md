# Payment Splitter

## Overview

This connects with other contract and used for sharing accumulated tokens on the contract with shared accounts.

The number of shared accounts is limited up to 10 and can be used for sharing revenues with limited number of accounts. (NFT Mint, Launch Token, ...)

## How to use

1. Add payee with share point on the contract
2. Connect with other contracts which accumulates tokens (both ERC20 and native token) itself.
3. Release tokens to payees based on their shares
4. Contract owner can update the shares of payees, and disable the payee to prevent further payments(Of course can enable the payee again if needed)

## Usage

In most cases, the contract accumulates tokens itself and then releases them to payees.

_example:_

1. Token Launch contract is getting fee from the transaction(sell, buy, transfer, ...)
2. DEFI contract is getting the fee from user's deposit and stake.
3. NFT Mint contract has some minting price and the contract is getting tokens from the minting transaction.
4. NFT Marketplace contract is getting fee from the tradings(sell, buy, transfer, ...)\
   ...

For above cases, the contracts need to have functions to withdraw the accumulated tokens or release them to payees with shares.

Using PaymentSplitter, the above contracts doesn't need to have those functions, just connect with PaymentSplitter and add payees with shares and release it to the payees.

## Functions

### WRITE

`addPayee`

Add a new payee with shares, only by **owner**

| name      | type    | description                             |
| :-------- | :------ | :-------------------------------------- |
| \_account | address | The address of the payee to add         |
| \_shares  | uint256 | The number of shares owned by the payee |

<br>

`removePayee`

Remove a payee from the contract, only by **owner**

| name      | type    | description                        |
| :-------- | :------ | :--------------------------------- |
| \_account | address | The address of the payee to remove |

<br>

`updatePayeeShares`

Update a payee shares, only by **owner**

A payee's shares can't be 0

| name      | type    | description                             |
| :-------- | :------ | :-------------------------------------- |
| \_account | address | The address of the payee to update      |
| \_shares  | uint256 | The number of shares owned by the payee |

<br>

`updatePayeeStatus`

Update a payee status, only by **owner**

Can't release payment to a disabled payee

| name      | type    | description                        |
| :-------- | :------ | :--------------------------------- |
| \_account | address | The address of the payee to update |
| \_status  | bool    | The new status of the payee        |

<br>

`withdrawEth`

Withdraw Eth to a receiver without shares, only by **owner**

| name     | type    | description                   |
| :------- | :------ | :---------------------------- |
| receiver | address | The address of the receiver   |
| amount   | uint256 | The amount of Eth to withdraw |

<br>

`withdrawErc20`

Withdraw ERC20 tokens to a receiver without shares, only by **owner**

| name     | type    | description                               |
| :------- | :------ | :---------------------------------------- |
| token    | IERC20  | The address of the token contract         |
| receiver | address | The address which will receive the tokens |
| amount   | uint256 | The amount of tokens to withdraw          |

<br>

`setMaxPayeeCounter`

Set max count of payees, only by **owner**

Owner can't add payee more than max counter(which should be less than 10)

| name      | type   | description              |
| :-------- | :----- | :----------------------- |
| \_counter | IERC20 | Max value of payee count |

<br>

`releaseEth`

Transfers available ETH of the contract to all payees based on their shares

    No params

<br>

`releaseErc20`

Transfers available ERC20 token of the contract to all payees based on their shares

    No params

<br>

### READ

`totalEthReleased`

Getter for the total ETH released on the contract

    No Params

<br>

`totalErc20Released`

Getter for the total ERC20 released on the contract

| name  | type   | description                       |
| :---- | :----- | :-------------------------------- |
| token | IERC20 | The address of the token contract |

<br>

`totalEthWithdrawn`

Getter for the total ETH withdrawn on the contract

    No params

<br>

`totalErc20Withdrawn`

Getter for the total ERC20 released on the contract

    No params

<br>

`listOfPayees`

Getter for the list of payee

    No params

<br>

`maxPayeeCounter`

Getter for the max count of payees

    No params

<br>

`totalShares`

Getter for total amount of shares on the contract

    No params

<br>

`shares`

Getter for the amount of shares held by an account

| name    | type    | description   |
| :------ | :------ | :------------ |
| account | address | Payee address |

<br>

`isEnabled`

Getter for a payee is enabled or not

| name    | type    | description   |
| :------ | :------ | :------------ |
| account | address | Payee address |

<br>

`isPayee`

Getter for a payee is exists or not

| name    | type    | description   |
| :------ | :------ | :------------ |
| account | address | Payee address |

<br>

`ethReleased`

Getter for the amount of ETH already released to a payee

| name    | type    | description   |
| :------ | :------ | :------------ |
| account | address | Payee address |

<br>

`erc20Released`

Getter for the amount of `token` tokens already released to a payee

`token` is address of the IERC20 contract

| name    | type    | description                       |
| :------ | :------ | :-------------------------------- |
| token   | IERC20  | The address of the token contract |
| account | address | Payee address                     |

<br>

`payeeCount`

Getter for number of the payee address

    No params

<br>

`releasableEth`

Getter for the amount of payee's releasable ETH

| name    | type    | description                       |
| :------ | :------ | :-------------------------------- |
| account | address | The address of the payee to query |

<br>

`releasableErc20`

Getter for the amount of payee's releasable `token` tokens

`token` is address of the IERC20 contract

| name    | type    | description                       |
| :------ | :------ | :-------------------------------- |
| token   | IERC20  | The address of the token contract |
| account | address | The address of the payee to query |

<br>

## Events

`PayeeAdded`

Emitted when a new payee is added

| name    | type    | description                             |
| :------ | :------ | :-------------------------------------- |
| account | address | The address of the payee to add         |
| shares  | uint256 | The number of shares owned by the payee |

<br>

`PayeeRemoved`

Emitted when a payee is removed

| name    | type    | description                        |
| :------ | :------ | :--------------------------------- |
| account | address | The address of the payee to remove |

<br>

`PayeeUpdatedShares`

Emitted when a payee's shares are updated

| name         | type    | description                                  |
| :----------- | :------ | :------------------------------------------- |
| account      | address | The address of the payee to update           |
| beforeShares | uint256 | Previous number of shares owned by the payee |
| shares       | uint256 | The number of shares owned by the payee      |

<br>

`PayeeUpdatedStatus`

Emitted when a payee's status is updated

| name         | type    | description                        |
| :----------- | :------ | :--------------------------------- |
| account      | address | The address of the payee to update |
| beforeStatus | bool    | Previous status of the payee       |
| status       | bool    | The new status of the payee        |

<br>

`EthPaymentReleased`

Emitted when ETH is released to a payee

| name    | type    | description                            |
| :------ | :------ | :------------------------------------- |
| account | address | The address of the payee to release to |
| amount  | uint256 | The amount of ETH released to the pay  |

<br>

`ERC20PaymentReleased`

Emitted when `token` tokens are released to a payee

| name    | type    | description                            |
| :------ | :------ | :------------------------------------- |
| token   | IERC20  | The address of the token contract      |
| account | address | The address of the payee to release to |
| amount  | uint256 | The amount of ETH released to the pay  |

<br>

`EthPaymentWithdrawn`

Emitted when ETH is withdrawn from the contract

| name    | type    | description                             |
| :------ | :------ | :-------------------------------------- |
| account | address | The address of the payee to withdraw to |
| amount  | uint256 | The amount of ETH withdrawn from the    |

<br>

`ERC20PaymentWithdrawn`

Emitted when `token` tokens are withdrawn from the contract

| name    | type    | description                             |
| :------ | :------ | :-------------------------------------- |
| token   | IERC20  | The address of the token contract       |
| account | address | The address of the payee to withdraw to |
| amount  | uint256 | The amount of tokens withdrawn from the |

<br>

`MaxPayeeCounterUpdated`

Emitted when max counter of payee is updated

| name | type    | description                   |
| :--- | :------ | :---------------------------- |
| prev | uint256 | Previous max counter of payee |
| next | uint256 | The new max counter of payee  |
