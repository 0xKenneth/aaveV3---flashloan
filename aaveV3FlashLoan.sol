//SPDX-License-Identifier:MIT
pragma solidity 0.8.10;
import "node_modules/@aave/core-v3/contracts/dependencies/openzeppelin/contracts/IERC20.sol";
import "node_modules/@aave/core-v3/contracts/flashloan/base/FlashLoanReceiverBase.sol";
import "node_modules/@aave/core-v3/contracts/interfaces/IPoolAddressesProvider.sol";
contract aaveV3FlashLoan is FlashLoanReceiverBase {

    address payable private owner;
    IERC20 private constant USDC = IERC20(0x94a9D9AC8a22534E3FaCa9F4e7F2E2cf85d5E4C8);
    IERC20 private constant DAI = IERC20(0xFF34B3d4Aee8ddCd6F9AFFFB6Fe49bD371b8a357);

    constructor(address provider) FlashLoanReceiverBase(IPoolAddressesProvider(provider))
    {
        owner = payable(msg.sender);
    }

    function startFlashLoan() public {
        require(msg.sender == owner, "not owner");
        address receiverAddress = address(this);
        address[] memory assets = new address[](2);
        assets[0] = address(USDC);
        assets[1] = address(DAI);
        uint256[] memory amounts = new uint256[](2);
        amounts[0] = 10000 * (10 ** 6);
        amounts[1] = 10000 * (10 ** 18);
        uint256[] memory interestRateModes = new uint256[](assets.length);
        address onBehalfOf = address(this);
        bytes memory params = "";
        uint16 referralCode = 0;
        POOL.flashLoan(
        receiverAddress, assets, amounts, interestRateModes, onBehalfOf, params, referralCode);
    }

    function executeOperation(
    address[] calldata assets,uint256[] calldata amounts,uint256[] calldata premiums,
    address initiator,bytes calldata params) external override returns (bool) {
        //logic
        for(uint i = 0; i < assets.length; i++) {
        uint256 totalAmount = amounts[i] + premiums[i];
        IERC20(assets[i]).approve(address(POOL), totalAmount);
        }
        return true;
    }

}