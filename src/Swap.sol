// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

contract Swap{
    ISwapRouter constant router =
        ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    function swap(
        address tokenIn,
        address tokenOut,
        uint24 poolFee, // This poolFee can be queried from the Internet using GraphQL.
        /* Following code should work
            {
                pair(id: "0x1f9840a85d5af5bf1d1762f925bdaddc4201f984_0xc02aaa39b223fe8d0a0e5c4f27ead9083c756cc2") {
                    id
                    feeTier
                }
            }
            Check answer to the question "How to get the poolFee for a token pair in Uniswap?" in ChatGPT
         */
         uint amountIn
    ) external returns (uint amountOut){
        IERC20(tokenIn).approve(address(router), amountIn);

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: poolFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = router.exactInputSingle{gas:8000000}(params);
        require(amountOut!=0,"swap didn't occur");
    }
    
    /* function getBalance(address tokenIn) public view returns (uint){
        return IERC20(tokenIn).balanceOf(address(this));
    }
    function getBalanceWithoutDecimals(address tokenIn) public view returns (uint){
        return IERC20(tokenIn).balanceOf(address(this))/(10**IERC20(tokenIn).decimals());
    } */
}



interface ISwapRouter {
    struct ExactInputSingleParams {
        address tokenIn;
        address tokenOut;
        uint24 fee;
        address recipient;
        uint deadline;
        uint amountIn;
        uint amountOutMinimum;
        uint160 sqrtPriceLimitX96;
    }

    /// @notice Swaps amountIn of one token for as much as possible of another token
    /// @param params The parameters necessary for the swap, encoded as ExactInputSingleParams in calldata
    /// @return amountOut The amount of the received token
    function exactInputSingle(
        ExactInputSingleParams calldata params
    ) external payable returns (uint amountOut);
}

interface IERC20 {
    function totalSupply() external view returns (uint);

    function balanceOf(address account) external view returns (uint);

    function transfer(address recipient, uint amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint);

    function approve(address spender, uint amount) external returns (bool);

    function transferFrom(
        address sender,
        address recipient,
        uint amount
    ) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint value);
    event Approval(address indexed owner, address indexed spender, uint value);
    function decimals() external view returns (uint8);
}

interface IWETH is IERC20 {
    function deposit() external payable;

    function withdraw(uint amount) external;
}
