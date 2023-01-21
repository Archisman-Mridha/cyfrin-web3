// SPDX-License-Identifier: Unlicense
pragma solidity ^0.8.17;

// creating a token using the ERC20 standards
contract ERC20TokenContract {

    string public name;
    string public symbol;
    uint256 public totalSupply; // in decimal units

    /*
        decimals represents how many pieces a token can be broken down into. So if decimals= 18 for a token, then 1 token
        can be broken down into 10^18 pieces.
    */
    uint8 public decimals;

    mapping(address => uint256) public balanceOf;
    // example - allowing account A to transfer 20 tokens from account B to C (or from B to itself)
    mapping(address => mapping(address => uint256)) public allowance;

    // if we use the `indexed` keyword with some event parameter, then we can search events by that parameter
    event Transfer(address indexed sender, address indexed receiver, uint256 value);
    event Approval(address indexed _owner, address indexed _spender, uint256 value);
    event Burn(address indexed sender, uint256 value);

    // initializes contract and gives initial supply of tokens to the contract creator
    constructor(uint256 _initialSupply, string memory _name, string memory _symbol) {

        totalSupply= _initialSupply * 10**uint256(decimals);
        balanceOf[msg.sender]= totalSupply;

        name= _name;
        symbol= _symbol;
    }

    function _transfer(address _sender, address _receiver, uint256 _value) internal {

        require(_receiver != address(0x0));
        require(balanceOf[_sender] >= _value);

        balanceOf[_sender] -= _value;
        balanceOf[_receiver] += _value;

        emit Transfer(_sender, _receiver, _value);
    }

    // sender initiating the transfer
    function transfer(address _to, uint256 _value) public {
        _transfer(msg.sender, _to, _value);
    }

    // 3rd party initiating the transfer
    function transferFrom(address _sender, address _receiver, uint256 _value) public {

        require(_value <= allowance[_sender][msg.sender]);
        allowance[_sender][msg.sender] -= _value;

        _transfer(_sender, _receiver, _value);
    }

    function approve(address _spender, uint256 _value) public {

        allowance[_spender][msg.sender]= _value;
        emit Approval(msg.sender, _spender, _value);
    }

    // `burning tokens` means removing those tokens forever from the system. here the owner of the tokens burns the tokens
    // himself/herself
    function burn(uint256 _value) public {

        require(balanceOf[msg.sender] >= _value);

        balanceOf[msg.sender] -= _value;
        totalSupply -= _value;

        emit Burn(msg.sender, _value);
    }

    // 3rd party burning tokens of someone else
    function burnFrom(address _owner, uint256 _value) public {

        require(balanceOf[_owner] >= _value);
        require(_value <= allowance[_owner][msg.sender]);

        balanceOf[_owner] -= _value;
        allowance[_owner][msg.sender] -= _value;
        totalSupply -= _value;

        emit Burn(msg.sender, _value);
    }

}
