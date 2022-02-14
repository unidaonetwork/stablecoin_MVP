require('./cronjobs')
require('dotenv').config()
const express = require('express')
const app = express()
app.use(express.json())

//Routes
app.use('/user', require('./routes/routes.js'))

//cronjobs

const PORT = process.env.PORT || 5000
app.listen(PORT, () => {
    console.log('Server is running on port', PORT)
})
