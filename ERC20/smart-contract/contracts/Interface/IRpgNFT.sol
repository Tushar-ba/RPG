// SPDX-License-Identifier: MIT
pragma solidity 0.8.27;

interface RpgNFT {
    function getNFTdetails() public returns(address,Role,uint256,bool) {};
}