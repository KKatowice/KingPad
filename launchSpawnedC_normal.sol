// SPDX-License-Identifier: KK

pragma solidity 0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";
import "@openzeppelin/contracts/token/ERC721/extensions/ERC721URIStorage.sol";
import "@openzeppelin/contracts/token/ERC721/ERC721.sol";
import "@openzeppelin/contracts/utils/structs/EnumerableSet.sol";
contract KINGPAD is ERC721URIStorage,Ownable {
    using EnumerableSet for EnumerableSet.AddressSet;
    address constant public bnbA = 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c; // main: 0xbb4CdB9CBd36B01bD1cBaEBF2De08d9173bc095c;  test: 0xae13d989daC2f0dEbFf460aC112a837C89BAa7cd
    address public creatorz;
    address constant public dead = 0x000000000000000000000000000000000000dEaD;
    uint public idThis;
    bool public created = false; //nft
    PathLaunchpadz_factory public Launchpad_factory;
    BEP20 public pathAddressz;
    EnumerableSet.AddressSet private partecipant;
    mapping(address=>UsrInfo) public userDB;
    struct UsrInfo {
        bool vest_firstClaim;
        uint claimEpoch;
        uint claimableToken;
        uint total_claimableToken;
        uint amountDeposit;
    }
    mapping(address=>bool) public whiteListP1;
    address public token;
    address public pair;
    address public router;
    address public addrsLocker;
    address public pairz;
    address public feeRec;
    uint public phase = 0;
    uint public soldToken;
    uint public constant precisionNum = 10**30;
    uint public totalContribution = 0;
    uint public pSaleRation = 0;
    uint public soft = 0;
    uint public hardcap = 0;
    uint public minToBuy = 0;
    uint public maxToBuy = 0;
    uint public liq = 0;
    uint public listrate = 0;
    uint public start = 0;
    uint public endtime = 0;
    uint public liqlock = 0;
    uint public refundtype = 0;
    uint public vest_1stRelease = 0;
    uint public vest_everyXdays = 0;
    uint public vest_tokenEachCycle = 0;
    uint public _claimed = 0;
    bool public vesting = false;
    bool public finalized = false;
    bool public killed = false;
    bool public WLenabled = false;
    bool public softReached = false;
    string public logoURL;
    string public website;
    string public facebook;
    string public twitter;
    string public instagram;
    string public discord;
    string public reddit;
    string public description;
    string public auditLink;

    event PsaleCreated(address indexed factory, address indexed PsaleAddress, address creator, uint pSaleID, uint256 date);
    event Deposited(address indexed user, uint indexed amount);
    event withdrawn(address indexed user, uint indexed amount);
    event Finalized(uint indexed partecipantsAmount, uint indexed amountRaised);
    event NextPhase(uint indexed partecipantsAmount, uint indexed amountRaised);
    event Claimed(address indexed user, uint indexed amount);
    event ClaimedVesting(address indexed user, uint indexed amount);
    event logoURL_changed(string new_logoURL );
    event website_changed(string new_website );
    event facebook_changed(string new_facebook );
    event twitter_changed(string new_twitter );
    event instagram_changed(string new_instagram );
    event discord_changed(string new_discord );
    event reddit_changed(string new_reddit );
    event description_changed(string new_description );

 constructor(address fact, address[] memory addressInfo, uint[] memory uintInfo, bool[] memory boolInfo, string[] memory strInfo, uint[] memory vestingInfo, uint p_saleID, address creator) ERC721("PathFund presalers","PATHlaunched"){
    token = addressInfo[0];
    pair = addressInfo[1];
    router = addressInfo[2];
    pSaleRation = uintInfo[0];
    soft = uintInfo[1];
    hardcap = uintInfo[2];
    minToBuy = uintInfo[3];
    maxToBuy = uintInfo[4];
    liq = uintInfo[5];
    listrate = uintInfo[6];
    start = uintInfo[7];
    endtime = uintInfo[8];
    liqlock = uintInfo[9];
    refundtype = uintInfo[10];
    vesting = boolInfo[0];
    WLenabled = boolInfo[1];
    logoURL = strInfo[0];
    website = strInfo[1];
    facebook = strInfo[2];
    twitter = strInfo[3];
    instagram = strInfo[4];
    discord = strInfo[5];
    reddit = strInfo[6];
    description = strInfo[7];
    auditLink = strInfo[8];
    //vesting info
    vest_1stRelease = vestingInfo[0]; // %
    vest_everyXdays = vestingInfo[1]; 
    vest_tokenEachCycle = vestingInfo[2]; // %
    Launchpad_factory = PathLaunchpadz_factory(fact);
    creatorz = creator;
    idThis = p_saleID;
    createNft(token);
    phase = 1;
    emit PsaleCreated(fact, address(this), creator, p_saleID, block.timestamp);
    }

modifier onlyCreator(){
    require(msg.sender == creatorz, "you are not the presale creator");
    _;
}
function deposit(uint amount) external payable {
    require(userDB[msg.sender].amountDeposit + amount <= maxToBuy, "max buys reached");
    if(phase == 1 && WLenabled){
        if((block.timestamp-start) >=  Launchpad_factory.get_minimumTimeForNextPhase()){
            nextPhase();
        }else{
            require(whiteListP1[msg.sender], "not in WL for Phase1");
        }
    }
    require( start<block.timestamp &&  endtime>block.timestamp &&!finalized && !killed, "presale not started or ended"); // da capi cazzo vo 
    if(pair == bnbA){
        require( msg.value >= minToBuy && msg.value <= maxToBuy, "amount too low or high, deposit limits");
        require(totalContribution+msg.value<= hardcap, "amount too high, HC limit");
        
        // ...

        soldToken+=userDB[msg.sender].total_claimableToken;
        emit Deposited (msg.sender, msg.value);
    }
    else{
        require(amount > minToBuy && amount <= maxToBuy, "amount too low or high, deposit limits");
        require(totalContribution+amount<= hardcap, "amount too high, HC limit");
        
        // ...

        require(BEP20(pair).transferFrom(msg.sender, address(this), amount), "transfer from failed");
        emit Deposited (msg.sender, amount);
    }
    
}
function getFundBack() external {
    uint am_depo = userDB[msg.sender].amountDeposit;
    require((!finalized || !softReached) && am_depo>0, "already finalized or 0");
    if(pair == bnbA){
        
        // ...

        (bool success, ) = payable(msg.sender).call{value: am_depo}("");
        require(success);
    }
    else{
        
        // ...
        
        require(BEP20(pair).transfer(msg.sender, am_depo));
    }
    emit withdrawn(msg.sender, am_depo);

}
function nextPhase() public onlyCreator {
    require( (block.timestamp-start) >=  Launchpad_factory.get_minimumTimeForNextPhase(), "minimumTimeForNextPhase not passed");
    require(phase == 1, "already phase 2");
    phase = 2;
    uint pNum = getPartecipantsNum(); 
    emit NextPhase(pNum, totalContribution);
}
function enable_WL(bool wl) external onlyCreator{
    require(phase == 1);
    WLenabled = wl;
}
function whiteListAccount(address toWL, bool isWL) external onlyCreator{
    require(phase == 1);
    whiteListP1[toWL] = isWL;
}
function whiteListMultipleAccount(address[] memory toWL, bool isWL) external onlyCreator{
    require(phase == 1);
    for(uint i=0; i<toWL.length;i++){
        whiteListP1[toWL[i]] = isWL;
}
    
}
function claim() external { 
    require(finalized && !vesting && softReached, "not finalized or vesting");
    require(_claimed < getPartecipantsNum(), "all claimed");
    require(userDB[msg.sender].claimableToken > 0, "already claimed");
    
    //...

    require(BEP20(token).transfer(msg.sender, temp_amnt));
        
    emit Claimed(msg.sender, temp_amnt);   
    }




function vestiti() external { 
    require(finalized && vesting && softReached, "not finalized or not vesting");
    require(userDB[msg.sender].claimableToken>0, "claimable token 0");
    require(userDB[msg.sender].claimEpoch + vest_everyXdays < block.timestamp, "not yet");
    uint tempAmnt;
    if(!userDB[msg.sender].vest_firstClaim){
        
        //...

        require(BEP20(token).transfer(msg.sender, tempAmnt));
    }else{
        
        //...

        require(BEP20(token).transfer(msg.sender, tempAmnt));
    }
    emit ClaimedVesting(msg.sender, tempAmnt);
}
function finalize() external onlyCreator{
    require(!killed && !finalized, "presale killed");
    if(totalContribution<soft && block.timestamp>=endtime ){
        Launchpad_factory.removeFinalizedIDs(idThis);
        finalized = true;
        softReached = false;
        require(BEP20(token).transfer(creatorz, BEP20(token).balanceOf(address(this))));
        return;
    }
    
    //...

    (bool successzz, ) = payable(feeReciv).call{value: bnbFeePart}("");
    require(successzz);
    if(pair == bnbA){
        BEP20(token).approve(router, tokenToAdd);
        PS_Router(router).addLiquidityETH{value: bnbToAdd}(token, tokenToAdd, 0, 0, address(lockr), block.timestamp+300);
        (bool successz, ) = payable(creatorz).call{value: bnbToOwnr}("");
        require(successz);
    }
    else{
        BEP20(token).approve(router, tokenToAdd);
        BEP20(pair).approve(router, bnbToAdd);
        PS_Router(router).addLiquidity(token, pair, tokenToAdd, bnbToAdd, 0, 0, address(lockr), block.timestamp+300);
        require(BEP20(pair).transfer(creatorz, bnbToOwnr));
    }
    if(refundtype == 1 && leftover>0){
        require(BEP20(token).transfer(dead, leftover));
    }
    else if(refundtype == 2 && leftover>0){
        require(BEP20(token).transfer(creatorz, leftover));
    }
    else if(refundtype>2){
        revert("wrong refund type");
    }

    uint pNum = getPartecipantsNum(); 
    emit Finalized(pNum, totalContribution);
}
    //create single NFT, send to the token contract
function createNft(address to) internal {
    require(!created);
    //...
    created = true;
}
// view
function getPartecipantsNum() public view returns(uint){
    return EnumerableSet.length(partecipant);
}
// set

function set_logoURL(string memory logurl) external onlyCreator {
    logoURL = logurl;
}
function set_websiteL(string memory ws) external onlyCreator {
    website = ws;
}
function set_facebook(string memory fb) external onlyCreator {
    facebook = fb;
}
function set_twitter(string memory twt) external onlyCreator {
    twitter = twt;
}
function set_instagram(string memory ig) external onlyCreator {
    instagram = ig;
}
function set_discord(string memory dsc) external onlyCreator {
    discord = dsc;
}
function set_reddit(string memory rdt) external onlyCreator {
    reddit = rdt;
}
function set_description(string memory desc) external onlyCreator {
    description = desc;
}
function set_auditlink (string memory auditLinkz) external onlyCreator {
        auditLink = auditLinkz;
}
// external
function returnInfoPresale() external view returns(uint,uint,uint,uint,uint,uint,uint){
    return (soft, hardcap, totalContribution, start, endtime, liqlock, liq);

}
function emergency_killPreSale() external {
    require(msg.sender == address(Launchpad_factory) || msg.sender == creatorz, "you are not authorized");
    killed = true;
    Launchpad_factory.removeFinalizedIDs(idThis);
}
receive() external payable {}
}
abstract contract BEP20 {
    function approve(address guy, uint wad) virtual public returns (bool);
    function balanceOf(address tokenowner) virtual external view returns (uint256);
    function transfer(address receiver, uint256 numTokens) virtual public returns (bool);
    function transferFrom(address sender, address recipient, uint256 amount) public virtual returns (bool);

}
interface PS_Router {
    function addLiquidityETH(
    address token,
    uint amountTokenDesired,
    uint amountTokenMin,
    uint amountETHMin,
    address to,
    uint deadline
    ) external payable returns (uint amountToken, uint amountETH, uint liquidity);
    function addLiquidity(
    address tokenA,
    address tokenB,
    uint amountADesired,
    uint amountBDesired,
    uint amountAMin,
    uint amountBMin,
    address to,
    uint deadline
    ) external returns (uint amountA, uint amountB, uint liquidity);
    function factory() external view returns (address);
}
interface factMM {
  function getPair(address tokenA, address tokenB) external view returns (address pair);
  function allPairs(uint) external view returns (address pair);
  function allPairsLength() external view returns (uint);
  function feeTo() external view returns (address);
  function feeToSetter() external view returns (address);
  function createPair(address tokenA, address tokenB) external returns (address pair);
}

interface PathLaunchpadz_factory {
    function set_lockerFromlockedToken(address lpTokenAddress, uint idPsale, address lockerz, address tokenz) external;
    function get_minimumTimeForNextPhase() external view returns(uint);
    function get_pSaleCreationURI() external view returns(string memory);
    function removeFinalizedIDs (uint id) external;
    function getLockSpawnerAdrs() external view returns(address);
    function getFeeBnb() external view returns(uint);
    function createLock(uint liqlock, address creatorz, address pairz) external returns(address);
    function getFeeRec() external view returns(address);
    function getFeeTkn() external view returns(uint);
}
