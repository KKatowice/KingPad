// SPDX-License-Identifier: KK
pragma solidity 0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
contract KINGPAD_Factory is Ownable{
    using EnumerableSet for EnumerableSet.AddressSet;
    EnumerableSet.UintSet private activePsaleIDs;
    
    address[] private PsalePools;
    address public spawnAdrs;
    address public spawnLockAdrs;
    address public feeReciver;

    string public pSaleCreationURI;

    uint public PsaleID = 0;

    uint public feeOpenPsale = 1;

    uint public feeOnlyBnb = 3;

    uint public minLiqXcent = 50;
    uint public minimumTimeForNextPhase = 6000;
    uint constant public precNumb = 10**30;


    bool public tokenFeeActive = false;

    mapping(uint=>address) public IDaddresses;
    mapping(address=>bool) public presaleC_check;
    mapping(address=>address) public lockedTokenToLocker;
    mapping(address=>address) public tokenToLockerLp;
    mapping(address=>bool) public authorizedCreator;
    mapping(address=>bool) public permittedPairs;


    event PreSaleCreated(address indexed creator, address indexed pSaleAddress);
    event presaleKilled(address indexed addressPsale, string reason);
    event balanceTierLimitSet(uint[] tierz, uint[] t_minBalance);
    event addressLockSpawner_changed(address indexed addressSpawnLock);
    event addressPsaleSpawner_changed(address indexed pSaleAddress);
    event addressPath_changed(address indexed newPathAdr);
    event presaleCreationWhitelisted(address indexed user, bool inOrOut);
    event stuckedBnbRecovered(uint amount);
    event stuckedTokenRecovered(address indexed tnk ,uint amount);
    event settingChanged (uint feeOpenP, uint feeOnlyBnbs);
    event newPsaleUri(string newUri);
    event minimumTimeForNextPhase_updated(uint mintime);
    event lockedTokenToLockerAddress(address indexed tokenAdrs, address indexed lpTokenAdrs, address indexed lockerAdrs, uint idPresale);
    event feeReciver_updated(address indexed nreFeeReciver);
    event pairChanged(address indexed pair, bool isPermitted);

    constructor(){
        feeReciver = msg.sender;
    }
    function createPsale(address[] memory addressInfo, uint[] memory uintInfo, bool[] memory boolInfo, string[] memory strInfo, uint[] memory vestingInfo ) external payable returns(address){
//controlli sul pair
        require(permittedPairs[addressInfo[1]],"pair not in list");
        require(authorizedCreator[msg.sender],"you cant open a presale");
        require(BEP20(addressInfo[0]).owner() == msg.sender, "you are not the token owner");
        require(uintInfo[5]>minLiqXcent && uintInfo[1] >= uintInfo[2]/2, "liq% or soft/hard cap ratio wrong"); // liq% > 50% - softcap >= hardcap/2
        require(addressInfo[0] != address(0) && addressInfo[1] != address(0) && addressInfo[2] != address(0), "address(0) not valid");
        checkLiq(addressInfo[0], addressInfo[2], addressInfo[1]);
        address pool = spawnerz(spawnAdrs).spawnaPresale(
            addressInfo,
            uintInfo,
            boolInfo,
            strInfo,
            vestingInfo,
            PsaleID,
            msg.sender
        );
        
        // ...

        require(BEP20(addressInfo[0]).transferFrom(msg.sender, address(pool), tokNoFee));
        (bool success, ) = payable(feeReciver).call{value: msg.value}("");
        require(success);
        
        emit PreSaleCreated(msg.sender , address(pool));
        return address(pool);
    }
// external
    function createLock(uint liqlock, address creatorz, address pairz) external returns(address){
        require(presaleC_check[msg.sender], "you are not a presale contract");
        address lkA = spawnerzLock(spawnLockAdrs).spawnaLockr(liqlock, creatorz, pairz);
        return lkA;
    }
    function removeFinalizedIDs (uint id) external {
        require(presaleC_check[msg.sender], "you are not a presale contract");
        EnumerableSet.remove(activePsaleIDs, id);
    }
    function emergency_killPreSale(address psaleAddress,string memory reason) external onlyOwner {
        pSaleInterface(psaleAddress).emergency_killPreSale();
        emit presaleKilled(psaleAddress, reason);
    }
    // view
    function getpsale(uint256 id) external view returns (address) {
        return PsalePools[id];
    }
    function get_pSaleCreationURI() external view returns(string memory){
        return pSaleCreationURI;
    }
    function checkLiq (address adr, address router, address pair) internal view {
        address facto = PS_Router(router).factory();
        address pairz = factryMM(facto).getPair(adr, pair);
        if(pairz != address(0)){
            require(BEP20(pairz).totalSupply() == 0, "pair balance > 0");
        }
    }
    function returnActivePsaleIDs() external view returns (uint[] memory){
        uint lenList = EnumerableSet.length(activePsaleIDs);
        uint[] memory lst = new uint[](lenList);
        for(uint i=0; i<lenList; i++){
            lst[i] = EnumerableSet.at(activePsaleIDs, i);
        }
        return lst;
    }
    function returnActivePsaleAddresses() external view returns (address[] memory){
        uint lenList = EnumerableSet.length(activePsaleIDs);
        address[] memory lst = new address[](lenList);
        for(uint i=0; i<lenList; i++){
            lst[i] = IDaddresses[EnumerableSet.at(activePsaleIDs, i)];
        }
        return lst;
    }
    function returnPsaleInfo( address psaleAdrs) external view returns(uint,uint,uint,uint,uint,uint,uint){
        return pSaleInterface(psaleAdrs).returnInfoPresale();

    }

    function get_lockedTokenToLocker(address adr) public view returns(address){
        require(lockedTokenToLocker[adr] != address(0) || tokenToLockerLp[adr]!= address(0), "it doesn't exist");
        if(lockedTokenToLocker[adr] != address(0)){
            return lockedTokenToLocker[adr];
        }
        else{
            return tokenToLockerLp[adr];
        }
    }
    function getFeeBnb() external view returns(uint){
        return feeOnlyBnb;
    }


// utility
    function transferForeignToken(address _token, uint _value) external onlyOwner returns(bool _sent){
        if(_value == 0) {
            _value = BEP20(_token).balanceOf(address(this));
        }
        _sent = BEP20(_token).transfer(owner(), _value);
        require(_sent);
        
        emit stuckedTokenRecovered(_token, _value);
    }
    function Sweep() external onlyOwner {
        uint balance = address(this).balance;
        (bool success, ) = payable(owner()).call{value: balance}("");
        require(success);
        emit stuckedBnbRecovered(balance);
    }
    receive() external payable {}
// set

    function setspawnLockAdrs(address adr) external onlyOwner {
        spawnLockAdrs = adr;
        emit addressLockSpawner_changed(adr);
    }
    function set_pSaleCreationURI(string memory uriz) external onlyOwner {
        pSaleCreationURI = uriz;
        emit newPsaleUri(uriz);
    }
    function set_feeSettings(uint feeOpenP, uint feeOnlyBnbs ) external onlyOwner {
        feeOpenPsale = feeOpenP;
        feeOnlyBnb = feeOnlyBnbs;
        emit settingChanged(feeOpenP, feeOnlyBnbs);
    }
    function set_permittedPairs(address pairz, bool isPermitted)external onlyOwner{
        permittedPairs[pairz] = isPermitted;
        emit pairChanged(pairz, isPermitted);
    }
    function setSpawnAddress(address adr) external onlyOwner {
        spawnAdrs = adr;
        emit addressPsaleSpawner_changed(adr);
    }
    function set_authCreator(address who, bool isAuth) external onlyOwner{
        authorizedCreator[who] = isAuth;
        emit presaleCreationWhitelisted(who,isAuth);
    }
    function set_minimumTimeForNextPhase(uint minTime) external onlyOwner {
        minimumTimeForNextPhase = minTime;
        emit minimumTimeForNextPhase_updated(minTime);
    }
    function get_minimumTimeForNextPhase() external view returns(uint){
        return minimumTimeForNextPhase;
    }
    function set_lockerFromlockedToken(address lpTokenAddress, uint idPsale, address lockerz, address tokenz) external {
        require(presaleC_check[msg.sender], "you are not a presale contract");
        lockedTokenToLocker[lpTokenAddress] = lockerz;
        tokenToLockerLp[tokenz] = lockerz;
        emit lockedTokenToLockerAddress(tokenz, lpTokenAddress, lockerz, idPsale);
    }
    function set_feeReciver(address adr) external onlyOwner{
        feeReciver = adr;
        emit feeReciver_updated(adr);
    }
    function getFeeRec() external view returns(address){
        return feeReciver;
    }

    
}

interface pSaleInterface{
    function emergency_killPreSale() external;
    function returnInfoPresale() external view returns(uint,uint,uint,uint,uint,uint,uint);
    function set_tierLimit(uint[] memory t_buyLimitB) external;
}
interface spawnerz {
    function spawnaPresale(address[] memory addressInfo, uint[] memory uintInfo, bool[] memory boolInfo, string[] memory strInfo, uint[] memory vestingInfo, uint PsaleID, address creatir ) external returns(address);
}
interface spawnerzLock{
    function spawnaLockr(uint liqlock, address creatorz, address pairz) external returns(address);

}
abstract contract BEP20 {
    function approve(address guy, uint wad) virtual public returns (bool);
    function balanceOf(address tokenowner) virtual external view returns (uint256);
    function transfer(address receiver, uint256 numTokens) virtual public returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool);
    function totalSupply() virtual external view returns (uint256);
    function owner() public view virtual returns (address);

}
interface factryMM {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
}
interface PS_Router {
    function factory() external view returns (address);
}



