pragma solidity ^0.5.0;

import "caver-js/packages/caver-kct/src/contract/token/KIP7/KIP7.sol";
import "caver-js/packages/caver-kct/src/contract/token/KIP7/KIP7Metadata.sol";
import "caver-js/packages/caver-kct/src/contract/token/KIP7/KIP7Pausable.sol";

contract HeartLink is KIP7,KIP7Metadata,KIP7Pausable{
    address[] public owners;
    uint256 private _totalSupply;
    uint256 public transactionCount;
    uint256 public required;
    
    mapping (address => uint256) private _balances;
    mapping (address => bool) public isOwner;
    mapping (uint => Transaction) public transactions;
    mapping (uint => mapping (address => bool)) public confirmations;
    
    
    event CoinDeposit(address indexed _from, uint256 _value); 
    event SwapRequest(address indexed _from, uint256 _value);    
    event Confirmation(address indexed sender, uint indexed transactionId);
    event Execution(uint indexed transactionId);
    event ExecutionFailure(uint indexed transactionId);
    event Submission(uint indexed transactionId);
    event Deposit(address indexed sender, uint value);
    
    struct Transaction {
        address destination;
        uint value;
        bytes data;
        bool executed;
    }
    
    modifier ownerExists(address owner) {
        require(isOwner[owner]);
        _;
    }
    
     modifier transactionExists(uint transactionId) {
        require(transactions[transactionId].destination != address(0));
        _;
    }
    
    modifier notExecuted(uint transactionId) {
        require(!transactions[transactionId].executed);
        _;
    }
    
    modifier notConfirmed(uint transactionId, address owner) {
        require(!confirmations[transactionId][owner]);
        _;
    }
    
    modifier confirmed(uint transactionId, address owner) {
        require(confirmations[transactionId][owner]);
        _;
    }
    
    modifier notNull(address _address) {
        require(_address != address(0));
        _;
    }
    
    function()
        external payable
    {
        if (msg.value > 0)
            emit Deposit(msg.sender, msg.value);
    }
    
    constructor(address[] memory _owners, uint _required, string memory name, string memory symbol, uint8 decimals) KIP7Metadata(name, symbol, decimals) public { 
        for (uint i=0; i<_owners.length; i++) {
                require(!isOwner[_owners[i]] && _owners[i] != address(0));
                isOwner[_owners[i]] = true;
            }
            owners = _owners;
            required = _required;
    }
    
    // @dev스테이킹 기능, 스테이킹시 같은 갯수의 토큰을 반환
    function Staking() public payable {
        _balances[msg.sender] += _balances[msg.sender].add(msg.value);
        _totalSupply = _totalSupply.add(msg.value); 
        _mint(msg.sender,msg.value);
        emit CoinDeposit(msg.sender, msg.value);
    }
    
    // @dev 언스테이킹 기능
    // @params amount 언스테이킹할 수량
    function Unstaking(uint256 amount) public returns (bool) {
        require(amount <= _balances[msg.sender]);
        _balances[msg.sender] = _balances[msg.sender].sub(amount);
        _burn(msg.sender,amount);
        msg.sender.transfer(amount);
        emit SwapRequest(msg.sender,amount);
        return true;
    }
    
    // @dev 스테이커에게 클레이 전송하는 기능. 이 기능은 오로지 컨트렉트의 주인만이 할수있다.
    // @params _to 받는사람주소
    // @params amount 보내는 수량
    // function TransferToStaker(address payable _to, uint256 amount) onlyOwner public {
    //     _to.transfer(amount);
    // }
    
    //------------------------- Multisig ---------------------------------------
    
    /// @dev Allows an owner to submit and confirm a transaction.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function submitTransaction(address destination, uint value, bytes memory data)
        public
        returns (uint transactionId)
    {
        require(isOwner[msg.sender]);
        transactionId = addTransaction(destination, value, data);
        confirmTransaction(transactionId);
    }
    
    /// @dev Allows an owner to confirm a transaction.
    /// @param transactionId Transaction ID.
    function confirmTransaction(uint transactionId)
        public
        ownerExists(msg.sender)
        transactionExists(transactionId)
        notConfirmed(transactionId, msg.sender)
    {
        confirmations[transactionId][msg.sender] = true;
        emit Confirmation(msg.sender, transactionId);
        executeTransaction(transactionId);
    }
    
    /// @dev Allows anyone to execute a confirmed transaction.
    /// @param transactionId Transaction ID.
    function executeTransaction(uint transactionId)
        public
        ownerExists(msg.sender)
        confirmed(transactionId, msg.sender)
        notExecuted(transactionId)
    {
        if (isConfirmed(transactionId)) {
            Transaction storage txn = transactions[transactionId];
            txn.executed = true;
            if (external_call(txn.destination, txn.value, txn.data.length, txn.data))
                emit Execution(transactionId);
            else {
                emit ExecutionFailure(transactionId);
                txn.executed = false;
            }
        }
    }
    
    /// @dev Returns the confirmation status of a transaction.
    /// @param transactionId Transaction ID.
    /// @return Confirmation status.
    function isConfirmed(uint transactionId)
        public
        view
        returns (bool)
    {
        uint count = 0;
        for (uint i=0; i<owners.length; i++) {
            if (confirmations[transactionId][owners[i]])
                count += 1;
            if (count == required)
                return true;
        }
    }
    
    /// @dev Adds a new transaction to the transaction mapping, if transaction does not exist yet.
    /// @param destination Transaction target address.
    /// @param value Transaction ether value.
    /// @param data Transaction data payload.
    /// @return Returns transaction ID.
    function addTransaction(address destination, uint value, bytes memory data)
        internal
        notNull(destination)
        returns (uint transactionId)
    {
        transactionId = transactionCount;
        transactions[transactionId] = Transaction({
            destination: destination,
            value: value,
            data: data,
            executed: false
        });
        transactionCount += 1;
        emit Submission(transactionId);
    }
    
    // call has been separated into its own function in order to take advantage
    // of the Solidity's code generator to produce a loop that copies tx.data into memory.
    function external_call(address destination, uint value, uint dataLength, bytes memory data) internal returns (bool) {
        bool result;
        assembly {
            let x := mload(0x40)   // "Allocate" memory for output (0x40 is where "free memory" pointer is stored by convention)
            let d := add(data, 32) // First 32 bytes are the padded length of data, so exclude that
            result := call(
                sub(gas, 34710),   // 34710 is the value that solidity is currently emitting
                                   // It includes callGas (700) + callVeryLow (3, to pay for SUB) + callValueTransferGas (9000) +
                                   // callNewAccountGas (25000, in case the destination address does not exist and needs creating)
                destination,
                value,
                d,
                dataLength,        // Size of the input (in bytes) - this is what fixes the padding problem
                x,
                0                  // Output is ignored, therefore the output size is zero
            )
        }
        return result;
    }
}
