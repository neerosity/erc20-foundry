// SPDX-License-Identifier: SEE LICENSE IN LICENSE
pragma solidity ^0.8.18;

import {Test, console} from "forge-std/Test.sol";
import {DeployMyToken} from "../script/DeployMyToken.s.sol";
import {MyToken} from "../src/MyToken.sol";

interface MintableToken {
    function mint(address, uint256) external;
}

contract MyTokenTest is Test {
    uint256 public constant BOB_STARTING_AMOUNT = 10000 ether;

    MyToken public myToken;
    DeployMyToken public deployer;
    address public deployerAddress;
    address public bob;
    address public alice;

    function setUp() public {
        deployer = new DeployMyToken();
        myToken = deployer.run();

        bob = makeAddr("bob");
        alice = makeAddr("alice");

        deployerAddress = vm.addr(deployer.deployerKey());
        vm.prank(deployerAddress);
        myToken.transfer(bob, BOB_STARTING_AMOUNT);
    }

    function testInitialSupply() public {
        assertEq(myToken.totalSupply(), deployer.INITIAL_SUPPLY());
    }

    function testBobBalance() public {
        assertEq(BOB_STARTING_AMOUNT, myToken.balanceOf(bob));
    }

    function testAllowances() public {
        uint256 initialAllowance = 1000;

        vm.prank(bob);
        myToken.approve(alice, initialAllowance);

        uint256 transferAmount = 500;

        vm.prank(alice);
        myToken.transferFrom(bob, alice, transferAmount);

        assertEq(myToken.balanceOf(alice), transferAmount);

        assertEq(myToken.balanceOf(bob), BOB_STARTING_AMOUNT - transferAmount);
    }

    function testUsersCantMint() public {
        vm.expectRevert();
        MintableToken(address(myToken)).mint(address(this), 1);
    }

    function testTransfer() public {
        uint256 transferAmount = 1000;
        address receiver = address(0x1);
        vm.prank(deployerAddress);
        myToken.transfer(receiver, transferAmount);
        assertEq(myToken.balanceOf(receiver), transferAmount);
    }

    function testBalanceAfterTransfer() public {
        uint256 transferAmount = 1000;
        address receiver = address(0x1);
        uint256 initialBalance = myToken.balanceOf(deployerAddress);
        vm.prank(deployerAddress);
        myToken.transfer(receiver, transferAmount);
        assertEq(
            myToken.balanceOf(deployerAddress),
            initialBalance - transferAmount
        );
    }

    function testTransferFrom() public {
        uint256 allowanceAmount = 1000;
        address receiver = address(0x1);
        vm.prank(deployerAddress);
        myToken.approve(address(this), allowanceAmount);
        myToken.transferFrom(deployerAddress, receiver, allowanceAmount);
        assertEq(myToken.balanceOf(receiver), allowanceAmount);
    }
}
