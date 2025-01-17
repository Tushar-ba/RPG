// SPDX-License-Identifier: MIT

pragma solidity ^0.8.22;

interface IRPGtoken {
    function FEE_AMOUNT () public returns(uint){}
    function getDetails() public view returns(uint ,bool){};
}