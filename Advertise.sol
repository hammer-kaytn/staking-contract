pragma solidity ^0.5.0;

import "caver-js/packages/caver-kct/src/contract/token/KIP7/KIP7.sol";
import "caver-js/packages/caver-kct/src/contract/token/KIP7/KIP7Metadata.sol";
import "caver-js/packages/caver-kct/src/contract/token/KIP7/KIP7Pausable.sol";

contract Advertise is KIP7,KIP7Metadata,KIP7Pausable {
    address public owner;

    uint256 private _totalSupply; // 토큰의 총량
    uint missionsId = 0; // 광고 식별의 초기 카운트 필히 storage 데이터로 남길필요가 있다.
    
    mapping (uint256 => Mission) public missions; //광고등록이 덮어씌어지지 않도록 uint id로 맵핑
    mapping (address => uint256) private _balances; //이용자 각각의 잔여 토큰을 확인하기 위한 맵핑
    
    //스테이킹을 했을때 보낸사람, 클레이의 양을 이벤트 호출
    event CoinDeposit(
        address indexed _from,
        uint256 _value); 
    
    //언스테이킹을 했을때 보낸사람, 토큰의 양을 이벤트 호출    
    event SwapRequest(
        address indexed _from,
        uint256 _value);    
    
    //광고를 만들었을때 미션식별과 광고주 주소, 목표 좋아요, 유효기간, 총보상량을 이벤트 호출
    event GeneratedMission(
        uint indexed _id,
        address indexed _advertiser,
        uint _likingGoal,
        uint _deadline,
        uint _totalReword
        );
    
    //좋아요를 눌렀을때 미션식별과 누른사람의 address 를 이벤트 호출
    event LikeMission(
        uint indexed _id,
        address indexed _user
        );
    
    
    modifier onlyOwner(){
    require(msg.sender == owner);
    _;
    }
    
    struct Mission{
        uint id; //미션의 식별자
        address[] likedUsers; //좋아요를 누른사람들의 지갑 주소
        address advertiser; //미션을 생성한 광고주의 주소
        uint likingGoal; //미션을 완료하기 위한 목표 좋아요
        uint likingNow; //현재 좋아요.
        uint deadline; //미션 기간 데드라인
        uint totalReword; //미션에 걸려있는 총 보상
        bool closed; //미션 달성시 
    }
    
    constructor(string memory name, string memory symbol, uint8 decimals) KIP7Metadata(name, symbol, decimals) public { 
    owner = msg.sender;
    }
    
    
    //  ----------------------------------------------~!@~!@~ Advertise ~~!@~!@~--------------------------------------------
    
    
    // @dev 좋아요를 눌렀을때 광고의 기간이 지나있는지 확인하는 함수 require
    function _chackTimeOut(uint _missionId) private view returns (bool) {
        if(missions[_missionId].deadline != now ){
            return true;
        } else {
            return false;
        }  
    }
    
    // @dev 좋아요를 눌렀을때 배열안에 이미 있다면 require로 걸러는 함수
    function _testLiked(uint _missionId) private view returns (bool) {
        for(uint i = 0; i < missions[_missionId].likedUsers.length; ++i) {
            if(missions[_missionId].likedUsers[i] == msg.sender) return false;
        }
        return true;
    }
    
   
    // @dev 광고를 등록하는 기능.
    // @params _likingGoal 목표 좋아요.
    // @params _totalReword 총 보상 지급량.
    function createAdvertise(uint _likingGoal, uint _totalReword) public {
        require(_totalReword <= _balances[msg.sender]);
        address[] memory likedUsers;
        missions[missionsId] = Mission(missionsId, likedUsers, msg.sender, _likingGoal, 0, getDeadline(now), _totalReword, false);
        
        Mission memory mission = missions[missionsId];
        emit GeneratedMission(missionsId, msg.sender, mission.likingGoal, getDeadline(now), mission.totalReword); 
        _burn(msg.sender,_totalReword);
        _totalSupply = _totalSupply.add(_totalReword);
        missionsId++;
    }

    // @dev 광고 "좋아요"를 누르는 기능
    // @parmas _missionId 광고주가 등록한 미션 식별 아이디.
    function likeMission(uint _missionId) public {
        require(_chackTimeOut(_missionId), "기간이 만료된 광고 입니다.");
        require(_testLiked(_missionId), "이미 등록되어 있는 어드레스입니다");
        missions[_missionId].likedUsers.push(msg.sender);
        missions[_missionId].likingNow += 1;
        emit LikeMission(_missionId,msg.sender);
    }
    
    // @dev 광고의 좋아요를 눌러준 사람들에게 보상을 주는 기능
    // @params _missionId 조회하고 싶은 광고 미션의 식별 아이디
    // @return bool 정상적으로 기능이 작동하면 true를 반환
    function rewordMission(uint _missionId) public onlyOwner returns (bool) {
        require(missions[_missionId].closed);
        uint ratioReword = missions[_missionId].totalReword / missions[_missionId].likedUsers.length;
        for(uint i = 0; i <= missions[_missionId].likedUsers.length; ++i){
            _mint(missions[_missionId].likedUsers[i],ratioReword);
        }
        return missions[_missionId].closed = true;
    }

    // @dev 등록한 광고의 정보를 볼수있는 콜 데이터
    // @params _missionId 조회하고 싶은 광고미션의 식별 아이디
    // @return 목표좋아요, 좋아요눌러준 사람들, 기간, 총 보상량, 현재 좋아요
    function getMission(uint _missionId) public view returns (uint,address[] memory,uint,uint,uint) {
        Mission memory mission = missions[_missionId];
        return (mission.likingGoal, mission.likedUsers, mission.deadline, mission.totalReword, mission.likingNow);
    }

    // @dev 기간을 설정기능.
    // @params _now 현재 시간.
    // @return 현재 시간 + 30일
    function getDeadline(uint _now) public pure returns (uint) {
       return _now + 30 days; //(3600 * 24 * 30)
    } 
    
    // ----------------------------------- ~!~!~!  STAKING ~!~!~!~ ----------------------------------------------
    
    // @ dev 스테이킹 기능, 스테이킹시 같은 갯수의 토큰을 반환
    function Staking() public payable {
        _balances[msg.sender] += _balances[msg.sender].add(msg.value);
        _totalSupply = _totalSupply.add(msg.value); 
        _mint(msg.sender,msg.value);
        emit CoinDeposit(msg.sender, msg.value);
    }
    // @ dev 언스테이킹 기능,
    // @ params amount 반환할 토큰의 양
    // @ return 성공시 true 반환
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