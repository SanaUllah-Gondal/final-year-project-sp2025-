// Express Route 11
const express = require('express');
const router = express.Router();

router.get('/route11', (req, res) => res.send('Route 11'));

module.exports = router;