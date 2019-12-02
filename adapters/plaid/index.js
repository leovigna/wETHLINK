require('babel-polyfill');

require('dotenv').config();

const request = require('request');
const envvar = require('envvar');

const PLAID_CLIENT_ID = envvar.string('PLAID_CLIENT_ID');
const PLAID_SECRET = envvar.string('PLAID_SECRET');
const PLAID_PUBLIC_KEY = envvar.string('PLAID_PUBLIC_KEY');
const PLAID_ENV = envvar.string('PLAID_ENV', 'sandbox');
let PLAID_URL;

if (PLAID_ENV == 'sandbox') { PLAID_URL = "https://sandbox.plaid.com" }
else if (PLAID_ENV == 'development') { PLAID_URL = "https://development.plaid.com" }
else if (PLAID_ENV == 'production') { PLAID_URL = "https://production.plaid.com" }
else { PLAID_URL = "https://sandbox.plaid.com" }

const localStore = {};
 
exports.PlaidAdapter = (req, res) => {
    const baseUrl = PLAID_URL;
    const extPath = req.body.data.extPath || ""; // Plaid API endpoint (similar to HTTPGet adapter)
    const url = new URL(extPath, baseUrl);
 
    const public_key = req.body.public_key || ""; // Request public key
    const requestBody = req.body.data.body || {}; // Plaid request body (similar to HTTPGet adapter)
    requestBody.secret = PLAID_SECRET;
    requestBody.client_id = PLAID_CLIENT_ID;

    if (url.toString().indexOf("test") != -1) {
        let returnData = {
            jobRunID: req.body.id,
            data: { test: true, success: true }
        };
        res.status(200).send(returnData);
        return;
    }

    if (url.toString().indexOf("/item/public_token/exchange") != -1) {
        const public_token = requestBody.public_token;
        if (!public_token) {
            let errorData = {
                jobRunID: req.body.id,
                status: "errored",
                error: { "message": "Missing public_token for /item/public_token/exchange"}
            };
            res.status(500).send(errorData);
            return;
        }

        // Requires public_token in body
        request.post(options, (error, response, body) => {
            if (error || response.statusCode >= 400) {
                let errorData = {
                    jobRunID: req.body.id,
                    status: "errored",
                    error: body
                };
                res.status(response.statusCode).send(errorData);
            } else {
                const access_token = response.access_token;
                const item_id = response.item_id;
                if (!localStore[public_key]) { localStore[public_key] = {}; }
                localStore[public_key][item_id] = { item_id, access_token };

                let returnData = {
                    jobRunID: req.body.id,
                    data: { public_key: public_key, success: true } // Do not return access code
                };
                res.status(response.statusCode).send(returnData);
            }
        })
    } else {
        const user = localStore[public_key];
        if (!user) {
            let errorData = {
                jobRunID: req.body.id,
                status: "errored",
                error: { "message": `Missing data for public_key: ${public_key}`}
            };
            res.status(500).send(errorData);
            return;
        }
        
        const { item_id, access_token } = Object.values(user)[0];
        if (!access_token) {
            let errorData = {
                jobRunID: req.body.id,
                status: "errored",
                error: { "message": `Missing access_token for public_key: ${public_key}`}
            };
            res.status(500).send(errorData);
            return;
        }

        requestBody.access_token = access_token;
        const options = {
            url: url,
            json: requestBody
        };

        request.post(options, (error, response, body) => {
            if (error || response.statusCode >= 400) {
                let errorData = {
                    jobRunID: req.body.id,
                    status: "errored",
                    error: body
                };
                res.status(response.statusCode).send(errorData);
            } else {
                let returnData = {
                    jobRunID: req.body.id,
                    data: body
                };
                res.status(response.statusCode).send(returnData);
            }
        });

    }
};