pragma solidity ^0.5.0;

import "caver-js/packages/caver-kct/src/contract/token/KIP7/KIP7.sol";
import "caver-js/packages/caver-kct/src/contract/token/KIP7/KIP7Metadata.sol";
import "caver-js/packages/caver-kct/src/contract/token/KIP7/KIP7Pausable.sol";

contract Klaymore is KIP7,KIP7Metadata,KIP7Pausable {
    address public owner;

    uint256 private _totalSupply;
    
    mapping (address => uint256) private _balances;
    event CoinDeposit(address indexed _from, uint256 _value); 
    event SwapRequest(address indexed _from, uint256 _value);    

    
    modifier onlyOwner(){
    require(msg.sender == owner);
    _;
    }
    
    constructor(string memory name, string memory symbol, uint8 decimals) KIP7Metadata(name, symbol, decimals) public { 
    owner = msg.sender;
    }
    
    //스테이킹 기능, 스테이킹시 같은 갯수의 토큰을 반환
    function Staking() public payable {
        _balances[msg.sender] += _balances[msg.sender].add(msg.value);
        _totalSupply = _totalSupply.add(msg.value); 
        _mint(msg.sender,msg.value);
        emit CoinDeposit(msg.sender, msg.value);
    }
    //언스테이킹 기능,
    function Unstaking(uint256 amount) public returns (bool) {
        require(amount <= _balances[msg.sender]);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _burn(msg.sender,amount);
        msg.sender.transfer(amount);
        emit SwapRequest(msg.sender,amount);
        return true;
    }
    //스테이커에게 전송하는 기능. 이 기능은 오로지 컨트렉트의 주인만이 할수있다.
    function TransferToStaker(address payable _to, uint256 amount) onlyOwner public {
        _to.transfer(amount);
    }
}