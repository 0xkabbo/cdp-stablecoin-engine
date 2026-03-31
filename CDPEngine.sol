// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

import "@openzeppelin/contracts/utils/ReentrancyGuard.sol";
import "@chainlink/contracts/src/v0.8/shared/interfaces/AggregatorV3Interface.sol";
import "./Stablecoin.sol";

contract CDPEngine is ReentrancyGuard {
    Stablecoin public immutable i_stablecoin;
    AggregatorV3Interface public immutable i_priceFeed;

    uint256 public constant LIQUIDATION_THRESHOLD = 50; // 200% Collateralized
    uint256 public constant PRECISION = 1e18;

    mapping(address => uint256) public collateralDeposited;
    mapping(address => uint256) public usdMinted;

    constructor(address stablecoinAddress, address priceFeed) {
        i_stablecoin = Stablecoin(stablecoinAddress);
        i_priceFeed = AggregatorV3Interface(priceFeed);
    }

    function depositAndMint(uint256 amountToMint) external payable nonReentrant {
        collateralDeposited[msg.sender] += msg.value;
        usdMinted[msg.sender] += amountToMint;
        
        _checkHealthFactor(msg.sender);
        i_stablecoin.mint(msg.sender, amountToMint);
    }

    function redeemAndBurn(uint256 amountToBurn, uint256 collateralToRedeem) external nonReentrant {
        usdMinted[msg.sender] -= amountToBurn;
        collateralDeposited[msg.sender] -= collateralToRedeem;
        
        _checkHealthFactor(msg.sender);
        i_stablecoin.burn(msg.sender, amountToBurn);
        payable(msg.sender).transfer(collateralToRedeem);
    }

    function _checkHealthFactor(address user) internal view {
        uint256 userValueInUsd = (collateralDeposited[user] * _getLatestPrice()) / PRECISION;
        uint256 adjustedThreshold = (userValueInUsd * LIQUIDATION_THRESHOLD) / 100;
        require(adjustedThreshold >= usdMinted[user], "Healt Factor too low!");
    }

    function _getLatestPrice() internal view returns (uint256) {
        (, int256 price, , , ) = i_priceFeed.latestRoundData();
        return uint256(price) * 1e10;
    }
}
