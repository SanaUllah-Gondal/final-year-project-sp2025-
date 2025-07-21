// Express Route 53
const express = require('express');
const router = express.Router();

router.get('/route53', (req, res) => res.send('Route 53'));

module.exports = router;