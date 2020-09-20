pragma solidity ^0.5.0;

contract Advertise {
    struct Mission{
        address advertiser; //미션을 생성한 광고주의 주소
        uint likingGoal; //미션을 완료하기 위한 목표 좋아요
        uint likingNow; //현재 좋아요.
        uint deadline; //미션 기간 데드라인
        uint totalReword; //미션에 걸려있는 총 보상
    }
    mapping (address => Mission) public missions; //광고등록이 덮어씌어지지 않도록 맵핑
    
    event GeneratedMission(address _advertiser, uint _likingGoal, uint _deadline, uint _totalReword);
    
    // @dev 광고를 등록하는 기능.
    // @params _likingGoal 목표 좋아요.
    // @params _totalReword 총 보상 지급량.
    function createAdvertise(uint _likingGoal, uint _totalReword) public {
      missions[msg.sender] = Mission(msg.sender, _likingGoal,0,getDeadline(now), _totalReword);
      
    //   Mission memory mission = missions[msg.sender];
      emit GeneratedMission(msg.sender, _likingGoal, getDeadline(now), _totalReword);
  }
  
   // @dev 등록한 광고의 정보를 볼수있는 콜 데이터
   // @return 목표좋아요,기간,총 보상량,현재 좋아요
  function getMission() public view returns (uint,uint,uint,uint) {
      Mission memory mission = missions[msg.sender];
      return (mission.likingGoal, mission.deadline, mission.totalReword, mission.likingNow);
  }
    // @dev 기간을 설정기능.
    // @params _now 현재 시간.
    // @return 현재 시간 + 30일
  function getDeadline(uint _now) public pure returns (uint) {
       return _now + (3600 * 24 * 30);
  }
  
}