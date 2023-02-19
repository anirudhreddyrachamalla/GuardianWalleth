// SPDX-License-Identifier: MIT
pragma solidity ^0.8.17;

import "./interface/ISwapRouter.sol";
import "./interface/IUniswapV3Factory.sol";
import "./interface/IERC20.sol";

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
    function calculateMinimumFeeForPair(address tokenIn,address tokenOut) view external returns(uint24 minimumFee,address poolAddress){
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
        (uint24 minimumFee,address poolAddress) = this.calculateMinimumFeeForPair(tokenIn,tokenOut);

        if(minimumFee==0 || poolAddress==address(0)){
            revert("Direct LP for this pair does not exist");
        }
        ISwapRouter.ExactInputSingleParams memory params = ISwapRouter
            .ExactInputSingleParams({
                tokenIn: tokenIn,
                tokenOut: tokenOut,
                fee: minimumFee,
                recipient: msg.sender,
                deadline: block.timestamp,
                amountIn: amountIn,
                amountOutMinimum: 0,
                sqrtPriceLimitX96: 0
            });

        amountOut = router.exactInputSingle{gas:8000000}(params);
    }
}