// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;
interface ISwap{
    
    function calculateMinimumFeeForPair(address tokenIn,address tokenOut) view external returns(uint24 minimumFee,address poolAddress);
    function swap(
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) external returns (uint amountOut);
}