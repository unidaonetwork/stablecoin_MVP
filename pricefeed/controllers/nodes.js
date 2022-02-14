


const Web3 = require('web3');
const axios = require('axios')


const finalcontract= require('../contract/contractabi.json')
const finalcontractabi=finalcontract.abi;

//paste your contract address here
const contractaddress='0xccd47446B3698Ee0f9E7E331f5653a206696B179'

const address ='0x7803e84ebd1737c3e0bd2403bd617e0dfc5fb089'
const privatekey = "";    //give the private Key of this account
console.log(privatekey);
const xdcurl='https://rpc.apothem.network'

const token={  
   
  //to set a beneficiary
  setEcoinPrice: async (req, res) => {
        console.log("check1");
      
      
        try {
            const apiurl = "https://api.probit.com/api/exchange/v1/ticker?market_ids=ECOIN-USDT";
            var priceraw;
            
            axios.get(apiurl)
            .then(res=>  {const price3=res.data.data[0].last.replace(".", ""); console.log(price3), priceraw= price3})
        
            .catch(err=>{console.log( err)})
           // const price= priceraw;
            //console.log(price);
     
            const web3= new Web3(xdcurl);
            const networkId = await web3.eth.net.getId();
            const tetherToken = await new web3.eth.Contract(
              finalcontractabi,
              contractaddress

         );
         console.log("main");
         console.log(priceraw)
   const setprice= await tetherToken.methods.setEcoinPrice(priceraw)
             const gas= await setprice.estimateGas({from:address})
             const data=setprice.encodeABI();
             console.log("check4");
             const nonce= await web3.eth.getTransactionCount(address)
             const signedTx = await web3.eth.accounts.signTransaction({
                      to:tetherToken.options.address,
                      data,
                      gas,
                      nonce:nonce,
                      chainId:networkId
                },privatekey
                )
             console.log("check 5");
             console.log(priceraw)
             const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction)
             console.log(receipt,"transaction receipt");
             if(receipt.status==true){
                   return res.json({msg: `transaction sucess! Hash :${receipt.transactionHash}`})
               }
          res.status(400).json({msg: `error:${receipt.transactionHash}`})
      } catch (err) {
          return res.status(500).json({msg: err.message})
      }
    },


    setXDCPrice: async (req, res) => {
        console.log("check1");
      
      
        try {
            const apiurl = "https://api.probit.com/api/exchange/v1/ticker?market_ids=XDC-USDT";
            var priceraw;
            
            axios.get(apiurl)
            .then(res=>  {const price3=res.data.data[0].last.replace(".", ""); console.log(price3), priceraw= price3})
        
            .catch(err=>{console.log( err)})
           // const price= priceraw;
            //console.log(price);
      setTimeout(() => {
          console.log(priceraw);
      }, 5000);
            const web3= new Web3(xdcurl);
            const networkId = await web3.eth.net.getId();
            const tetherToken = await new web3.eth.Contract(
              finalcontractabi,
              contractaddress

         );
   const setprice= await tetherToken.methods.setXDCPrice(priceraw)
             const gas= await setprice.estimateGas({from:address})
             const data=setprice.encodeABI();
             console.log("check4");
             const nonce= await web3.eth.getTransactionCount(address)
             const signedTx = await web3.eth.accounts.signTransaction({
                      to:tetherToken.options.address,
                      data,
                      gas,
                      nonce:nonce,
                      chainId:networkId
                },privatekey
                )
             console.log("check 5");
             console.log(priceraw)
             const receipt = await web3.eth.sendSignedTransaction(signedTx.rawTransaction)
             console.log(receipt,"transaction receipt");
             if(receipt.status==true){
                   return res.json({msg: `transaction sucess! Hash :${receipt.transactionHash}`})
               }
          res.status(400).json({msg: `error:${receipt.transactionHash}`})
      } catch (err) {
          return res.status(500).json({msg: err.message})
      }
    },



    getEcoinPrice: async (req, res) => {
	    console.log("check1");
    
      
        try {
            const web3= new Web3(xdcurl);
            const networkId = await web3.eth.net.getId();
            const tetherToken = await new web3.eth.Contract(
              finalcontractabi,
              contractaddress
         );
const getprice = await tetherToken.methods.getEcoinPrice().call();
            return res.status(200).json({msg:getprice})
   } catch (err) {
            return res.status(500).json({msg: err.message})
    }		 
	},


    getXDCPrice: async (req, res) => {
	    console.log("check1");
    
      
        try {
            const web3= new Web3(xdcurl);
            const networkId = await web3.eth.net.getId();
            const tetherToken = await new web3.eth.Contract(
              finalcontractabi,
              contractaddress
         );
const getprice = await tetherToken.methods.getXDCPrice().call();
            return res.status(200).json({msg:getprice})
   } catch (err) {
            return res.status(500).json({msg: err.message})
    }		 
	},

}
    


module.exports = token;