// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import "src/AdvancedFlashLender.sol";
import "src/interfaces/IFlashBorrower.sol";

import "solmate/test/utils/mocks/MockERC20.sol";
import "solmate/tokens/ERC20.sol";

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";
import "forge-std/console.sol";


contract AdvancedFlashLenderTest is DSTestPlus {
    AdvancedFlashLender lender;
    MockERC20 token;

    function setUp() public {
        token = new MockERC20("Test Token", "TEST", 18);
        lender = new AdvancedFlashLender(ERC20(address(token)), 0.05e18); // 5% fee

        token.mint(address(this), 1000 ether);
    }

    function testDeposit() public {
        token.approve(address(lender), 1000 ether);
        lender.deposit(1000 ether);

        require(lender.balanceOf(address(this)) == 1000 ether);
        require(lender.balanceOfUnderlying(address(this)) == 1000 ether);
    }

    function testWithdraw() public {
        testDeposit();
        lender.withdraw(1000 ether);

        require(lender.balanceOf(address(this)) == 0);
        require(lender.balanceOfUnderlying(address(this)) == 0 ether);
    }

    function testBalanceIncrease() public {
        // Execute a flash loan and pay the 5% fee.
        testDeposit();

        GoodBorrower borrower = new GoodBorrower();
        token.mint(address(borrower), 50 ether);
        lender.borrow(1000 ether, IFlashBorrower(address(borrower)));


        // The balance of the lender should have increased by 5%.
        console.log(lender.balanceOfUnderlying(address(this)));
        console.log(lender.sharePrice());
        console.log(token.balanceOf(address(lender)), lender.totalSupply());
        console.log((token.balanceOf(address(lender)) * 1e18) / lender.totalSupply());

        require(lender.balanceOfUnderlying(address(this)) == 1050 ether, "Value");
    }

    function testLoan() public {
        testDeposit();

        GoodBorrower borrower = new GoodBorrower();
        token.mint(address(borrower), 50 ether);
        lender.borrow(1000 ether, IFlashBorrower(address(borrower)));
    }

    function testLoanSuccess() public {
        testDeposit();

        GoodBorrower borrower = new GoodBorrower();
        token.mint(address(borrower), 50 ether);
        lender.borrow(1000 ether, IFlashBorrower(address(borrower)));
    }

    function testFailRevertsIfFeeNotReturned() public {
        testDeposit();
        
        CheapBorrower borrower = new CheapBorrower();
        token.mint(address(borrower), 50 ether);
        lender.borrow(1000 ether, IFlashBorrower(address(borrower)));
    }

    function testFailRevertsIfNotReturned() public {
        testDeposit();
        
        BadBorrower borrower = new BadBorrower();
        lender.borrow(1000 ether, IFlashBorrower(address(borrower)));
    }

    function testFailRevertsIfSemiReturned() public {
        testDeposit();
        
        MistakenBorrower borrower = new MistakenBorrower();
        token.mint(address(borrower), 50 ether);
        lender.borrow(1000 ether, IFlashBorrower(address(borrower)));
    }
}

contract GoodBorrower {
    function executeOnFlashLoan(ERC20 token, uint256, uint256 total) external {
        token.transfer(msg.sender, total);
    }
}

contract CheapBorrower {
    function executeOnFlashLoan(ERC20 token, uint256 amount, uint256) external {
        token.transfer(msg.sender, amount);
    }
}

contract BadBorrower {
    function executeOnFlashLoan(ERC20 token, uint256, uint256) external {
        token.transfer(msg.sender, 0);
    }
}

contract MistakenBorrower {
    function executeOnFlashLoan(ERC20 token, uint256 amount, uint256) external {
        token.transfer(msg.sender, amount/2);
    }
}
