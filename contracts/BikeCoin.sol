pragma solidity 0.5.0 ;
pragma experimental ABIEncoderV2;

contract BikeCoin
{
    
    address payable public owner ;
    uint public rentPrice ;
    enum State  {notRented , Rented}  
    
    struct Member{
        address add ; //會員地址
        string name ; //會員姓名
        uint age ; //會員年齡
        uint sex ; //會員性別
        uint id ;  //租借腳踏車編號
        bool pay ; //是否付款
        mapping(uint => bike) bikes; //腳踏車詳細資訊
    }
    
    struct bike{
        string location ; //租借地址
        address rentAddress; //租借帳戶EOA地址
        uint rentStartTime;  //租借時間
        uint rentEndTime;  //還車時間
        uint price ; // 租借總費用
    }
    
    mapping(uint => State) public  rentState ; //腳踏出租借狀態
    mapping(address => Member) public memberRent ; //會員詳細資訊
    mapping(address => bool) public registerState ; //註冊狀態
    
    modifier isRegister(){
        require(registerState[msg.sender] == false , "you had register");
        _;
    }
    
      modifier onlyOwner(){
        require(owner == msg.sender , "not owner");
        _;
    }
    constructor() public payable{
        owner = msg.sender ;
        rentPrice = 1 ether;
    }
    
    function register(string memory _name , uint _age , uint _sex) public isRegister() returns(bool){
        
        memberRent[msg.sender] = Member(msg.sender , _name , _age , _sex , 0 , true);
        registerState[msg.sender] = true ;
        return true ;
    } 
    
    
    function rentBike(uint _id , string memory _location) public{
        
        require(registerState[msg.sender] == true , "not register");
        require(rentState[_id] == State.notRented ,"you have rented");
        require(memberRent[msg.sender].pay == true , "You have unpaid amount ");
        
        memberRent[msg.sender].id = _id ;
        memberRent[msg.sender].pay = false;
        memberRent[msg.sender].bikes[_id] = bike(_location , msg.sender , now , 0 , 0);
        
        rentState[_id] = State.Rented;
    }
    
    
    function returnBike(uint _id) public  returns(uint){
        require(memberRent[msg.sender].id == _id , "You haven't rented ");
        memberRent[msg.sender].bikes[_id].rentEndTime = now ;
        
        uint time = memberRent[msg.sender].bikes[_id].rentEndTime - memberRent[msg.sender].bikes[_id].rentStartTime ;
        memberRent[msg.sender].bikes[_id].price = time * rentPrice ;
        rentState[_id] = State.notRented ;
        return (time * rentPrice) / 1 ether;
    }
    
    function pay() public payable returns(bool){
        require(memberRent[msg.sender].pay == false , "you have pay");
        require(msg.value == memberRent[msg.sender].bikes[memberRent[msg.sender].id].price,"pay error");
       // address(this).transfer(msg.value);
        memberRent[msg.sender].pay = true ;
        delete memberRent[msg.sender].id ;
        delete memberRent[msg.sender].bikes[memberRent[msg.sender].id];
        return true ;
    }
    
    function queryRent(address _add) public view returns(bike memory){
        uint id = memberRent[_add].id ;
        return memberRent[_add].bikes[id];
    }
    
    function queryMember(address _add) public view returns(address add, string memory name,uint age,uint sex, uint id){
        add = memberRent[_add].add; 
        name = memberRent[_add].name; 
        age = memberRent[_add].age;
        sex = memberRent[_add].sex;
        id = memberRent[_add].id;
        //return(add , name, age , sex , id);
    }
    
    function contract_balance() public view onlyOwner() returns(uint){
        return address(this).balance ;
    }
    
    function() external payable{}
}

