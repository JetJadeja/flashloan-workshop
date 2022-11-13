// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

// Interfaces
import "src/interfaces/IFlashBorrower.sol";
import "solmate/tokens/ERC20.sol";

/// @title Intermediate Flash Lender
/// @author Jet Jadeja <jet@pentagon.xyz>
/// @notice Flash lender contract that allows liquidity providers to deposit and withdraw funds.
contract IntermediateFlashLender {
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
                        LIQUIDITY PROVIDER INTERFACE
    //////////////////////////////////////////////////////////////*/

    /// @notice Deposit funds into the flash loan
    function deposit(uint256 amount) external {
        // Transfer the tokens from the user to the contract.
        TOKEN.transferFrom(msg.sender, address(this), amount);
    }
}