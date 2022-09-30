// SPDX-License-Identifier: KK
pragma solidity 0.8.13;
import "@openzeppelin/contracts/access/Ownable.sol";

contract KINGPAD_infoGetter is Ownable{
    address factoryAdrs;

    constructor(address fact){
        factoryAdrs = fact;
    }


struct wallOfInfo{
    address  tokenz;
    address  pairs;
    address  routerz;
    address  addrsLockerz;
    address  pairzz;

    uint  phasez;
    uint  totalContributionz;
    uint  pSaleRationz;
    uint  softz;
    uint  hardcapz;
    uint  minToBuyz;
    uint  maxToBuyz;
    uint  liqz;
    uint  listratez;
    uint  startz;
    uint  endtimez;
    uint  liqlockz;
    uint  refundtypez;
    uint vest_1stReleasez;
    uint vest_everyXdaysz;
    uint vest_tokenEachCyclez;
    uint councilVotez;

    bool  vestingz ;
    bool  finalizedz;
    bool  killedz;

    string  logoURLz;
    string  websitez;
    string  facebookz;
    string  twitterz;
    string  instagramz;
    string  discordz;
    string  redditz;
    string  descriptionz;
    string auditLinkz;
}
    function retunInfos(address psaleAdrsz) external view returns( wallOfInfo memory){
        wallOfInfo memory tempStruct;

        tempStruct.tokenz = spawned(psaleAdrsz).token();
        tempStruct.pairs = spawned(psaleAdrsz).pair();
        tempStruct.routerz = spawned(psaleAdrsz).router();
        tempStruct.addrsLockerz = spawned(psaleAdrsz).addrsLocker();
        tempStruct.pairzz = spawned(psaleAdrsz).pairz();

        tempStruct.phasez=spawned(psaleAdrsz).phase();
        tempStruct.totalContributionz=spawned(psaleAdrsz).totalContribution();
        tempStruct.pSaleRationz=spawned(psaleAdrsz).pSaleRation();
        tempStruct.softz=spawned(psaleAdrsz).soft();
        tempStruct.hardcapz=spawned(psaleAdrsz).hardcap();
        tempStruct.minToBuyz=spawned(psaleAdrsz).minToBuy();
        tempStruct.maxToBuyz=spawned(psaleAdrsz).maxToBuy();
        tempStruct.liqz=spawned(psaleAdrsz).liq();
        tempStruct.listratez=spawned(psaleAdrsz).listrate();
        tempStruct.startz=spawned(psaleAdrsz).start();
        tempStruct.endtimez=spawned(psaleAdrsz).endtime();
        tempStruct.liqlockz=spawned(psaleAdrsz).liqlock();
        tempStruct.refundtypez =spawned(psaleAdrsz).refundtype();
        tempStruct.vest_1stReleasez =spawned(psaleAdrsz).vest_1stRelease();
        tempStruct.vest_everyXdaysz =spawned(psaleAdrsz).vest_everyXdays();
        tempStruct.vest_tokenEachCyclez =spawned(psaleAdrsz).vest_tokenEachCycle();


        tempStruct.vestingz = spawned(psaleAdrsz).vesting();
        tempStruct.finalizedz = spawned(psaleAdrsz).finalized();
        tempStruct.killedz = spawned(psaleAdrsz).killed();

        tempStruct.logoURLz = spawned(psaleAdrsz).logoURL();
        tempStruct.websitez = spawned(psaleAdrsz).website();
        tempStruct.facebookz = spawned(psaleAdrsz).facebook();
        tempStruct.twitterz = spawned(psaleAdrsz).twitter();
        tempStruct.instagramz = spawned(psaleAdrsz).instagram();
        tempStruct.discordz = spawned(psaleAdrsz).discord();
        tempStruct.redditz = spawned(psaleAdrsz).reddit();
        tempStruct.descriptionz = spawned(psaleAdrsz).description();
        tempStruct.auditLinkz = spawned(psaleAdrsz).auditLink();


        return tempStruct;

    }
}

interface factortz {
    function owner() external view returns (address);
}

interface spawned {

    function token() external view returns (address);
    function pair() external view returns (address);
    function router() external view returns (address);
    function addrsLocker() external view returns (address);
    function pairz() external view returns (address);

    function phase() external view returns (uint);
    function totalContribution() external view returns (uint);
    function pSaleRation() external view returns (uint);
    function soft() external view returns (uint);
    function hardcap() external view returns (uint);
    function minToBuy() external view returns (uint);
    function maxToBuy() external view returns (uint);
    function liq() external view returns (uint);
    function listrate() external view returns (uint);
    function start() external view returns (uint);
    function endtime() external view returns (uint);
    function liqlock() external view returns (uint);
    function refundtype() external view returns (uint);
    function vest_1stRelease() external view returns (uint);
    function vest_everyXdays() external view returns (uint);
    function vest_tokenEachCycle() external view returns (uint);

    function vesting() external view returns (bool);
    function finalized() external view returns (bool);
    function killed() external view returns (bool);

    function logoURL() external view returns (string memory);
    function website() external view returns (string memory);
    function facebook() external view returns (string memory);
    function twitter() external view returns (string memory);
    function instagram() external view returns (string memory);
    function discord() external view returns (string memory);
    function reddit() external view returns (string memory);
    function description() external view returns (string memory);
    function auditLink() external view returns (string memory);

}