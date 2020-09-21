pragma solidity ^0.5.0;

contract Advertise {
    struct Mission{
        uint id; //미션의 식별자
        address[] likedUsers; //좋아요를 누른사람들의 지갑 주소
        address advertiser; //미션을 생성한 광고주의 주소
        uint likingGoal; //미션을 완료하기 위한 목표 좋아요
        uint likingNow; //현재 좋아요.
        uint deadline; //미션 기간 데드라인
        uint totalReword; //미션에 걸려있는 총 보상
    }
  
    mapping (uint => Mission) public missions; //광고등록이 덮어씌어지지 않도록 맵핑
    uint missionsId = 0;
    
    event GeneratedMission(
        uint indexed _id,
        address indexed _advertiser,
        uint _likingGoal,
        uint _deadline,
        uint _totalReword);
    
    event LikeMission(
        uint indexed _id,
        address indexed _user
        );
    
    // @dev 광고를 등록하는 기능.
    // @params _likingGoal 목표 좋아요.
    // @params _totalReword 총 보상 지급량.
  function createAdvertise(uint _likingGoal, uint _totalReword) public {
      address[] memory likedUsers;
      missions[missionsId] = Mission(missionsId, likedUsers, msg.sender, _likingGoal, 0, getDeadline(now), _totalReword);
      
      Mission memory mission = missions[missionsId];
      emit GeneratedMission(missionsId, msg.sender, mission.likingGoal, getDeadline(now), mission.totalReword);
      missionsId++;
  }
  
  function likeMission(uint _missionId) public returns (bool) {
      missions[_missionId].likedUsers.push(msg.sender);
      missions[_missionId].likingNow += 1;
      
      emit LikeMission(_missionId,msg.sender);
  }
  
   // @dev 등록한 광고의 정보를 볼수있는 콜 데이터
   // @return 목표좋아요,기간,총 보상량,현재 좋아요
  function getMission() public view returns (uint,uint,uint,uint) {
      Mission memory mission = missions[missionsId];
      return (mission.likingGoal, mission.deadline, mission.totalReword, mission.likingNow);
  }
    // @dev 기간을 설정기능.
    // @params _now 현재 시간.
    // @return 현재 시간 + 30일
  function getDeadline(uint _now) public pure returns (uint) {
       return _now + (3600 * 24 * 30);
  }

}