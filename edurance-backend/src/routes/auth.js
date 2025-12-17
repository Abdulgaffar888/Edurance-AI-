const express = require('express');
const router = express.Router();

router.get('/', (req, res) => {
  res.json({ status: 'Auth API working' });
});

module.exports = router;

