// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

contract VendingMachine {
    address public owner;
    mapping (address => uint) public balances;
    uint public itemPrice;
    uint public itemStock;

    event Purchase(address indexed buyer, uint amount);
    event Restock(uint amount);
    event Withdrawal(uint amount);

    modifier onlyOwner() {
        require(msg.sender == owner, "Only the owner can perform this action.");
        _;
    }

    constructor(uint _itemPrice, uint _initialStock) {
        owner = msg.sender;
        itemPrice = _itemPrice;
        itemStock = _initialStock;
    }

    function purchase(uint amount) public payable {
        require(amount > 0, "You need to purchase at least one item.");
        require(msg.value == amount * itemPrice, "Incorrect Ether value sent.");
        require(itemStock >= amount, "Not enough items in stock.");

        balances[msg.sender] += amount;
        itemStock -= amount;

        emit Purchase(msg.sender, amount);
    }

    function restock(uint amount) public onlyOwner {
        itemStock += amount;
        emit Restock(amount);
    }

    function withdraw() public onlyOwner {
        uint balance = address(this).balance;
        payable(owner).transfer(balance);

        emit Withdrawal(balance);
    }

    function getBalance() public view returns (uint) {
        return address(this).balance;
    }

    function getStock() public view returns (uint) {
        return itemStock;
    }
}
