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

    /// @notice The percentage fee that is charged on flash loans.
    /// It is important to note that this is a "mantissa", which means that it is scaled by 1e18.
    /// So, a fee of 100% would actually be 1e18. A fee of 5% would be 0.05e18.
    uint256 public immutable FEE;

    /*///////////////////////////////////////////////////////////////
                               CONSTRUCTOR
    //////////////////////////////////////////////////////////////*/

    /// @notice Set up the flash lender contract.
    constructor(ERC20 _TOKEN, uint256 _FEE) {
        // Set our immutable values.
        TOKEN = _TOKEN;
        OWNER = msg.sender;
        FEE = _FEE;
    }

    /*///////////////////////////////////////////////////////////////
                        FEE COLLECTION INTERFACE
    //////////////////////////////////////////////////////////////*/

    /// @notice Stores total fees collected.
    uint256 public totalFees;

    /// @notice Retrieve the fees that have been collected.
    function collectFees() external {
        // Ensure that the caller is the owner.
        require(msg.sender == OWNER, "Only the owner can collect fees");

        // Transfer the tokens from the contract to the owner.
        TOKEN.safeTransfer(OWNER, totalFees);

        // Reset the total fees to 0.
        delete totalFees;
    }

    /*///////////////////////////////////////////////////////////////
                       LIQUIDITY PROVIDER INTERFACE
    //////////////////////////////////////////////////////////////*/

    /// @notice Stores liquidity provider balances.
    mapping(address => uint256) public balances;

    /// @notice Deposit funds into the flash lender contract.
    /// @param amount The amount of funds to deposit.
    function deposit(uint256 amount) external {
        // Ensure that the contract is not already in a flash loan.
        require(!inFlashLoan, "Already in a flash loan");

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
        // Ensure that the contract is not already in a flash loan.
        require(!inFlashLoan, "Already in a flash loan");

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

    /// @notice Boolean indicating whether the contract is currently in a flash loan.
    bool public inFlashLoan;

    /// @notice Borrow funds from the flash lender contract.
    function borrow(uint256 amount, IFlashBorrower borrower) external {
        // Ensure that the contract is not already in a flash loan. If it is, set inFlashLoan to true.
        // This is to prevent reentrancy.
        require(!inFlashLoan, "Already in a flash loan");
        inFlashLoan = true;

        // Store the current balance of the contract.
        uint256 balance = TOKEN.balanceOf(address(this));

        // Calculate the fee and update the totalFees.
        uint256 fee = (amount * FEE) / 1e18;
        totalFees += fee;

        // Transfer the tokens from the contract to the borrower and call the executeOnFlashLoan function.
        TOKEN.safeTransfer(address(borrower), amount);
        borrower.executeOnFlashLoan(TOKEN, amount, amount + fee);

        // Ensure that the tokens have been returned to the contract.
        require(TOKEN.balanceOf(address(this)) >= balance + fee, "Borrower did not return funds");

        // Reset inFlashLoan to false.
        inFlashLoan = false;
    }
}