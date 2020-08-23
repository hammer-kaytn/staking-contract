pragma solidity ^0.5.0;

import "caver-js/packages/caver-kct/src/contract/token/KIP7/KIP7.sol";

contract Klaymore is KIP7 {
    address private _owner;
    string private _name;
    string private _symbol;
    uint8 private _decimals;
    uint256 private _totalSupply;
    address [] internal stakeholders; 
    
    mapping(address => uint256) internal stakes;
    mapping(address => uint256) internal rewards;
    
    constructor(string memory name,string memory symbol,uint8 decimals) public {
        _name = name;
        _symbol = symbol;
        _decimals = decimals;
    }
    // 테스트용 클레이예치 및 토큰 반환하는기능.  비율은 예치한 클레이와 동일하게함.
    function createStake(uint256 _stake) public {
        _burn(msg.sender, _stake);
        if(stakes[msg.sender] == 0) addStakeholder(msg.sender);
        stakes[msg.sender] = stakes[msg.sender].add(_stake);
    }
    
    function removeStake(uint256 _stake) public {
        stakes[msg.sender] = stakes[msg.sender].sub(_stake);
        if(stakes[msg.sender] == 0) removeStakeholder(msg.sender);
        _mint(msg.sender, _stake);
    }
    
    function stakeOf(address _stakeholder) public view returns(uint256) {
        return stakes[_stakeholder];
    }
    
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
    
    function addStakeholder(address _stakeholder) public {
        (bool _isStakeholder, ) = isStakeholder(_stakeholder);
        if(!_isStakeholder) stakeholders.push(_stakeholder);
    }
    
    function removeStakeholder(address _stakeholder) public {
        (bool _isStakeholder, uint256 s) = isStakeholder(_stakeholder);
        if(_isStakeholder){
            stakeholders[s] = stakeholders[stakeholders.length - 1];
            stakeholders.pop();
        } 
    }
    // ---------- REWARDS ----------
    
    /**
     * @notice A method to allow a stakeholder to check his rewards.
     * @param _stakeholder The stakeholder to check rewards for.
     */
    function rewardOf(address _stakeholder) public view returns(uint256)
    {
        return rewards[_stakeholder];
    }

    /**
     * @notice A method to the aggregated rewards from all stakeholders.
     * @return uint256 The aggregated rewards from all stakeholders.
     */
    function totalRewards() public view returns(uint256) {
        uint256 _totalRewards = 0;
        for (uint256 s = 0; s < stakeholders.length; s += 1){
            _totalRewards = _totalRewards.add(rewards[stakeholders[s]]);
        }
        return _totalRewards;
    }

    /** 
     * @notice A simple method that calculates the rewards for each stakeholder.
     * @param _stakeholder The stakeholder to calculate rewards for.
     */
    function calculateReward(address _stakeholder) public view returns(uint256) {
        return stakes[_stakeholder] / 100;
    }

    /**
     * @notice A method to distribute rewards to all stakeholders.
     */
    // function distributeRewards() public onlyOwner {
    //     for (uint256 s = 0; s < stakeholders.length; s += 1){
    //         address stakeholder = stakeholders[s];
    //         uint256 reward = calculateReward(stakeholder);
    //         rewards[stakeholder] = rewards[stakeholder].add(reward);
    //     }
    // }

    /**
     * @notice A method to allow a stakeholder to withdraw his rewards.
     */
    function withdrawReward() public {
        uint256 reward = rewards[msg.sender];
        rewards[msg.sender] = 0;
        _mint(msg.sender, reward);
    }
}