pragma solidity ^0.5.0;

import "./KIP7.sol";

// KIP7 익스텐션들 (필수적인건 아니고 필요에 따라서 기능을.)
// import "./KIP7Burnable.sol";
// import "./KIP7Mintable.sol";
// import "./KIP7Metadata.sol";
// import "./KIP7Pausable.sol";


contract Klaymore is KIP7 {
    address private _owner;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    address [] internal stakeholders; 
    
    constructor(string memory name,string memory symbol,uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    // 테스트용 클레이예치 및 토큰 반환하는기능.  비율은 예치한 클레이와 동일하게함.
    function testDeposit(uint256 amount) public payable {
        _addStakeholder(msg.sender);
        _mint(msg.sender, amount);
    }
    //토큰의 총 발행량 입니다.(기존에 추가를 하지않아도 KIP7에서 상속받아 사용가능)
    //단지 팀프로젝트 컨트렉트내용을 보다 쉽게 전달히기 위해 추가하였음.
    function totalStakes() public view returns(uint256) {
    uint256 _totalStakes = 0;
    for (uint256 s = 0; s < stakeholders.length; s += 1){
        _totalStakes = _totalStakes.add(stakes[stakeholders[s]]);
    }
    return _totalStakes;
    }
    //스테이킹한 사람을 조회하는 기능
    function isStakeholder(address _address)public view returns(bool, uint256) {
    for (uint256 s = 0; s < stakeholders.length; s += 1){
        if (_address == stakeholders[s]) return (true, s);
    }
    return (false, 0);
    }
    // 개인과 개인끼리 토큰 거래를 할수있는 함수 단순하게 
    //호출자(msg.sender)가 to(recipient) 에게 토큰을 얼마만큼(amount)를 보내는 함수 
    function transfer(address recipient, uint256 amount) public returns (bool) {
        _transfer(msg.sender, recipient, amount);
        return true;
    }
    // function unstaking(){
        
    // }
    
    function _addStakeholder(address _stakeholder) internal {
    (bool _isStakeholder, ) = isStakeholder(_stakeholder);
    if(!_isStakeholder) stakeholders.push(_stakeholder);
    }
}