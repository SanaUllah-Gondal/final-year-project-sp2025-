// Express Route 7
const express = require('express');
const router = express.Router();

router.get('/route7', (req, res) => res.send('Route 7'));

module.exports = router;