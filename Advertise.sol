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
  
    mapping (uint => Mission) public missions; //광고등록이 덮어씌어지지 않도록 uint id로 맵핑
    uint missionsId = 0;
    
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
  
   // @dev 광고 "좋아요"를 누르는 기능
   // @parmas _missionId 광고주가 등록한 미션 식별 아이디.
  function likeMission(uint _missionId) public {
      for (uint i = 0; i <= missions[_missionId].likedUsers.length; i++) {
          if(missions[_missionId].likedUsers[i] == msg.sender){
              revert();
          } else {
              missions[_missionId].likedUsers.push(msg.sender);
              missions[_missionId].likingNow += 1;
              emit LikeMission(_missionId,msg.sender);
          }
      }
  }
  // @dev 만든 배열을 갯수를 확인하기 위한 테스트용 함수
    function dwadwa(uint _missionId) public view returns (uint) {
      return missions[_missionId].likedUsers.length;
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
       return _now + (3600 * 24 * 30);
  }
  

}