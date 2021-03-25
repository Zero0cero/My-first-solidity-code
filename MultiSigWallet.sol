pragma solidity 0.7.5;
pragma abicoder v2;

/*
-The contract has to have funds in int
-everyone can deposit funds to the contract
-each address can see its balance
-owners can se total balance of the contract
-just owners can create a transaction
-we can have more than 0 transaction pending to be approved
-owners have to sign/ approve the transaction
-the transaction has some caracteristics
-have to say who is the owners
*/

//["0x5B38Da6a701c568545dCfcB03FcB875f56beddC4", "0xAb8483F64d9C6d1EcF9b849Ae677dD3315835cb2", "0x4B20993Bc481177ec7E8f571ceCaE8A9e22C02db"]

contract MultisigWallet{
    
    //number of signatures need to approve the transaction
    uint signNeed;
    
    //array to store the owners introduced at deploy
    address[] public owners;
    
    //array to store the transactions
    Transaction[] transactionList;
    
    //set the owners at deploy
    constructor (uint _signNeed, address[] memory _owners){
        require(_signNeed <= _owners.length);
        signNeed = _signNeed;
        owners = _owners;
    }
    
    //the transaction has some characteristics
    struct Transaction {
        address from;
        address payable to;
        uint amount;
        uint numberOfApprovals;
        bool approved;
        uint ID;
    }
    
    //bunch of requires that make only able to execute the function the owners
    modifier onlyOwners {
        bool ownerAccess = false;
        for(uint i = 0; i< owners.length; i++){
            if(msg.sender == owners[i]){
                ownerAccess = true;
                break;
            }
        }
        require(ownerAccess == true);
        _;
    }

    
    //record the balance of funds for each address
    mapping (address => uint) balanceOf;
    
    //record which address has sign which transaction
    mapping(address => mapping(uint => bool)) addressWhoSigned;
    
    //when transaction, the value inserted is in wei
    //so more comfortable if the user write in ether
    //this function convert wei in ether
    function _convertEtherWei(uint _amount) private pure returns(uint){
        return _amount*1e18;
    }
    
    //deposit funds in the contract
    function depositFunds() public payable {
        balanceOf[msg.sender] += msg.value;
    }
    
    //get the own balance
    function getBalance() public view returns(uint){
        return balanceOf[msg.sender];
    }
    
    //get the entire contract balance
    function getContractBalance() public view onlyOwners returns(uint){
        return address(this).balance;
    }
    
    //create the Transaction
    function createTransaction(address payable _to, uint _amount) public onlyOwners {
        require(address(this).balance >= _amount);
        Transaction memory newTransaction = Transaction(msg.sender, _to, _convertEtherWei(_amount), 0, false, transactionList.length);
        transactionList.push(newTransaction);
    }
    
    //Approve the Transaction
    function approveTransaction(uint _id) public onlyOwners{
        require(addressWhoSigned[msg.sender][_id] == false);
        require(transactionList[_id].approved == false);
        
        addressWhoSigned[msg.sender][_id] = true;
        transactionList[_id].numberOfApprovals ++;
        
        if(transactionList[_id].numberOfApprovals >= signNeed){
            transactionList[_id].to.transfer(transactionList[_id].amount);
            transactionList[_id].approved = true;
        }
    }
    
    //Get the list of transactions
    function getTransactionList() public view onlyOwners returns(Transaction[] memory){
        return transactionList;
    }
}
