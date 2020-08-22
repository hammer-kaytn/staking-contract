pragma solidity ^0.5.0;

import "./KIP7.sol";

contract Klaymore is KIP7 {
    address private _owner;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    
    
    constructor(string memory name,string memory symbol,uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    // 테스트용 클레이예치 및 토큰 반환하는기능.  비율은 예치한 클레이와 동일하게함.
    function deposit(uint256 amount) public payable {
        _mint(msg.sender, amount);
    }
    //토큰의 총 발행량 입니다.(기존에 추가를 하지않아도 KIP7에서 상속받아 사용가능)
    //단지 팀프로젝트 컨트렉트내용을 보다 쉽게 전달히기 위해 추가하였음.
    function totalSupply() public view returns (uint256) {
        return _totalSupply;
    }
    // 개인과 개인끼리 토큰 거래를 할수있는 함수 단순하게 
    //호출자(msg.sender)가 to(recipient) 에게 토큰을 얼마만큼(amount)를 보내는 함수 
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    
    
}