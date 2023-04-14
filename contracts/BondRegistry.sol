 // SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.9;

import './Bond.sol';

contract BondRegistry {
    address[] _bonds;
    mapping(address=>uint256) _bondIndex;

    uint256 constant _fee = 0.01 ether;

    event Issued(address indexed bond, address indexed issuer);


    function issue(string memory name_, 
        string memory symbol_,
        uint256 totalQuantity_,
        uint256 faceValue_,
        uint256 price_,
        uint256 numYears_
    ) external payable returns(address) {
        require(msg.value >= _fee, "Insufficient ETH sent to issue bond");
        
        if (msg.value > _fee){
            uint256 excess = msg.value - _fee;
            (bool success, ) = payable(msg.sender).call{value: excess}("");
            require(success, "Failed");
        }
        Bond bond = new Bond(name_,symbol_,totalQuantity_,faceValue_,price_,numYears_, address(this));
        address bondContract = address(bond);
        bond.transferOwnership(msg.sender);


        uint256 idx = _bonds.length;
        _bondIndex[bondContract] = idx;
        _bonds.push(bondContract);
        emit Issued(bondContract, msg.sender);
        return bondContract;
    }

    function fee() public pure returns(uint256) {
        return _fee;
    }

    function getBondIndex(address bondContract_) public view returns(uint256) {
        return _bondIndex[bondContract_];
    }

    function getBondList() public view returns(address[] memory){
        return _bonds;
    }
}