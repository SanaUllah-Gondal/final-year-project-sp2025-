// Express Route 65
const express = require('express');
const router = express.Router();

router.get('/route65', (req, res) => res.send('Route 65'));

module.exports = router;