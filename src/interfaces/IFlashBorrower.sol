pragma solidity 0.8.17;

/// @title Flash Borrower Interface
/// @notice Interface for flash loan borrowers.
interface IFlashBorrower {
    /// @notice The function that is called by the flash lender contract when funds are borrowed.
    /// @param amount The amount of funds that are borrowed.
    function executeOnFlashLoan(uint256 amount) external;
}