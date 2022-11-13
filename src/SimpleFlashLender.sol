// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

// Interfaces
import "src/interfaces/IFlashBorrower.sol";
import "solmate/tokens/ERC20.sol";

// Libraries
import "solmate/utils/SafeTransferLib.sol";

/// @title Simple Flash Lender
/// @author Jet Jadeja <jet@pentagon.xyz>
/// @notice Simple flash lender contract that allows liquidity providers to deposit and withdraw funds.
contract SimpleFlashLender {
    using SafeTransferLib for ERC20;

    /*///////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice The address of the ERC20 contract.
    ERC20 public immutable TOKEN;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Set up the flash lender contract.
    constructor(ERC20 _TOKEN) {
        // Set our token to the correct ERC20 address.
        TOKEN = _TOKEN;
    } 

    /*///////////////////////////////////////////////////////////////
                            LENDING INTERFACE
    //////////////////////////////////////////////////////////////*/

    /// @notice Borrow funds from the flash lender contract.
    function borrow(uint256 amount, IFlashBorrower borrower) external {
        // Store the current balance of the contract.
        uint256 balance = TOKEN.balanceOf(address(this));

        // Transfer the tokens from the contract to the borrower.
        TOKEN.safeTransfer(address(borrower), amount);


        // Call the borrower's executeOnFlashLoan function.
        borrower.executeOnFlashLoan(TOKEN, amount);

        // Ensure that the tokens have been returned to the contract.
        require(TOKEN.balanceOf(address(this)) >= balance, "Borrower did not return funds");
    }
}