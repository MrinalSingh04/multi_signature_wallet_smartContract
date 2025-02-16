// SPDX-License-Identifier: MIT
pragma solidity ^0.8.19;

contract MultiSigWallet {
    address[] public owners;
    uint public requiredApprovals;

    struct Transaction {
        address to;
        uint value;
        bool executed;
        uint approvalCount;
    }

    mapping(uint => mapping(address => bool)) public approvals;
    Transaction[] public transactions;

    modifier onlyOwner() {
        require(isOwner(msg.sender), "Not an owner");
        _;
    }

    constructor(address[] memory _owners, uint _requiredApprovals) {
        require(_owners.length > 1, "At least two owners required");
        require(
            _requiredApprovals > 0 && _requiredApprovals <= _owners.length,
            "Invalid approvals"
        );
        owners = _owners;
        requiredApprovals = _requiredApprovals;
    }

    function submitTransaction(address _to, uint _value) public onlyOwner {
        transactions.push(
            Transaction({
                to: _to,
                value: _value,
                executed: false,
                approvalCount: 0
            })
        );
    }

    function approveTransaction(uint _txIndex) public onlyOwner {
        require(_txIndex < transactions.length, "Invalid transaction");
        require(!approvals[_txIndex][msg.sender], "Already approved");
        approvals[_txIndex][msg.sender] = true;
        transactions[_txIndex].approvalCount++;
    }

    function executeTransaction(uint _txIndex) public onlyOwner {
        require(
            transactions[_txIndex].approvalCount >= requiredApprovals,
            "Not enough approvals"
        );
        require(!transactions[_txIndex].executed, "Already executed");
        transactions[_txIndex].executed = true;
        payable(transactions[_txIndex].to).transfer(
            transactions[_txIndex].value
        );
    }

    function isOwner(address _address) private view returns (bool) {
        for (uint i = 0; i < owners.length; i++) {
            if (owners[i] == _address) return true;
        }
        return false;
    }

    receive() external payable {}
}
