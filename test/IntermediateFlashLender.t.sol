// SPDX-License-Identifier: Unlicense
pragma solidity 0.8.17;

import "src/IntermediateFlashLender.sol";
import "src/interfaces/IFlashBorrower.sol";

import "solmate/test/utils/mocks/MockERC20.sol";
import "solmate/tokens/ERC20.sol";

import {DSTestPlus} from "solmate/test/utils/DSTestPlus.sol";


contract IntermediateFlashLenderTest is DSTestPlus {
    IntermediateFlashLender lender;
    MockERC20 token;

    function setUp() public {
        token = new MockERC20("Test Token", "TEST", 18);
        lender = new IntermediateFlashLender(ERC20(address(token)), 0.05e18); // 5% fee

        token.approve(address(lender), 1000 ether);
        lender.deposit(1000 ether);
    }

    function testLoan() public {
        GoodBorrower borrower = new GoodBorrower();
        token.mint(address(borrower), 50 ether);
        lender.borrow(1000, IFlashBorrower(address(borrower)));
    }

    function testLoanSuccess() public {
        GoodBorrower borrower = new GoodBorrower();
        token.mint(address(borrower), 50 ether);
        lender.borrow(1000, IFlashBorrower(address(borrower)));
    }

    function testFailRevertsIfFeeNotReturned() public {
        CheapBorrower borrower = new CheapBorrower();
        token.mint(address(borrower), 50 ether);
        lender.borrow(1000, IFlashBorrower(address(borrower)));
    }

    function testFailRevertsIfNotReturned() public {
        BadBorrower borrower = new BadBorrower();
        lender.borrow(1000, IFlashBorrower(address(borrower)));
    }

    function testFailRevertsIfSemiReturned() public {
        MistakenBorrower borrower = new MistakenBorrower();
        token.mint(address(borrower), 50 ether);
        lender.borrow(1000, IFlashBorrower(address(borrower)));
    }

    function testWithdrawFees() public {
        testLoanSuccess();
        lender.collectFees();
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
