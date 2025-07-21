// Express Route 25
const express = require('express');
const router = express.Router();

router.get('/route25', (req, res) => res.send('Route 25'));

module.exports = router;