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

### `releaseErc20`
Release the token on contract to all payees based on their shares

| name        | type             | description                       |
| :---        |    :----:        |          ---:                     |
| token       | IERC20           | address of the token                  |

No returns
<br>

### `shares`

Returns shares for all payees on the contract
| name        | type             | description                       |
| :---        |    :----:        |          ---:                     |
| account     | address          | address of the payee              |

It returns shares of the account

<br>