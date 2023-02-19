// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;



contract Swap{
    ISwapRouter constant router = ISwapRouter(0xE592427A0AEce92De3Edee1F18E0157C05861564);
    IUniswapV3Factory constant factory = IUniswapV3Factory(0x1F98431c8aD98523631AE4a59f267346ea31F984);
    enum FeeLevel {
        LOWEST, // 100
        LOW, // 500
        MEDIUM,//3000
        HIGH//10000
    }   

    function getFeeLevelByValue(FeeLevel _fee) internal pure returns (uint24 feeInBasisPoints) {
        // Error handling for input
        require(uint8(_fee) <= 2);
        // Loop through possible options
        if (FeeLevel.LOWEST == _fee) {
            feeInBasisPoints = uint24(100);
            return feeInBasisPoints;
        }
        if (FeeLevel.LOW == _fee) {
            feeInBasisPoints = uint24(500);
            return feeInBasisPoints;
        }
        if (FeeLevel.MEDIUM == _fee){
            feeInBasisPoints = uint24(3000);
            return feeInBasisPoints;
        } 
        if (FeeLevel.HIGH == _fee){
            feeInBasisPoints = uint24(10000);
            return feeInBasisPoints;
        } 
    }

    // TODO: need to query this with GraphQL/Javascript
    function calculateMinimumFeeForPair(address tokenIn,address tokenOut) view private returns(uint24 minimumFee,address poolAddress){
        for(uint i;i<4;i++){
            poolAddress = factory.getPool(tokenIn, tokenOut,getFeeLevelByValue(FeeLevel(i)));
            if(poolAddress!=address(0)){
                minimumFee=getFeeLevelByValue(FeeLevel(i));
                break;
            }
        }
    }
    function swap(
        address tokenIn,
        address tokenOut,
        uint amountIn
    ) external returns (uint amountOut){
        IERC20(tokenIn).approve(address(router), amountIn);
        (uint24 minimumFee,address poolAddress) = calculateMinimumFeeForPair(tokenIn,tokenOut);

        if(minimumFee==0 || poolAddress==address(0)){
            revert("Direct LP for this pair does not exists");
        }
        

        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: minimumFee,
                // recipient: msg.sender, // for actual contract 
                recipient: address(this), // while testing this contract for swapping
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = router.exactInputSingle{gas:8000000}(params);
        require(amountOut!=0,"swap didn't occur");
    }
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
    function approve(address spender, uint amount) external returns (bool);
}


pragma solidity >=0.5.0;

/// @title The interface for the Uniswap V3 Factory
/// @notice The Uniswap V3 Factory facilitates creation of Uniswap V3 pools and control over the protocol fees
interface IUniswapV3Factory {
    

    /// @notice Returns the pool address for a given pair of tokens and a fee, or address 0 if it does not exist
    /// @dev tokenA and tokenB may be passed in either token0/token1 or token1/token0 order
    /// @param tokenA The contract address of either token0 or token1
    /// @param tokenB The contract address of the other token
    /// @param fee The fee collected upon every swap in the pool, denominated in hundredths of a bip
    /// @return pool The pool address
    function getPool(
        address tokenA,
        address tokenB,
        uint24 fee
    ) external view returns (address pool);
    
}

