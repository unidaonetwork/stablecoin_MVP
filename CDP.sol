pragma solidity ^0.4.18;
contract UDAuthority {
    function canCall(
        address src, address dst, bytes4 sig
    ) public view returns (bool);
}

contract UDAuthEvents {
    event LogSetAuthority (address indexed authority);
    event LogSetOwner     (address indexed owner);
}

contract UDAuth is UDAuthEvents {
    UDAuthority  public  authority;
    address      public  owner;

    function UDAuth() public {
        owner = msg.sender;
        LogSetOwner(msg.sender);
    }

    function setOwner(address owner_)
        public
        auth
    {
        owner = owner_;
        LogSetOwner(owner);
    }

    function setAuthority(UDAuthority authority_)
        public
        auth
    {
        authority = authority_;
        LogSetAuthority(authority);
    }

    modifier auth {
        require(isAuthorized(msg.sender, msg.sig));
        _;
    }

    function isAuthorized(address src, bytes4 sig) internal view returns (bool) {
        if (src == address(this)) {
            return true;
        } else if (src == owner) {
            return true;
        } else if (authority == UDAuthority(0)) {
            return false;
        } else if (authority == src) {
            return true;
        } else {
            return authority.canCall(src, this, sig);
        }
    }
}
contract UDNote {
    event LogNote(
        bytes4   indexed  sig,
        address  indexed  guy,
        bytes32  indexed  foo,
        bytes32  indexed  bar,
        uint              wad,
        bytes             fax
    ) anonymous;

    modifier note {
        bytes32 foo;
        bytes32 bar;

        assembly {
            foo := calldataload(4)
            bar := calldataload(36)
        }

        LogNote(msg.sig, msg.sender, foo, bar, msg.value, msg.data);

        _;
    }
}

contract UDMath {
    function add(uint x, uint y) internal pure returns (uint z) {
        require((z = x + y) >= x);
    }
    function sub(uint x, uint y) internal pure returns (uint z) {
        require((z = x - y) <= x);
    }
    function div(uint x, uint y) internal pure returns (uint z) {
        return((z = x/y));
    }
    function mul(uint x, uint y) internal pure returns (uint z) {
        require(y == 0 || (z = x * y) / y == x);
    }

    function min(uint x, uint y) internal pure returns (uint z) {
        return x <= y ? x : y;
    }
    function max(uint x, uint y) internal pure returns (uint z) {
        return x >= y ? x : y;
    }
    function imin(int x, int y) internal pure returns (int z) {
        return x <= y ? x : y;
    }
    function imax(int x, int y) internal pure returns (int z) {
        return x >= y ? x : y;
    }

    uint constant WAD = 10 ** 18;
    uint constant RAY = 10 ** 27;

    function wmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), WAD / 2) / WAD;
    }
    function rmul(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, y), RAY / 2) / RAY;
    }
    function wdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, WAD), y / 2) / y;
    }
    function rdiv(uint x, uint y) internal pure returns (uint z) {
        z = add(mul(x, RAY), y / 2) / y;
    }

    // This famous algorithm is called "exponentiation by squaring"
    // and calculates x^n with x as fixed-point and n as regular unsigned.
    //
    // It's O(log n), instead of O(n) for naive repeated multiplication.
    //
    // These facts are why it works:
    //
    //  If n is even, then x^n = (x^2)^(n/2).
    //  If n is odd,  then x^n = x * x^(n-1),
    //   and applying the equation for even x gives
    //    x^n = x * (x^2)^((n-1) / 2).
    //
    //  Also, EVM division is flooring and
    //    floor[(n-1) / 2] = floor[n / 2].
    //
    function rpow(uint x, uint n) internal pure returns (uint z) {
        z = n % 2 != 0 ? x : RAY;

        for (n /= 2; n != 0; n /= 2) {
            x = rmul(x, x);

            if (n % 2 != 0) {
                z = rmul(z, x);
            }
        }
    }
}
contract UDThing is UDAuth, UDNote, UDMath {

    function S(string s) internal pure returns (bytes4) {
        return bytes4(keccak256(s));
    }

}
contract UDStop is UDNote, UDAuth {

    bool public stopped;

    modifier stoppable {
        require(!stopped);
        _;
    }
    function stop() public auth note {
        stopped = true;
    }
    function start() public auth note {
        stopped = false;
    }

}
contract ERC20Events {
    event Approval(address indexed src, address indexed guy, uint wad);
    event Transfer(address indexed src, address indexed dst, uint wad);
}

contract ERC20 is ERC20Events {
    function totalSupply() public view returns (uint);
    function balanceOf(address guy) public view returns (uint);
    function allowance(address src, address guy) public view returns (uint);

    function approve(address guy, uint wad) public returns (bool);
    function transfer(address dst, uint wad) public returns (bool);
    function transferFrom(
        address src, address dst, uint wad
    ) public returns (bool);
}

contract UDTokenBase is ERC20, UDMath {
    uint256                                            _supply;
    mapping (address => uint256)                       _balances;
    mapping (address => mapping (address => uint256))  _approvals;

    function UDTokenBase(uint supply) public {
        _balances[msg.sender] = supply;
        _supply = supply;
    }

    function totalSupply() public view returns (uint) {
        return _supply;
    }
    function balanceOf(address src) public view returns (uint) {
        return _balances[src];
    }
    function allowance(address src, address guy) public view returns (uint) {
        return _approvals[src][guy];
    }

    function transfer(address dst, uint wad) public returns (bool) {
        return transferFrom(msg.sender, dst, wad);
    }

    function transferFrom(address src, address dst, uint wad)
        public
        returns (bool)
    {
        if (src != msg.sender) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        Transfer(src, dst, wad);

        return true;
    }

    function approve(address guy, uint wad) public returns (bool) {
        _approvals[msg.sender][guy] = wad;

        Approval(msg.sender, guy, wad);

        return true;
    }
}
    interface IERC20 {
    function totalSupply() external view returns (uint256);

    function balanceOf(address account) external view returns (uint256);

    function transfer(address recipient, uint256 amount) external returns (bool);

    function allowance(address owner, address spender) external view returns (uint256);

    function approve(address spender, uint256 amount) external returns (bool);

    function transferFrom(address sender, address recipient, uint256 amount) external returns (bool);

    event Transfer(address indexed from, address indexed to, uint256 value);

    event Approval(address indexed owner, address indexed spender, uint256 value);
}
contract UDToken is UDTokenBase(0), UDStop {

    string  public  symbol;
    uint256  public  decimals = 18; // standard token precision. override to customize

    function UDToken(string symbol_) public {
        symbol = symbol_;
    }

    event Mint(address indexed guy, uint wad);
    event Burn(address indexed guy, uint wad);

    function approve(address guy) public stoppable returns (bool) {
        return super.approve(guy, uint(-1));
    }

    function approve(address guy, uint wad) public stoppable returns (bool) {
        return super.approve(guy, wad);
    }
    
    function transferFrom(address src, address dst, uint wad)
        public
        stoppable
        returns (bool)
    {
        if (src != msg.sender && _approvals[src][msg.sender] != uint(-1)) {
            _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        }

        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        Transfer(src, dst, wad);

        return true;
    }
    function vaultTransfer(address src, address dst, uint wad)
    public
    returns(bool){
        require( _approvals[src][msg.sender] >= wad);
        _approvals[src][msg.sender] = sub(_approvals[src][msg.sender], wad);
        _balances[src] = sub(_balances[src], wad);
        _balances[dst] = add(_balances[dst], wad);

        Transfer(src, dst, wad);

        return true;
    }
    function push(address dst, uint wad) public {
        transferFrom(msg.sender, dst, wad);
    }
    function pull(address src, uint wad) public {
        transferFrom(src, msg.sender, wad);
    }
    function move(address src, address dst, uint wad) public {
        transferFrom(src, dst, wad);
    }

    function mint(uint wad) public {
        mint(msg.sender, wad);
    }
    function burn(uint wad) public {
        burn(msg.sender, wad);
    }
    function mint(address guy, uint wad) public auth stoppable {
        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        Mint(guy, wad);
    }
     function vaultMint(address guy, uint wad) public auth stoppable {
     /*    address authorityis = authority;
        require(msg.sender == authorityis); */
        _balances[guy] = add(_balances[guy], wad);
        _supply = add(_supply, wad);
        Mint(guy, wad);


    }
     function burnFrom(address guy, uint wad) public {
        require(_approvals[guy][msg.sender]>=wad);
        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        Burn(guy, wad);
    }
    
    
    function burn(address guy, uint wad) public auth stoppable {
        if (guy != msg.sender && _approvals[guy][msg.sender] != uint(-1)) {
            _approvals[guy][msg.sender] = sub(_approvals[guy][msg.sender], wad);
        }

        _balances[guy] = sub(_balances[guy], wad);
        _supply = sub(_supply, wad);
        Burn(guy, wad);
    }

    // Optional token name
    bytes32   public  name = "";

    function setName(bytes32 name_) public auth {
        name = name_;
    }
}


//PriceFeed 

contract pricefeed {
    uint256 public EPrice;
    uint256 public XPrice;
    address public owner;
    address public authority;

   function pricefeed() public {
        owner = msg.sender;
        
    }
 function setEcoinPrice(uint256 price_) public returns(uint256){
     require(msg.sender==authority);
     require(authority!=0x0000000000000000000000000000000000000000);
     EPrice = price_;
    
 }
  function setXDCPrice(uint256 price_) public returns(uint256){
     require(msg.sender==authority);
     require(authority!=0x0000000000000000000000000000000000000000);
     XPrice = price_;
    
 }
 function setAuthority(address auth) public  returns(address){
     require(msg.sender==owner);
     authority = auth;
     return   auth;
 }
 function getEcoinPrice() public view returns(uint256) {
     return EPrice;
 }
 function getXDCPrice() public view returns(uint256) {
     return XPrice;
 }
}


contract UDTubEvents {
    event LogNewCup(address indexed lad, bytes32 cup);
}
contract UDTub is  UDThing, UDTubEvents {
    ERC20                     public  collateralcoin; //collateral coin address
    UDToken                   public  stablecoin;  //stablecoin address
    UDToken                   public  sincoin;  //sincoin address
    UDToken                   public  governcoin; //governance coin address
    pricefeed                 public  pfc; //pricefeed address
    uint256                   public  taxrate; //tax rate /stability
    uint256                   public  cupi; //cup number
    mapping (bytes32 => Cup)  public  cups; //vault number
    uint256                   public  ocr; //over-collaterization ratio
    address                   public  owner; //owner
    address                   public  lqv; //liquidation vault
    address                   public  pit; //token burner address
    uint256                   public  msr; //minimum safety ratio
    uint256                   public  ttd; // total normalised debt tax
    uint256                   public  tdc=10**10;
    uint256                   public  edc=10**18;
struct Cup {
        bytes32  ino; //Number
        address  owner; //lad;      // CDP owner
        uint256  collateralE; //ink;      // Locked collateral (in ecoin)
        uint256  collateralX; //ink;      // Locked collateral (in xdc)
        uint256  tax; //art;      // Outstanding normalised debt (tax only)
        uint256  scm;      // Stablecoin minted in current debt;
        uint256  debt; //debt
            }

    function UDTub(
     
        ERC20  cc_,
        UDToken gov_,
        UDToken  sc_,
        pricefeed pf_,
        address pit_
    ) public {
         owner= msg.sender;
         stablecoin=sc_;
         governcoin = gov_;
         collateralcoin=cc_;
         pfc = pf_;
         pit=pit_;
         ocr=500;
         msr=175;
    }

    
    function SetTaxRate(uint256 rate) public auth  {
        //require(msg.sender==owner);
        taxrate=rate;
    }
    function checkEcoinRate() public view returns(uint256){
            uint256 ecoinprice_ = pfc.getEcoinPrice();
            return(ecoinprice_);

    }

     function checkXDCRate() public view returns(uint256){
            uint256 xdcprice_ = pfc.getXDCPrice();
            return(xdcprice_);

    }
    // Function to set over-collaterized ratio and minimum ratio
    function setOCR(uint ocr_) public auth {
        //require(msg.sender==owner);
        ocr= ocr_;
    }
     function setMSR(uint msr_) public auth {
       // require(msg.sender==owner);
        msr= msr_;
    }



    function open() public  returns (bytes32 cup) {
        require (cupNoOf(msg.sender) == 0);
        cupi = (cupi+ 1);
        cup = bytes32(cupi);
        cups[cup].ino = cup;
        cups[cup].owner = msg.sender;
        LogNewCup(msg.sender, cup);
    }



    function ownerOf(bytes32 cup) public view returns (address) {
        return cups[cup].owner;
    }



     function collateralEOf(bytes32 cup) public view returns (uint) {
        return cups[cup].collateralE;
    }
     function collateralXOf(bytes32 cup) public view returns (uint) {
        return cups[cup].collateralX;
    }



     function taxcalc(bytes32 cup) public view returns (uint) {
        uint ppl =cups[cup].scm;
        uint rate = taxrate;
        uint tax = ppl*rate/100;
        return tax;
    }
   








    //Returns stable amount allowed for given amount of ecoin
    function sAmountforEcoin(uint256 amount_) public view returns(uint256){
         uint256 ecoinrate = checkEcoinRate();
        uint256 value = mul(div(amount_, tdc), ecoinrate)*10**15; 
        uint amountallowed= value/ocr;
        uint newamount= (amountallowed); 
        return(newamount);

    } 

    //Returns stable amount allowed for given amount of xdc
    function sAmountforXDC(uint256 amount_) public view returns(uint256){
        uint256 XDCrate = checkXDCRate();
        uint256 value = mul(div(amount_, edc), XDCrate)*10**15; 
        uint amountallowed= value/ocr;
        uint newamount= (amountallowed); 
        return(newamount);

    } 







    /* 
     function to deposit ecoin and mint stablecoin
     */

    function depositEcoin(bytes32 cup, uint amount_) public note {
        require(safeCheck(cup)==true);
        
        cups[cup].collateralE = add(cups[cup].collateralE, amount_);
                
        collateralcoin.transferFrom(msg.sender, address(this), amount_);
        uint amountallowed= sAmountforEcoin(amount_);
        stablecoin.vaultMint(msg.sender, amountallowed);
        uint amountAdd = amountallowed;
        cups[cup].scm = add(cups[cup].scm, amountAdd);
        cups[cup].debt = add(cups[cup].debt, amountAdd);
        uint256 taxdebt = taxcalc(cup);
        cups[cup].tax = taxdebt;
        ttd = add(ttd, taxdebt);


    }

    function checkXDCbalcance()public view returns(uint){
        return(address(this).balance);
    }
/* 
    function to deposit XDC and mint stablecoin

     */
    function depositXDC(bytes32 cup, uint amount_) public payable note {
        require(safeCheck(cup)==true);
        require(msg.value==amount_);

        cups[cup].collateralX = add(cups[cup].collateralX, amount_);
        
        
    
        uint amountallowed= sAmountforXDC(amount_);
        stablecoin.vaultMint(msg.sender, amountallowed);
        uint amountAdd = amountallowed;
        cups[cup].scm = add(cups[cup].scm, amountAdd);
        cups[cup].debt = add(cups[cup].debt, amountAdd);
        uint256 taxdebt = taxcalc(cup);
        cups[cup].tax = taxdebt;
        ttd = add(ttd, taxdebt);


    }


    //function to deposit full or partial debt
    function payBack(bytes32 cup_, uint256 USDX_Amt ) public {
        require(safeCheck(cup_)==true);
        require(cups[cup_].owner==msg.sender);
        require(USDX_Amt<=cups[cup_].debt);
        uint256 amtTrans = USDX_Amt;
        uint256 amtAdd = amtTrans;
        stablecoin.burnFrom(msg.sender, amtTrans );
        cups[cup_].debt = cups[cup_].debt - amtAdd;

    }
 



/* 
    function to wipe debt and pay the tax
    burn the debt amount of stablecoin from cup owner (msg.sender)
    transfer the amount of tax in the form of governance coin and send 
    it to the token burner
 */
    function wipeVault(bytes32 cup_) public {
        require(safeCheck(cup_)==true);
        require(cups[cup_].owner==msg.sender);
        require(stablecoin.balanceOf(msg.sender)>=cups[cup_].debt);
        require(governcoin.balanceOf(msg.sender)>=cups[cup_].tax);
        uint debt = cups[cup_].debt;
        uint tax = cups[cup_].tax;
        ttd =sub(ttd, tax );

        stablecoin.burnFrom(msg.sender, debt);
        governcoin.transferFrom(msg.sender, pit, tax);
        
        cups[cup_].tax= 0;
        cups[cup_].scm= 0;
        cups[cup_].debt = 0;
    }


    //function to transfer back the collateral if no debt is present

     function freeEcoins(bytes32 cup_) public {
        require(safeCheck(cup_)==true);
        require(msg.sender == cups[cup_].owner);
        require(cups[cup_].debt == 0);
        require(cups[cup_].tax == 0);

       
        collateralcoin.transferFrom(address(this), msg.sender, cups[cup_].collateralE);
        cups[cup_].collateralE =0;
    }

    //function to transfer back the collateral if no debt is present

    function freeXDC(bytes32 cup_) public {
        require(safeCheck(cup_)==true);
        require(msg.sender == cups[cup_].owner);
        require(cups[cup_].debt == 0);
        require(cups[cup_].tax == 0);
     
        uint refamt = cups[cup_].collateralX;
        msg.sender.transfer(refamt);
        cups[cup_].collateralX =0;
    }

    
    function StablecoinBalance() public view returns (uint) {
        uint bal= stablecoin.balanceOf(msg.sender);
        return bal;
    }
    





    // Function returns value with minimum safety ratio for an amount of Ecoin 
   
    function mAmount(uint amount_ )  public view returns(uint){
        uint256 ecoinrate = checkEcoinRate();
    
        uint256 value = mul(div(amount_, tdc), ecoinrate)*10**15;  
        uint amountallowed= value/msr;
        uint newamount= (amountallowed);
            
            return(newamount);
    }


    // Function returns value with minimum safety ratio for an amount of XDC 

    function mAmountX(uint amount_ )  public view returns(uint){
        uint256 xdcrate = checkXDCRate();
    
        uint256 value = mul(div(amount_, edc), xdcrate)*10**15;  
        uint amountallowed= value/msr;
        uint newamount= (amountallowed);
            
            return(newamount);
    }







    //Function to check whether cup is safe or not

    function safeCheck(bytes32 cup_) public view returns(bool){
        uint256 debt = cups[cup_].debt;
 
       
            uint256 dc = cups[cup_].collateralE;
            uint256 sa = mAmount(dc);
      
            uint256 dc1 = cups[cup_].collateralX;
            uint256 sa1 = mAmountX(dc1);
        
            uint256 tma = sa+sa1;

            if(tma<debt){
                return false;
            }else if (tma>=debt){
                return true;
            }
                           
    }

    



    //returns cup number of msg.sender
    function cupNo() public view returns(bytes32) {
        uint256 qua = cupi;
        for (uint256 i = 0 ; i <= qua ; i++) {
            address own = cups[bytes32(i)].owner;
            if (own==msg.sender) {
              bytes32 sno = cups[bytes32(i)].ino;
               return(sno);
            }
        }
    }




    //retuns cup number of given address
    function cupNoOf(address add) public view returns (bytes32) {
        uint256 qua = cupi;
        for (uint256 i = 0 ; i <= qua ; i++) {
            address own = cups[bytes32(i)].owner;
            if (own==add) {
              bytes32 sno = cups[bytes32(i)].ino;
               return(sno);
            }
        }
    }


    //fucntion to seize the collateral
    function grabCollateral(bytes32 cup) public note {
        require(safeCheck(cup)==false);

    // Take on all of the debt

        sincoin.mint(lqv, cups[cup].debt);
        ttd = sub(ttd, cups[cup].tax);
        cups[cup].tax = 0;
        cups[cup].debt = 0;
        cups[cup].scm = 0;
     
     //amount owed      
        uint256 amtX = cups[cup].collateralX;
        uint256 amtE = cups[cup].collateralE;
        
        lqv.transfer(amtX);
        collateralcoin.transferFrom(address(this), lqv, amtE);
        cups[cup].collateralX = 0;
        cups[cup].collateralE = 0;

    }


  


}