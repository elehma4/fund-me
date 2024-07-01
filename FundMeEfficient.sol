// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

error NotOwner();

contract FundMe {
    // attaching PriceConverter library to all uint256
    using PriceConverter for uint256;

    // constants = caps
    uint256 public constant MINIMUM_USD = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    function fund() public payable {
        require(msg.value.getConversionRate() >= MINIMUM_USD, "Didn't send enough ETH"); // 1e18 = 1 ETH = 1 * 10 ** 18
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    // immutable i_
    address public immutable i_owner;

    // constructors are immediately called when deploying contract
    constructor() {
        i_owner = msg.sender;
    }

    function withdraw() public onlyOwner {
        // require(msg.sender == owner, "Must be owner to withdraw");
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex = funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);

        // call (any f(x) in ethereum) | no cap on gas
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
        revert();
    }

    // modifier that can go directly in f(x) declaration
    // executes first then finish f(x)
    modifier onlyOwner() {
        // require(msg.sender == i_owner, "Sender is not the owner");
        if(msg.sender != i_owner) { revert NotOwner(); }
        _; // execute the rest of code
    }

    // What happens if someone sends this contract ETH without calling the FundMe function

    receive() external payable {
        fund();
    }
    fallback() external payable {
        fund();
    }
}