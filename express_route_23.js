// Express Route 23
const express = require('express');
const router = express.Router();

router.get('/route23', (req, res) => res.send('Route 23'));

module.exports = router;