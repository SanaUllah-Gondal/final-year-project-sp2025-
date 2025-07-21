// Express Route 95
const express = require('express');
const router = express.Router();

router.get('/route95', (req, res) => res.send('Route 95'));

module.exports = router;