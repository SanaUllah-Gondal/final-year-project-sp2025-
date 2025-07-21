// Express Route 41
const express = require('express');
const router = express.Router();

router.get('/route41', (req, res) => res.send('Route 41'));

module.exports = router;