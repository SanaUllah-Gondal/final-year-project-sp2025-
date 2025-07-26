const express = require('express');
const app = express();
app.get('/', (req, res) => res.send('SkillLink API'));
app.listen(3000);