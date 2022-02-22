//Liquidation Vault

pragma solidity ^0.4.18;
import "./cdp.sol";

contract UDTap is UDThing {
    UDToken     public  stablecoin;
    UDToken     public  sincoin;
    ERC20       public  collateralcoin;
    pricefeed   public  pfc;
    UDTub       public  tub;
    uint256     public  tdc=10**10;
    uint256     public  edc=10**18;  
    // Surplus  
    function joy() public view returns (uint) {
        return stablecoin.balanceOf(this);
    }
    // Bad debt
    function woe() public view returns (uint) {
        return sincoin.balanceOf(this);
    }
    // Collateral pending liquidation
    function EcoinFog() public view returns (uint) {
        return collateralcoin.balanceOf(this);
    }
    // Collateral pending liquidation
    function XDCFog() public view returns (uint) {
        return address(this).balance;
    }

    //constructor function
    function UDTap(UDTub tub_) public {
        tub = tub_;

        stablecoin = tub.stablecoin();
        sincoin = tub.sincoin();
        collateralcoin = tub.collateralcoin();

        pfc = tub.pfc();
    }


     // Cancel debt
    function heal() public note {
        if (joy() == 0 || woe() == 0) return;  // optimised
        uint wad = min(joy(), woe());
        stablecoin.burn(wad);
        sincoin.burn(wad);
    }



    // Boom price (xusd for ecoin) will return amount of xusd for input amount of ecoins
    function bidEcoin(uint ecoins_) public view returns (uint) {
       uint256 noe = div(mul(div(ecoins_, tdc), pfc.getEcoinPrice()), 10**5);
        return noe*edc;
        
    }

     //  price (xusd for xdc) will return amount of xusd for input amount of xdc
    function bidXDC(uint xdc_) public view returns (uint) {
       uint256 noe = div(mul(div(xdc_, edc), pfc.getXDCPrice()), 10**5);
        return noe*edc;
        
    }

    // Bust price (ecoin for xusd)  will return amount of Ecoins for input amount of xusd
    function askForEcoin(uint xusd_) public view returns (uint) {  
        uint odi = div(10**5, pfc.getEcoinPrice());
        uint256 noe = mul(odi, div(xusd_, edc));
        uint nox = noe*tdc;
        return nox;
    }

    // Bust price (xdc for xusd) will return amount of XDC for input amount of xusd
    function askForXDC(uint xusd_) public view returns (uint) {  
        uint odi = div(10**5, pfc.getXDCPrice());
        uint256 noe = mul(odi, div(xusd_, edc));
        uint nox = noe*edc;
        return nox;
    }


    // takes in the stablecoin and gives ecoin
     function flipE(uint xusd_) internal {
        stablecoin.transferFrom(msg.sender, address(this), xusd_);
        uint amtE = askForEcoin(xusd_);
        collateralcoin.transferFrom(address(this), msg.sender, amtE);
        heal();
    }

    // takes in ecoin and give the surplus stablecoin
     function flapE(uint ecoin_) internal {
        uint amtE = bidEcoin(ecoin_);
        stablecoin.transferFrom(address(this), msg.sender, amtE);
        collateralcoin.transferFrom(msg.sender, address(this), ecoin_);
        heal();
    }
     
        // takes in the stablecoin and gives xdc
     function flipX(uint xusd_) internal {
        stablecoin.transferFrom(msg.sender, address(this), xusd_);
        uint amtE = askForXDC(xusd_);
        msg.sender.transfer(amtE);
        heal();
    }

    // takes in xdc and give the surplus stablecoin
     function flapX(uint xdc_) internal  {
        require(msg.value ==xdc_);
        uint amtE = bidXDC(xdc_);

        stablecoin.transferFrom(address(this), msg.sender, amtE);
        heal();
    }


    //take input of number of xusd user want to deposit and get ecoin
    function bustEcoin(uint xusd_) public note {
        flipE(xusd_);
    }
    
    function bustXDC(uint xusd_) public note {
        flipX(xusd_);
    }

     function boomEcoin(uint ecoin_) public note {
        flapE(ecoin_);
    }
    
    function boomXDC(uint xcd_) public note {
        flapX(xcd_);
    }


}

