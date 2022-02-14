const fetch = require('node-fetch');
const cron = require('node-cron');
const axios = require('axios');

cron.schedule("*/100 * * * * *", function() {
    async function rnow10() {
        const apiurl = 'http://localhost:5000/user/setecoinprice';
        const apiurl2 = 'http://localhost:5000/user/setxdcprice';

            var response = await fetch(apiurl);
            var response2 = await fetch(apiurl2);
            var data = await response.json();
            var data2 = await response2.json();
            console.log(data, data2)
            var { msg } = data;
            console.log(msg)
        }
    
        rnow10();
        
        console.log('task completed once')
  
}
)