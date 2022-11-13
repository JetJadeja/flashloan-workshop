// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

// Interfaces
import "src/interfaces/IFlashBorrower.sol";
import "solmate/tokens/ERC20.sol";

// Libraries
import "solmate/utils/SafeTransferLib.sol";

/// @title Intermediate Flash Lender
/// @author Jet Jadeja <jet@pentagon.xyz>
/// @notice Flash lender contract that allows liquidity providers to deposit and withdraw funds.
contract IntermediateFlashLender {
    using SafeTransferLib for ERC20;

    /*///////////////////////////////////////////////////////////////
                                CONSTANTS
    //////////////////////////////////////////////////////////////*/

    /// @notice The address of the ERC20 contract.
    ERC20 public immutable TOKEN;

    /// @notice The owner of the contract.
    address public immutable OWNER;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Set up the flash lender contract.
    constructor(ERC20 _TOKEN) {
        // Set our immutable values.
        TOKEN = _TOKEN;
        OWNER = msg.sender;
    }

    /*///////////////////////////////////////////////////////////////
                       LIQUIDITY PROVIDER INTERFACE
    //////////////////////////////////////////////////////////////*/

    /// @notice Stores liquidity provider balances.
    mapping(address => uint256) public balances;

    /// @notice Deposit funds into the flash lender contract.
    /// @param amount The amount of funds to deposit.
    function deposit(uint256 amount) external {
        // Transfer the tokens from the sender to the contract.
        // Must have tokens approved.
        TOKEN.safeTransferFrom(msg.sender, address(this), amount);

        // Update liquidity provider balances.
        balances[msg.sender] += amount;
    }

    /// @notice Withdraw funds from the flash lender contract.
    /// @param amount The amount of funds to withdraw.
    /// Will fail if the liquidity provider does not have enough funds.
    function withdraw(uint256 amount) external {
        // Ensure that the liquidity provider has enough funds.
        // This technically isn't necessary. Solidity SafeMath would automatically revert.
        require(balances[msg.sender] >= amount, "Not enough funds");

        // Update liquidity provider balances.
        balances[msg.sender] -= amount;

        // Transfer the tokens from the contract to the liquidity provider.
        TOKEN.safeTransfer(msg.sender, amount);
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