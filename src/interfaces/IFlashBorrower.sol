pragma solidity 0.8.17;

// Interfaces
import "solmate/tokens/ERC20.sol";

/// @title Flash Borrower Interface
/// @notice Interface for flash loan borrowers.
interface IFlashBorrower {
    /// @notice The function that is called by the flash lender contract when funds are borrowed.
    /// @param token The address of the ERC20 token that is being borrowed.
    /// @param amount The amount of funds that are borrowed.
    /// @param total The amount that must be returned (including fees).
    function executeOnFlashLoan(ERC20 token, uint256 amount, uint256 total) external;
}