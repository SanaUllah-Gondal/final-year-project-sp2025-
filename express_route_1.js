// Express Route 1
const express = require('express');
const router = express.Router();

router.get('/route1', (req, res) => res.send('Route 1'));

module.exports = router;