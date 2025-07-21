// Express Route 91
const express = require('express');
const router = express.Router();

router.get('/route91', (req, res) => res.send('Route 91'));

module.exports = router;