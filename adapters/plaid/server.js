const express = require('express');
const bodyParser = require('body-parser');
const adapter = require('./index');

require ('dotenv').config();

const app = express();
app.use(bodyParser.json());

app.post('/', function (req, res) {
    adapter.PlaidAdapter(req, res);
});

let listener = app.listen(process.env.PORT || 6222, function () {
    console.log("Plaid adapter listening on", listener.address().address + listener.address().port);
});

process.on('SIGINT', function () {
    process.exit();
});
