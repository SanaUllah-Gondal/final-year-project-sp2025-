const express = require('express');
const router = express.Router();

router.post('/login', (req, res) => {
  res.send('Login endpoint');
});

module.exports = router;