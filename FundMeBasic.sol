// SPDX-License-Identifier: MIT
pragma solidity ^0.8.18;

import {PriceConverter} from "./PriceConverter.sol";

// solhint-disable-next-line interface-starts-with-i
// interface AggregatorV3Interface {
//   function decimals() external view returns (uint8);

//   function description() external view returns (string memory);

//   function version() external view returns (uint256);

//   function getRoundData(
//     uint80 _roundId
//   ) external view returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);

//   function latestRoundData()
//     external
//     view
//     returns (uint80 roundId, int256 answer, uint256 startedAt, uint256 updatedAt, uint80 answeredInRound);
// }

contract FundMe {
    // attaching PriceConverter library to all uint256
    using PriceConverter for uint256;

    uint256 public minimumUsd = 5e18;

    address[] public funders;
    mapping(address funder => uint256 amountFunded) public addressToAmountFunded;

    function fund() public payable {
        require(msg.value.getConversionRate() >= minimumUsd, "Didn't send enough ETH"); // 1e18 = 1 ETH = 1 * 10 ** 18
        funders.push(msg.sender);
        addressToAmountFunded[msg.sender] += msg.value;
    }

    address public owner;

    // constructors are immediately called when deploying contract
    constructor() {
        owner = msg.sender;
    }

    function withdraw() public onlyOwner {
        // require(msg.sender == owner, "Must be owner to withdraw");
        for(uint256 funderIndex = 0; funderIndex < funders.length; funderIndex = funderIndex++){
            address funder = funders[funderIndex];
            addressToAmountFunded[funder] = 0;
        }
        funders = new address[](0);
        // withdraw the funds

        // transfer (capped at 2300 gas -> errors out)
        // this keyword is contract
        // send tokens from different contracts
        // payable(msg.sender).transfer(address(this).balance);

        // send (capped at 2300 gas -> returns boolean)
        // bool sendSuccess = payable(msg.sender).send(address(this).balance);
        // require(sendSuccess, "Send failed");

        // call (any f(x) in ethereum) | no cap on gas
        (bool callSuccess, ) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess, "Call failed");
    }

    // modifier that can go directly in f(x) declaration
    // executes first then finish f(x)
    modifier onlyOwner() {
        require(msg.sender == owner, "Sender is not the owner");
        _; // execute the rest of code
    }

}