// SPDX-License-Identifier: MIT
// @author: Developed by Alex and Bunzz.
// @descpriton: Payment Splitter module for share revenue or salary with trasparency

pragma solidity ^0.8.0;

import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/Context.sol";
import "@openzeppelin/contracts/token/ERC20/utils/SafeERC20.sol";
import "./interfaces/IPaymentSplitter.sol";
import "./interfaces/IBunzz.sol";

/**
 * @title PaymentSplitter
 * @dev This contract allows to split Ether payments among a group of accounts. The sender does not need to be aware
 * that the Ether will be split in this way, since it is handled transparently by the contract.
 */
contract PaymentSplitter is Context, Ownable, IPaymentSplitter, IBunzz {
    uint256 private _totalShares; // Total shares

    uint256 private _totalEthReleased; // Total released eth
    mapping(IERC20 => uint256) private _totalErc20Released; // Total released erc20

    uint256 private _totalEthWithdrawed; // Total withdrawed eth
    mapping(IERC20 => uint256) private _totalErc20Withdrawed; // Total withdrawed erc20

    bool private _onlyAfterRelease; // checking release flag
    uint256 private _releaseableAmount; // releaseable amount

    address public paymentContract;

    struct PayeeInfo {
        uint256 shares; // Shares assigned to the payee
        uint256 ethReleased; // Released eth to the payee
        mapping(IERC20 => uint256) erc20Released; // Released erc20 to the payee
        bool enabled; // Payee status
        bool exists; // Payee exists
    }
    mapping(address => PayeeInfo) private _payeeInfos; // Payee infos

    address[] private _payees; // _payees list

    event PayeeAdded(address account, uint256 shares);
    event PayeeRemoved(address account);
    event PayeeUpdatedShares(
        address account,
        uint256 beforeShares,
        uint256 shares
    );
    event PayeeUpdatedStatus(address account, bool beforeStatus, bool status);

    event EthPaymentWithdrawed(address to, uint256 amount);
    event ERC20PaymentWithdrawed(
        IERC20 indexed token,
        address to,
        uint256 amount
    );

    modifier onlyAfterReleaseEth() {
        require(_onlyAfterRelease != true);
        _onlyAfterRelease = true;
        _releaseableAmount = address(this).balance;
        _;
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _onlyAfterRelease = false;
    }

    modifier onlyAfterReleaseErc20(IERC20 token) {
        require(_onlyAfterRelease != true);
        _onlyAfterRelease = true;
        _releaseableAmount = token.balanceOf(address(this));
        _;
        // By storing the original value once again, a refund is triggered (see
        // https://eips.ethereum.org/EIPS/eip-2200)
        _onlyAfterRelease = false;
    }

    constructor() {}

    /**
     * @dev receive BNB when msg.data is empty
     **/
    receive() external payable {}

    function connectToOtherContracts(address[] calldata contracts)
        external
        override
        onlyOwner
    {
        paymentContract = contracts[0];
    }

    /**
     * @dev Getter for the amount of shares held by an account.
     */
    function totalShares() external view override returns (uint256) {
        return _totalShares;
    }

    /**
     * @dev Add a new payee to the contract.
     * @param _account The address of the payee to add.
     * @param _shares The number of shares owned by the payee.
     */
    function addPayee(address _account, uint256 _shares) external onlyOwner {
        require(
            !isPayee(_account),
            "PaymentSplitter: account is already a payee"
        );
        require(_shares > 0, "PaymentSplitter: shares are 0");

        PayeeInfo storage payeeInfo = _payeeInfos[_account];
        payeeInfo.shares = _shares;
        payeeInfo.enabled = true;
        payeeInfo.exists = true;
        _payees.push(_account);

        _totalShares += _shares;

        emit PayeeAdded(_account, _shares);
    }

    /**
     * @dev Remove a payee from the contract.
     * @param _account The address of the payee to remove.
     */
    function removePayee(address _account) external onlyOwner {
        require(isPayee(_account), "PaymentSplitter: account not added");

        _totalShares -= shares(_account);
        delete _payeeInfos[_account];

        for (uint256 i = 0; i < _payees.length; i++) {
            if (_payees[i] == _account) {
                _payees[i] = _payees[_payees.length - 1];
                _payees.pop();
                break;
            }
        }

        emit PayeeRemoved(_account);
    }

    /**
     * @dev Update a payee shares.
     * @param _account The address of the payee to update.
     * @param _shares The number of shares owned by the payee.
     */
    function updatePayeeShares(address _account, uint256 _shares)
        external
        onlyOwner
    {
        require(isPayee(_account), "PaymentSplitter: account not added");
        require(
            _shares > 0,
            "PaymentSplitter: cannot update to 0, please remove the Payee instead"
        );

        PayeeInfo storage payeeInfo = _payeeInfos[_account];
        uint256 _beforeShares = payeeInfo.shares;
        payeeInfo.shares = _shares;

        _totalShares -= _beforeShares;
        _totalShares += _shares;

        emit PayeeUpdatedShares(_account, _beforeShares, _shares);
    }

    /**
     * @dev Update a payee status.
     * @param _account The address of the payee to update.
     * @param _status The new status of the payee.
     */
    function updatePayeeStatus(address _account, bool _status)
        external
        onlyOwner
    {
        require(isPayee(_account), "PaymentSplitter: account not added");

        PayeeInfo storage payeeInfo = _payeeInfos[_account];
        bool _beforeStatus = payeeInfo.enabled;
        payeeInfo.enabled = _status;

        emit PayeeUpdatedStatus(_account, _beforeStatus, _status);
    }

    /**
     * @dev Transfers available Ether of the contract to all _payees based on their shares
     */
    function releaseEth() external override onlyAfterReleaseEth {
        for (uint256 i = 0; i < _payees.length; i++) {
            if (isEnabled(_payees[i])) {
                releaseEth(payable(_payees[i]));
            }
        }
    }

    /**
     * @dev Transfers available `token` tokens of the contract to all _payees based on their shares
     */
    function releaseEr20(IERC20 token)
        external
        override
        onlyAfterReleaseErc20(token)
    {
        for (uint256 i = 0; i < _payees.length; i++) {
            if (isEnabled(_payees[i])) {
                releaseErc20(token, _payees[i]);
            }
        }
    }

    /**
     * @dev Allows admin to withdraw Eth to a receiver without shares.
     * @param receiver The address of the receiver.
     * @param amount The amount of Eth to withdraw.
     */
    function withdrawEth(address payable receiver, uint256 amount)
        external
        onlyOwner
    {
        require(
            receiver != address(0),
            "PaymentSplitter: receiver is the zero address"
        );
        require(amount > 0, "PaymentSplitter: amount is the zero");
        require(
            address(this).balance >= amount,
            "PaymentSplitter: not enough balance"
        );

        Address.sendValue(receiver, amount);
        _totalEthWithdrawed += amount;

        emit EthPaymentWithdrawed(receiver, amount);
    }

    /**
     * @dev Allows admin to withdraw tokens to a receiver without shares.
     * @param token IERC20 The address of the token contract
     * @param receiver address The address which will receive the tokens
     * @param amount uint256 The amount of tokens to withdraw
     */
    function withdrawErc20(
        IERC20 token,
        address receiver,
        uint256 amount
    ) external onlyOwner {
        require(
            receiver != address(0),
            "PaymentSplitter: receiver is the zero address"
        );
        require(amount > 0, "PaymentSplitter: amount is the zero");
        require(
            token.balanceOf(address(this)) >= amount,
            "PaymentSplitter: not enough balance"
        );

        SafeERC20.safeTransfer(token, receiver, amount);
        _totalErc20Withdrawed[token] += amount;

        emit ERC20PaymentWithdrawed(token, receiver, amount);
    }

    /**
     * @dev Getter for the total ETH released on the contract
     */
    function totalEthReleased() external view onlyOwner returns (uint256) {
        return _totalEthReleased;
    }

    /**
     * @dev Getter for the total ERC20 released on the contract
     */
    function totalErc20Released(IERC20 token)
        external
        view
        onlyOwner
        returns (uint256)
    {
        return _totalErc20Released[token];
    }

    /**
     * @dev Getter for the total ETH withdrawed on the contract
     */
    function totalEthWithdrawed() external view onlyOwner returns (uint256) {
        return _totalEthWithdrawed;
    }

    /**
     * @dev Getter for the total ERC20 released on the contract
     */
    function totalErc20Withdrawed(IERC20 token)
        external
        view
        onlyOwner
        returns (uint256)
    {
        return _totalErc20Withdrawed[token];
    }

    function listOfPayees() external view onlyOwner returns (address[] memory) {
        return _payees;
    }

    /**
     * @dev Getter for the amount of shares held by an account.
     */
    function shares(address account) public view override returns (uint256) {
        return _payeeInfos[account].shares;
    }

    /**
     * @dev Getter for a payeer is enabled or not
     */
    function isEnabled(address account) public view override returns (bool) {
        return _payeeInfos[account].enabled;
    }

    /**
     * @dev Getter for a payeer is exists or not
     * @param account Payee address
     */
    function isPayee(address account) public view override returns (bool) {
        return _payeeInfos[account].exists;
    }

    /**
     * @dev Getter for the amount of Ether already released to a payee.
     * @param account Payee address
     */
    function ethReleased(address account)
        public
        view
        override
        returns (uint256)
    {
        return _payeeInfos[account].ethReleased;
    }

    /**
     * @dev Getter for the amount of `token` tokens already released to a payee. `token` should be the address of an
     * IERC20 contract.
     * @param token IERC20 The address of the token contract
     * @param account address The address which will receive the tokens
     */
    function erc20Released(IERC20 token, address account)
        public
        view
        override
        returns (uint256)
    {
        return _payeeInfos[account].erc20Released[token];
    }

    /**
     * @dev Getter for number of the payee address.
     */
    function payeeCount() public view override returns (uint256) {
        return _payees.length;
    }

    /**
     * @dev Getter for the amount of payee's releasable Ether.
     * @param account The address of the payee to query.
     */
    function releasableEth(address account)
        public
        view
        override
        returns (uint256)
    {
        require(isPayee(account), "PaymentSplitter: account not added");

        uint256 _totalReleasableAmount = _onlyAfterRelease
            ? _releaseableAmount
            : address(this).balance;
        uint256 _amount = (_totalReleasableAmount * shares(account)) /
            _totalShares;
        return _amount;
    }

    /**
     * @dev Getter for the amount of payee's releasable `token` tokens. `token` should be the address of an
     * IERC20 contract.
     * @param token IERC20 The address of the token contract
     * @param account address The address which will receive the tokens
     */
    function releasableErc20(IERC20 token, address account)
        public
        view
        override
        returns (uint256)
    {
        require(isPayee(account), "PaymentSplitter: account not added");

        uint256 _totalReleasableAmount = _onlyAfterRelease
            ? _releaseableAmount
            : token.balanceOf(address(this));
        uint256 _amount = (_totalReleasableAmount * shares(account)) /
            _totalShares;
        return _amount;
    }

    /**
     * @dev Transfers available Ether of the contract to a payee.
     * @param account The address to release Ether to.
     */
    function releaseEth(address payable account) private {
        require(isEnabled(account), "PaymentSplitter: account not enabled");

        uint256 payment = releasableEth(account);

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _payeeInfos[account].ethReleased += payment;
        _totalEthReleased += payment;

        Address.sendValue(account, payment);
        emit EthPaymentReleased(account, payment);
    }

    /**
     * @dev Transfers available `token` tokens of the contract to a payee.
     * @param token IERC20 The address of the token contract
     * @param account address The address which will receive the tokens
     */
    function releaseErc20(IERC20 token, address account) private {
        require(isEnabled(account), "PaymentSplitter: account not enabled");

        uint256 payment = releasableErc20(token, account);

        require(payment != 0, "PaymentSplitter: account is not due payment");

        _payeeInfos[account].erc20Released[token] += payment;
        _totalErc20Released[token] += payment;

        SafeERC20.safeTransfer(token, account, payment);
        emit ERC20PaymentReleased(token, account, payment);
    }
}
