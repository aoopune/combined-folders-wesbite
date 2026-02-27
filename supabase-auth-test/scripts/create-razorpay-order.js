#!/usr/bin/env node
/**
 * Create a Razorpay order and print the order_id for use on test-both.html.
 *
 * Get your keys from: https://dashboard.razorpay.com/app/keys (use TEST keys).
 *
 * Run from supabase-auth-test folder (PowerShell):
 *   $env:RAZORPAY_KEY_ID="rzp_test_xxxx"
 *   $env:RAZORPAY_KEY_SECRET="your_secret"
 *   node scripts/create-razorpay-order.js
 */
var https = require('https');

var keyId = process.env.RAZORPAY_KEY_ID;
var keySecret = process.env.RAZORPAY_KEY_SECRET;
var amount = parseInt(process.env.RAZORPAY_AMOUNT || '100', 10);

if (!keyId || !keySecret) {
  console.error('Set RAZORPAY_KEY_ID and RAZORPAY_KEY_SECRET (use TEST keys from dashboard.razorpay.com/app/keys).');
  process.exit(1);
}

var body = JSON.stringify({
  amount: amount,
  currency: 'INR',
  receipt: 'rcpt_test_' + Date.now()
});

var auth = Buffer.from(keyId + ':' + keySecret).toString('base64');

var req = https.request({
  hostname: 'api.razorpay.com',
  path: '/v1/orders',
  method: 'POST',
  headers: {
    'Content-Type': 'application/json',
    'Authorization': 'Basic ' + auth,
    'Content-Length': Buffer.byteLength(body)
  }
}, function (res) {
  var chunks = [];
  res.on('data', function (c) { chunks.push(c); });
  res.on('end', function () {
    var data = JSON.parse(Buffer.concat(chunks).toString());
    if (data.id) {
      console.log('Order created. Paste this Order ID on test-both.html:\n');
      console.log(data.id);
      console.log('');
    } else {
      console.error('Error:', data.error || data);
      process.exit(1);
    }
  });
});

req.on('error', function (err) {
  console.error('Request failed:', err.message);
  process.exit(1);
});
req.write(body);
req.end();
