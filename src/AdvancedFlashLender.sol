// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

// Interfaces
import "src/interfaces/IFlashBorrower.sol";
import "solmate/tokens/ERC20.sol";

// Libraries
import "solmate/utils/SafeTransferLib.sol";

/// @title Advanced Flash Lender
/// @author Jet Jadeja <jet@pentagon.xyz>
/// @notice Flash lender contract that incentivises token holders to supply liquidity to earn yield from fees.
/// @notice This contract uses an "IOU" system (shares) to track the amount of tokens that are owed to each user.
/// This basically means that it will mint tokens to liquidity providers when they deposit funds, and 
/// burn them when they withdraw funds. This allows the contract to keep track of how much each user
/// has supplied.
contract AdvancedFlashLender is ERC20 {
    using SafeTransferLib for ERC20;

    /*///////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice The address of the ERC20 contract.
    ERC20 public immutable TOKEN;

    /// @notice The percentage fee that is charged on flash loans.
    /// It is important to note that this is a "mantissa", which means that it is scaled by 1e18.
    /// So, a fee of 100% would actually be 1e18. A fee of 5% would be 0.05e18.
    uint256 public immutable FEE;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Set up the flash lender contract.
    constructor(ERC20 _TOKEN, uint256 _FEE) ERC20("Advanced Flash Lender Share", "AFLS", 18) {
        // Set our immutable values.
        TOKEN = _TOKEN;
        FEE = _FEE;
    }

    /*///////////////////////////////////////////////////////////////
                          SHARE PRICE INTERFACE
    //////////////////////////////////////////////////////////////*/

    /// @notice Calculate the exchange rate between the share tokens and the underlying tokens.
    /// @return The exchange rate scaled by 1e18.
    function sharePrice() public view returns (uint256) {
        // Store the contracts's total underlying balance and IOU supply.
        uint256 supply = totalSupply;
        uint256 balance = TOKEN.balanceOf(address(this));

        // If the supply or balance is zero, return an exchange rate of 1.
        if (supply == 0 || balance == 0) return 1e18;

        // Calculate the exchange rate by diving the underlying balance by the share supply.
        return (balance * 1e18) / supply;
    }

    /// @notice Calculate the amount of underlying tokens that are held by a user.
    function balanceOfUnderlying(address account) public view returns (uint256) {
        // If this function is called in the middle of a transaction, the share price will change.
        require(!inFlashLoan, "Cannot call this function during a flash loan");

        // Calculate and return the amount of underlying tokens held by the user.
        return (balanceOf[account] * sharePrice()) / 1e18;
    }

    /*///////////////////////////////////////////////////////////////
                       LIQUIDITY PROVIDER INTERFACE
    //////////////////////////////////////////////////////////////*/

    /// @notice Deposit funds into the flash lender contract.
    /// @param amount The amount of funds to deposit.
    function deposit(uint256 amount) external {
        // Ensure that the contract is not currently executing a flash loan.
        require(!inFlashLoan, "Cannot deposit while flash loan is active");

        // Transfer the tokens from the sender to the contract.
        // Must have tokens approved.
        TOKEN.safeTransferFrom(msg.sender, address(this), amount);

        // Mint shares to the depositor.
        _mint(msg.sender, (amount * 1e18) / sharePrice());
    }

    /// @notice Withdraw funds from the flash lender contract.
    /// @param amount The amount of funds to withdraw.
    /// Will fail if the liquidity provider does not have enough funds.
    function withdraw(uint256 amount) external {
        // Ensure that the contract is not currently executing a flash loan.
        require(!inFlashLoan, "Cannot withdraw while flash loan is active");

        // Calculate the amount of shares needed to withdraw the given amount of tokens.
        uint256 shares = (sharePrice() * amount) / 1e18;

        // Ensure that the liquidity provider has enough funds.
        // This technically isn't necessary. Solidity SafeMath would automatically revert.
        require(balanceOf[msg.sender] >= shares, "Not enough funds");

        // Burn the shares from the liquidity provider.
        _burn(msg.sender, (sharePrice() * amount) / 1e18);

        // Transfer the tokens from the contract to the liquidity provider.
        TOKEN.safeTransfer(msg.sender, amount);
    }

    /*///////////////////////////////////////////////////////////////
                            LENDING INTERFACE
    //////////////////////////////////////////////////////////////*/

    /// @notice Boolean indicating whether the contract is currently in a flash loan.
    bool public inFlashLoan;

    /// @notice Borrow funds from the flash lender contract.
    function borrow(uint256 amount, IFlashBorrower borrower) external {
        // Ensure that the contract is not currently executing a flash loan.
        // We do this to prevent a reentrancy attack where the borrower calls borrow again, which
        // enables them to set inFlashLoan to false and bypass the isFlashLoan checks in deposit/withdraw.
        require(!inFlashLoan, "Cannot withdraw while flash loan is active");
    
        // Set inFlashLoan to true.
        // We do this to prevent a potential attacker from taking advantage of the withdraw() function.
        // This is because the sharePrice function uses the token balance of the contract to calculate
        // the exchange rate. This value drops when tokens are being loaned out, which would cause the
        // share price to drop. This would allow an attacker to withdraw more tokens than they should be
        // able to, and then repay the loan with the extra tokens.
        inFlashLoan = true;

        // Store the current balance of the contract.
        uint256 balance = TOKEN.balanceOf(address(this));

        // Calculate the fee.
        uint256 fee = (amount * FEE) / 1e18;

        // Transfer the tokens from the contract to the borrower and call the executeOnFlashLoan function.
        TOKEN.safeTransfer(address(borrower), amount);
        borrower.executeOnFlashLoan(TOKEN, amount, amount + fee);

        // Ensure that the tokens have been returned to the contract.
        require(TOKEN.balanceOf(address(this)) >= balance + fee, "Borrower did not return funds");

        // Set inFlashLoan back to false.
        inFlashLoan = false;
    }
}
