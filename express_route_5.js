// Express Route 5
const express = require('express');
const router = express.Router();

router.get('/route5', (req, res) => res.send('Route 5'));

module.exports = router;