// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.16;

contract DataTrading {
    string public id;

    address owner; //合约所有者
    address public dataRequester; //数据请求者
    string public dataStyle; //数据风格
    uint256 public quLimit; //数据质量限制
    uint256 public deadline; //截止日期
    uint256 public tradingBudget; //交易预算
    string public requestPK; //公钥

    uint256 public selectedNum; //选择数据的数量
    uint256 public selectedNumMax; //选择数据的上限
    uint256 public candidateNum; //候选数据的数量
    uint256 public candidateNumMax; //候选数据的数量上限
    string[] candidateDataList; //候选数据列表
    string[] selectedDataList; //选择数据列表

    string[] datasIDi; //评论过的数据ID
    address[] dataUsersAddr; //数据所有者地址集合
    string[] datasID; //数据ID

    uint256 projectBenefits; //项目利润
    uint256 public quanAMOUNT; //数据总质量
    address[] datasProvider;//数据提供者
    uint[] datasReward;//数据奖励集合 
    uint256[] datasquanlity; //数据质量集合

    bool done=false;

    struct Data {
        string dataUID;
        string datastyle;
        uint256 amount;
        uint256 registerTime;
        string description;
        uint256 tradeNum;
        string dataHash;
        string storageProof;
        uint256 evaluation;
        address[] transferProcess;
        uint256[] tradingPrice;
    } //数据struct

    struct DataEve {
        string dataIDi;
        string integrityEveluate; //完整性评估
        uint256 integrityScore; //得分
        string consistencyEveluate;
        uint256 consistencyScore; //一致性
        string accuracyEveluate;
        uint256 accuracyScore; //准确性
        uint256 qualityScore;
    } //数据评估

    struct DataReward {
        string dataIDi;
        uint256 rewardC;
    } //数据奖励

    mapping(string => Data) datas;
    mapping(string => address) dataToOwner;
    mapping(string => DataEve) dataeve;
    mapping(string => DataReward) datareward;

    modifier onlyOwner() {
        if (msg.sender == owner) _;
    }

    modifier onlyOwnerOf(string calldata _dataUID) {
        require(msg.sender == dataToOwner[_dataUID]);
        _;
    }

    event DataAddBlock(address _providerAddr, bool isSuccess, string message); //注册数据集事件
    event DataSimiliarCheck(string dataUID, bool isSimiliar, string message); //检测数据相似事件
    event providerAthtoCan(string _dataUID, bool isSuccess, string message); //增加到候选集事件
    event chooseToSelectedDataList(string _dataUID,bool isSuccess,string message); //数据集加入到选择数据集事件
    event DemanderbuyData(address _demanderAddr,bool isSuccess,string message); //购买数据事件
    event EvaluateData(address _valuator, bool isSuccess, string message); //评价事件
    event showOwner(string _dataUID, address _valuator); //展示数据所有者事件
    event rewardpay(address datasProvider, uint256 datasReward); //奖励分配事件

    //函数区
    constructor() {
        owner = msg.sender; //msg.sender是当前钱包的发起方
        //"run"时选择的是哪个account(钱包地址)，msg.sender就是哪个地址。
    }

    function Transfer() public payable {
        owner = msg.sender;
    }

    function getBalance() public view returns (uint256) {
        return address(this).balance; //获得地址余额
    }

    function dataSummary(address _providerAddr, string memory _dataUID, string memory _datastyle,  uint _evaluation, uint _amount,
        string memory _description, string memory _storageProof,string memory _dataHash) public {

        id = _dataUID;
        datas[id].dataUID = id;
        datas[id].registerTime =block.timestamp;
        datas[id].datastyle = _datastyle;
        datas[id].amount= _amount;
        datas[id].description = _description;
        datas[id].storageProof = _storageProof;
        datas[id].dataHash = _dataHash;
        datas[id].tradeNum = 0;
        datas[id].evaluation = _evaluation;
        datas[id].transferProcess.push(_providerAddr);
        datasID.push(id);
        dataToOwner[id] = _providerAddr;
        emit DataAddBlock(_providerAddr, true, "success to register data");
        return;
    }//数据注册

    function dataRequirements(address isDataRequester,uint DA,uint dl,uint CL,uint budget,uint qualityLimit,string calldata PKj,string calldata DS) public {
        dataRequester = isDataRequester;                    
        selectedNumMax=DA;                                                        
        candidateNumMax =DA*CL;                         
        deadline = block.timestamp + dl * 1 minutes;          
        tradingBudget=budget;                    
        dataStyle=DS;                         
        requestPK=PKj;                          
        quLimit=qualityLimit;                     
        candidateNum=0;                  
        selectedNum=0;                      
    }//数据需求设定函数

    function DataSimiliarChecking(string memory _dataUID) public {
        uint length = datasID.length;
        for(uint32 i=0;i<length;i++){
            id=datasID[i];
            if(keccak256(abi.encode(datas[id].dataHash))==keccak256(abi.encode(datas[_dataUID].dataHash))){//数据hash相同了
                emit DataSimiliarCheck(id,true,"the data set is similar");
            }
        }
    }//数据相似性检查

    function EvaluationChain(string memory _dataUID) public returns (string memory,uint,string memory,uint,string memory,uint) {
            id = _dataUID;
            return (dataeve[id].integrityEveluate,dataeve[id].integrityScore,dataeve[id].consistencyEveluate,dataeve[id].consistencyScore,dataeve[id].accuracyEveluate,dataeve[id].accuracyScore);
    }//数据评估加入链
    
    function SummaryChain(string memory _dataUID) public returns (string memory,string memory,string memory,string memory,uint,string memory) {
            id = _dataUID;
            return (datas[id].dataUID,datas[id].datastyle,datas[id].description,datas[id].storageProof,datas[id].amount,datas[id].dataHash);
    }//数据简介加入链 

    function AthtoCandidateDataList(string memory _dataUID) public returns (bool result){
        id=_dataUID;
        require(msg.sender==dataToOwner[id]);
        if(keccak256(abi.encode(datas[id].datastyle)) ==  keccak256(abi.encode(dataStyle))){//256hash
             if(datas[id].evaluation>=quLimit){
                if(candidateNumMax>= candidateNum){
                    require(datas[id].evaluation>=quLimit);
                    require(candidateNumMax>= candidateNum);
                    require(block.timestamp<deadline);
                    candidateDataList.push(id);
                    candidateNum+=datas[id].amount;
                    emit providerAthtoCan( _dataUID, true, "data set has been added to candidate");
                    return false;
                }
                else{
                    emit providerAthtoCan( _dataUID, false, "the candidate set is already full");
                }
            }
            else{
                emit providerAthtoCan( _dataUID, false, "the quality of data set is too low");
            }
        }
        else{
            emit providerAthtoCan( _dataUID, false, "the data set is not suitable for the requirement");
        }
    }//构造数据候选名单

    function ShowcandidateDataList() view public returns (uint,uint[] memory, uint[] memory, address[] memory){
        uint length = candidateDataList.length;
        uint[] memory datasPrice = new uint[](length);
        uint[] memory datasQua = new uint[](length);
        address[] memory datasOwner = new address[](length);
        for(uint32 i=0;i<length;i++){
            datasPrice[i] = datas[candidateDataList[i]].amount;
            datasQua[i] = datas[candidateDataList[i]].evaluation;
            datasOwner[i] = dataToOwner[candidateDataList[i]];
        }
       return (length, datasPrice, datasQua, datasOwner);
    }//展示数据候选名单

    function SelectedDataList(string memory _dataUID) onlyOwner public {
        require(selectedNumMax>= selectedNum);
        selectedDataList.push(_dataUID);
        datas[id].tradeNum = datas[_dataUID].tradeNum + 1;
        selectedNum+=datas[_dataUID].amount;
        datas[id].transferProcess.push( msg.sender);
        emit chooseToSelectedDataList( _dataUID, true, "the data set is added to the deal");
        emit DemanderbuyData( msg.sender, true, "success to buy the data set");
        return ;
    }//数据集加入到交易数据集，进行购买

    function writeEvaluation(string memory _dataUIDi, address _demanderAddr, string memory _integrityEveluate, uint _integrityScore,string memory _consistencyEveluate, uint _consistencyScore,string memory _accuracyEveluate, uint _accuracyScore) public {
        id = _dataUIDi;
        uint temTN= datas[id].tradeNum;
        if(datas[id].transferProcess[temTN] != msg.sender) {
            emit EvaluateData(_demanderAddr, false, "you have no right to evaluate");
            return;
        }
        else {
            dataeve[id].dataIDi= id;
            dataeve[id].integrityEveluate = _integrityEveluate;
            dataeve[id].integrityScore = _integrityScore;
            dataeve[id].consistencyEveluate = _consistencyEveluate;
            dataeve[id].consistencyScore = _consistencyScore;
            dataeve[id].accuracyEveluate = _accuracyEveluate;
            dataeve[id].accuracyScore = _accuracyScore;
            dataeve[id].qualityScore =_integrityScore+ _consistencyScore+_accuracyScore;
            datasIDi.push(id);
            emit EvaluateData(_demanderAddr, true, "success to evaluate");
            return;
        }
    }//写数据评论

    function showDataToOwner(string calldata _dataUID) public returns (address){
        emit showOwner(_dataUID,dataToOwner[_dataUID]);
        return dataToOwner[_dataUID];
    }//展示数据所有者

    function rewardAssigned() onlyOwner public returns (address[] memory Provider,uint[] memory Reward){
        uint selength=selectedDataList.length;//string memory uidtemp;
        uint temp1;
        quanAMOUNT=0;
        for(uint32 i=0;i<selength;i++){
            temp1=datas[selectedDataList[i]].amount*dataeve[selectedDataList[i]].qualityScore;
            datasquanlity.push(temp1);               
            quanAMOUNT+=temp1;            
        }
        for(uint32 k=0;k<selength;k++){
            datasProvider.push(dataToOwner[selectedDataList[k]]);  
            datasReward.push(datasquanlity[k]/quanAMOUNT*tradingBudget); 
        }
        return(datasProvider,datasReward);
    }//按照数据质量*数据数量进行占比分配预处理

    function showReward() view public returns (uint[] memory){
         return (datasquanlity);
    }

    function rewardPay(address payable[] calldata _datasProvider,uint256[] calldata _datasReward) payable public returns (bool result) {
        require(_datasProvider.length > 0);
        require(msg.sender == owner);
        for(uint32 i=0;i<_datasProvider.length;i++){
            _datasProvider[i].transfer(_datasReward[i]);//转给了_datasProvider[i]
            emit rewardpay(_datasProvider[i], _datasReward[i]); 
        }
        done=true;
        return true;
    }//实际进行转帐

    function dataPreview(string memory _dataUID) public view returns (string memory description)
    {
        string memory dataDescription=datas[_dataUID].description;
        return (dataDescription);
    }//查询数据简介

    receive() external payable { }
    fallback() external payable {}
}
