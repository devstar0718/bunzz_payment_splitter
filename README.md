# Payment Splitter
## Description
It's being used for sharing revenue on the contract or deliver payments of salary
## Main Work Flow
- Set address and shares for each delivery
- Send tokens to the contract
- User pull tokens assigned to him based on shares
- All ERC20 and native token on the contract can be delivered
## Functions
### Write Functions
- `_addPayee ` - set address and shares of payee(only once on constructor)
- `release ` - release pending token to payee based on the shares
### Read Functions
- `released ` - get token amount of released token of payee
- `releasable ` - get pending amount of token to be released based on the shares of payee
- `totalShares ` - get total shares of all payees
- `totalReleased ` - get total amount of released token on the contract
- `shares ` - get shares of payee
- `payee ` - get address of payee with index
- `payeeCount` - get number of payees