// SPDX-License-Identifier: AGPL-3.0-only
pragma solidity 0.8.17;

library TokenAddresses {
    // Consolidation Tokens

    address public constant ARAI = 0xc9BC48c72154ef3e5425641a3c747242112a46AF;
    address public constant AAMPL = 0x1E6bb68Acec8fefBD87D192bE09bb274170a0548;
    address public constant AFRAX = 0xd4937682df3C8aEF4FE912A96A74121C0829E664;
    address public constant FRAX = 0x853d955aCEf822Db058eb8505911ED77F175b99e;
    address public constant AUST = 0xc2e2152647F4C26028482Efaf64b2Aa28779EFC4;
    address public constant SUSD = 0x57Ab1ec28D129707052df4dF418D58a2D46d5f51;
    address public constant ASUSD = 0x6C5024Cd4F8A59110119C56f8933403A539555EB;
    address public constant TUSD = 0x0000000000085d4780B73119b644AE5ecd22b376;
    address public constant ATUSD = 0x101cc05f4A51C0319f570d5E146a8C625198e636;
    address public constant AMANA = 0xa685a61171bb30d4072B338c80Cb7b2c865c873E;
    address public constant MANA = 0x0F5D2fB29fb7d3CFeE444a200298f468908cC942;
    address public constant ABUSD = 0xA361718326c15715591c299427c62086F69923D9;
    address public constant BUSD = 0x4Fabb145d64652a948d72533023f6E7A623C7C53;
    address public constant ZRX = 0xE41d2489571d322189246DaFA5ebDe1F4699F498;
    address public constant AZRX = 0xDf7FF54aAcAcbFf42dfe29DD6144A69b629f8C9e;
    address public constant AENS = 0x9a14e23A58edf4EFDcB360f68cd1b95ce2081a2F;
    address public constant ADPI = 0x6F634c6135D2EBD550000ac92F494F9CB8183dAe;

    // AMM Tokens

    address public constant aAMMDAI = 0x79bE75FFC64DD58e66787E4Eae470c8a1FD08ba4;
    address public constant aAMMUSDC = 0xd24946147829DEaA935bE2aD85A3291dbf109c80;
    address public constant aAMMUSDT = 0x17a79792Fe6fE5C95dFE95Fe3fCEE3CAf4fE4Cb7;
    address public constant aAMMWBTC = 0x13B2f6928D7204328b0E8E4BCd0379aA06EA21FA;
    address public constant aAMMWETH = 0xf9Fb4AD91812b704Ba883B11d2B576E890a6730A;

    // Token for AMM withdrawal

    address public constant DAI = 0x6B175474E89094C44Da98b954EedeAC495271d0F;
    address public constant USDC = 0xA0b86991c6218b36c1d19D4a2e9Eb0cE3606eB48;
    address public constant USDT = 0xdAC17F958D2ee523a2206206994597C13D831ec7;
    address public constant WBTC = 0x2260FAC5E5542a773Aa44fBCfeDf7C193bc2C599;
    address public constant WETH = 0xC02aaA39b223FE8D0A0e5C4F27eAD9083C756Cc2;

    function getaAMMTokens() public pure returns (address[5] memory) {
        return [aAMMDAI, aAMMUSDC, aAMMUSDT, aAMMWBTC, aAMMWETH];
    }

    function getaAMMEquivalentTokens() public pure returns (address[5] memory) {
        return [DAI, USDC, USDT, WBTC, WETH];
    }
}
