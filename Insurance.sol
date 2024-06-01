// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract Insurance {
    address[] public insuredAddresses;
    address public immutable owner;
    mapping(address => uint256) public addressToAmount;
    uint256 public insurancePrice = 1 gwei; 
    uint256 public totalAmountToBePaidOut = 0;

    event Insured(address indexed insuredAddress);
    
    modifier onlyOwner() {
        require(msg.sender == owner, "Only contract owner can perform this action");
        _;
    }

    constructor() {
        owner = msg.sender;
    }

    function setInsurancePrice(uint256 newInsurancePrice) public onlyOwner {
        insurancePrice = newInsurancePrice;
    }

    function getInsured() public payable {
        require(msg.value >= insurancePrice, "Insufficient ether sent for insurance price");
        insuredAddresses.push(msg.sender);
        emit Insured(msg.sender);
    }

    function giveInsuranceMoney(address deservingAddress, uint256 deservingAmount) public onlyOwner {
        addressToAmount[deservingAddress] += deservingAmount;
        totalAmountToBePaidOut += deservingAmount;
    }

    function payoutAllInsuranceMoney() public onlyOwner {
        require(address(this).balance >= totalAmountToBePaidOut, "Insufficient contract balance");

        for (uint256 i = 0; i < insuredAddresses.length; i++) {
            address payable recipient = payable(insuredAddresses[i]);
            uint256 amount = addressToAmount[insuredAddresses[i]] * 1 gwei;
            recipient.transfer(amount);
            delete addressToAmount[insuredAddresses[i]];
        }
        totalAmountToBePaidOut = 0;
    }

    function withdrawInsuranceMoney() public {
        require(addressToAmount[msg.sender] > 0, "You are not entitled to withdraw insurance money");

        address payable recipient = payable(msg.sender);
        uint256 amount = addressToAmount[msg.sender] * 1 gwei;

        require(address(this).balance >= amount, "Insufficient contract balance");

        recipient.transfer(amount);
        delete addressToAmount[msg.sender];
    }

    function checkIsInsured() public view returns(bool){
        for (uint256 i = 0; i < insuredAddresses.length; i++) {
            if(msg.sender == insuredAddresses[i]){
                return true;
            }
        }
        return false;
    }

    function getTotalInsurancePoolAmount() public view returns(uint256) {
        return address(this).balance;
    }

    function hardDeleteData() public onlyOwner {
    delete insuredAddresses;

    for (uint256 i = 0; i < insuredAddresses.length; i++) {
        delete addressToAmount[insuredAddresses[i]];
    }
}

    function withdrawContract() public onlyOwner{
        (bool callSuccess,) = payable(msg.sender).call{value: address(this).balance}("");
        require(callSuccess);
    }

    function fundContract() public payable{require(msg.value > 0);}
    receive() external payable {fundContract();}
    fallback() external payable {fundContract();}
}