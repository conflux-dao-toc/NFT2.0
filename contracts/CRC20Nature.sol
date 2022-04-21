// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "@openzeppelin/contracts/token/ERC20/ERC20.sol";
import "@openzeppelin/contracts/access/Ownable.sol";

contract CRC20Nature is ERC20, Ownable {
    uint256 public totalBurnt;

    constructor(string memory name_, string memory symbol_) ERC20(name_, symbol_) {}

    function burn(uint256 amount) external virtual {
        _burn(_msgSender(), amount);
        totalBurnt += amount;
    }

    function burnFrom(address account, uint256 amount) external virtual {
        uint256 currentAllowance = allowance(account, _msgSender());
        require(currentAllowance >= amount, "CRC20: burn amount exceeds allowance");
        unchecked {
            _approve(account, _msgSender(), currentAllowance - amount);
        }
        _burn(account, amount);
        totalBurnt += amount;
    }

    function mint(address account, uint256 amount) external onlyOwner {
        _mint(account, amount);
    }
}
