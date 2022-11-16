# Payment Splitter

## Description

It's being used for sharing revenue on the contract or deliver payments of salary

## How to use

- Add payee with share point on the contract
- Send tokens to the contract
- Release tokens to all payees based on their shares
- Withdraw specific amount of tokens to a receiver without shares
- All ERC20 and native token on the contract can be delivered (only by contract owner)

## Functions

### `totalShares`

Getter for the amount of shares held by an account

#### params

    No params

#### returns

    the amount of shares held by an account

<br>

### `addPayee`

Add a new payee to the contract

#### params

| name      |  type   |                             description |
| :-------- | :-----: | --------------------------------------: |
| \_account | address |         The address of the payee to add |
| \_shares  | uint256 | The number of shares owned by the payee |

#### returns

    No returns

<br>

### `removePayee`

Remove a payee from the contract

#### params

| name      |  type   |                        description |
| :-------- | :-----: | ---------------------------------: |
| \_account | address | The address of the payee to remove |

#### returns

    No returns

<br>

### `updatePayeeShares`

Update a payee shares

#### params

| name      |  type   |                             description |
| :-------- | :-----: | --------------------------------------: |
| \_account | address |      The address of the payee to update |
| \_shares  | uint256 | The number of shares owned by the payee |

#### returns

    No returns

<br>

### `updatePayeeStatus`

Update a payee status

#### params

| name      |  type   |                        description |
| :-------- | :-----: | ---------------------------------: |
| \_account | address | The address of the payee to update |
| \_status  |  bool   |        The new status of the payee |

#### returns

    No returns

<br>

### `releaseEth`

Transfers available Ether of the contract to all \_payees based on their shares

#### params

    No params

#### returns

    No returns

<br>

### `releaseErc20`

Transfers available Ether of the contract to all \_payees based on their shares

#### returns

    No params

#### returns

    No returns

<br>

### `withdrawEth`

Allows admin to withdraw Eth to a receiver without shares

#### params

| name     |  type   |                   description |
| :------- | :-----: | ----------------------------: |
| receiver | address |   The address of the receiver |
| amount   | uint256 | The amount of Eth to withdraw |

#### returns

    No returns

<br>

### `withdrawErc20`

Allows admin to withdraw tokens to a receiver without shares

#### params

| name     |  type   |                               description |
| :------- | :-----: | ----------------------------------------: |
| token    | IERC20  |         The address of the token contract |
| receiver | address | The address which will receive the tokens |
| amount   | uint256 |          The amount of tokens to withdraw |

#### returns

    No returns

<br>

### `totalEthReleased`

Getter for the total ETH released on the contract

#### params

    No Params

#### returns

    the total ETH released on the contract

<br>

### `totalErc20Released`

Getter for the total ERC20 released on the contract

#### params

| name  |  type  |                       description |
| :---- | :----: | --------------------------------: |
| token | IERC20 | The address of the token contract |

#### returns

    the total ERC20 released on the contract

<br>

### `totalEthWithdrawed`

Getter for the total ETH withdrawed on the contract

#### params

    No params

#### returns

    the total ETH withdrawed on the contract

<br>

### `totalErc20Withdrawed`

Getter for the total ERC20 released on the contract

#### params

    No params

#### returns

    the total ERC20 released on the contract

<br>

### `listOfPayees`

Getter for the list of payee

#### params

    No params

#### returns

    the list of payee

<br>

### `shares`

Getter for the amount of shares held by an account

#### params

    No params

#### returns

    the amount of shares held by an account

<br>

### `isEnabled`

Getter for a payeer is enabled or not

#### params

    No params

#### returns

    a payeer is enabled or not

<br>

### `isPayee`

Getter for a payeer is exists or not

#### params

| name    |  type   |   description |
| :------ | :-----: | ------------: |
| account | address | Payee address |

#### returns

    a payeer is exists or not

<br>

### `ethReleased`

Getter for the amount of Ether already released to a payee

#### params

| name    |  type   |   description |
| :------ | :-----: | ------------: |
| account | address | Payee address |

#### returns

    the amount of Ether already released to a payee

<br>

### `erc20Released`

Getter for the amount of `token` tokens already released to a payee. `token` should be the address of an IERC20 contract

#### params

| name    |  type   |                               description |
| :------ | :-----: | ----------------------------------------: |
| token   | IERC20  |         The address of the token contract |
| account | address | The address which will receive the tokens |

#### returns

    the amount of Ether already released to a payee

<br>

### `payeeCount`

Getter for number of the payee address

#### params

    No params

#### returns

    the number of the payee address

<br>

### `releasableEth`

Getter for the amount of payee's releasable Ether

#### params

| name    |  type   |                       description |
| :------ | :-----: | --------------------------------: |
| account | address | The address of the payee to query |

#### returns

    the amount of payee's releasable Ether

<br>

### `releasableErc20`

Getter for the amount of payee's releasable `token` tokens. `token` should be the address of an IERC20 contract

#### params

| name    |  type   |                               description |
| :------ | :-----: | ----------------------------------------: |
| token   | IERC20  |         The address of the token contract |
| account | address | The address which will receive the tokens |

#### returns

    the amount of payee's releasable `token` tokens. `token` should be the address of an IERC20 contract

<br>
