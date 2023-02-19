// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;
interface IERC20 {
    function approve(address spender, uint amount) external returns (bool);
    function balanceOf(address account) external view returns (uint256);
}
