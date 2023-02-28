    // SPDX-License-Identifier: MIT
    pragma solidity 0.8.19;

contract ERC20{
    uint256 public totalSupply;
    string public name;
    string public symbol;

    event Transfer(address indexed from, address indexed to,uint256 value);
    event Approval(address indexed owner, address indexed spender,uint256 value);

    mapping (address=>uint256) public balanceOf;
    mapping (address=> mapping (address=>uint256)) public allowance;

    constructor(string memory _name, string memory _symbol){
        name = _name;
        symbol = _symbol;

        _mint(msg.sender, 100e18); //will mint 100 tokens to the deployer
    }
    //results into less gas
    function decimals() external pure returns (uint8) {
        return 18;
    }

    function transfer(address recipient, uint256 amount) external returns(bool){
        return _transfer(msg.sender, recipient, amount);
    }
    function transferFrom(address sender, address recipient, uint256 amount) external returns(bool){
        uint256 currentAllowance = allowance[sender][msg.sender];

        require(
            currentAllowance >= amount,
            "Erc20: transfer amount exceeds allowance "
        );
        emit Approval(sender, recipient, amount);

        return _transfer(sender, recipient, amount);
    }

    function approve(address spender, uint256 amount) external returns (bool){
        require(spender != address(0),"ERC20 : Cannot send to 0 address");
        allowance[msg.sender][spender] = amount;

        emit Approval(msg.sender, spender, amount);

        return true;
    }

    //function to transfer funds
    function _transfer(address sender,address recipient , uint256 amount) private returns (bool){
        require(recipient != address(0),"ERC20 : transfer to 0 address");

        uint256 senderBalance = balanceOf[sender];

        require(senderBalance >= amount, "ERC20: transfer amount exceeds balance");

        balanceOf[sender] -= amount;
        balanceOf[recipient] += amount;

        emit Transfer(sender, recipient, amount);
        return true;

    }
    function _mint(address to, uint256 amount) internal {
        require(to!=address(0),"ERC20:cannot transfer to 0 address");

        totalSupply += amount;
        balanceOf[to] += amount;

        emit Transfer(address(0), to, amount);
    }
    function _burn(address from, uint256 amount) internal {
        require(from!=address(0),"ERC20:cannot burn from 0 address");

        totalSupply -= amount;
        balanceOf[from] -= amount;

        emit Transfer(from, address(0), amount);
    }
}

