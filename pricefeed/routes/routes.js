const router = require('express').Router()
const token =require('../controllers/nodes.js')
router.get('/setecoinprice',token.setEcoinPrice)
router.get('/getecoinprice',token.getEcoinPrice)
router.get('/setxdcprice',token.setXDCPrice)
router.get('/getxdcprice',token.getXDCPrice)
module.exports = router;

