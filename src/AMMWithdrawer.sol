// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

import {AaveV2Ethereum} from "@aave-address-book/AaveV2Ethereum.sol";
import {AaveV2EthereumAMM} from "@aave-address-book/AaveV2EthereumAMM.sol";
import {IERC20} from "@openzeppelin/token/ERC20/IERC20.sol";
import {SafeERC20} from "@openzeppelin/token/ERC20/utils/SafeERC20.sol";

contract AMMWithdrawer {
    using SafeERC20 for IERC20;

    address public constant AMMDAI = 0x79bE75FFC64DD58e66787E4Eae470c8a1FD08ba4;
    address public constant AMMUSDC = 0xd24946147829DEaA935bE2aD85A3291dbf109c80;
    address public constant AMMUSDT = 0x17a79792Fe6fE5C95dFE95Fe3fCEE3CAf4fE4Cb7;
    address public constant AMMWBTC = 0x13B2f6928D7204328b0E8E4BCd0379aA06EA21FA;
    address public constant AMMWETH = 0xf9Fb4AD91812b704Ba883B11d2B576E890a6730A;

    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    address[5] private ammTokens = [AMMDAI, AMMUSDC, AMMUSDT, AMMWBTC, AMMWETH];
    address[5] private tokens = [DAI, USDC, USDT, WBTC, WETH];

    /// Withdraw AMM tokens from Aave V2 Collector Contract
    function redeem() external {
        uint256 length = ammTokens.length;

        for (uint256 i = 0; i < length;) {
            address token = ammTokens[i];
            uint256 amount = IERC20(token).balanceOf(AaveV2Ethereum.COLLECTOR);

            IERC20(token).safeTransferFrom(AaveV2Ethereum.COLLECTOR, address(this), amount);

            AaveV2EthereumAMM.POOL.withdraw(tokens[i], type(uint256).max, AaveV2Ethereum.COLLECTOR);
            unchecked {
                ++i;
            }
        }
    }
}
