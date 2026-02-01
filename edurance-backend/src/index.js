require('dotenv').config();
const express = require('express');
const cors = require('cors');
const app = express();
const port = process.env.PORT || 3000;


app.use(cors());
app.use(express.json());
app.use(express.static('public'));

// Routes
app.use('/auth', require('./routes/auth'));
app.use('/api/generate', require('./routes/generate'));
app.use('/api/solve-image', require('./routes/solve'));


app.listen(port, () => console.log(`Edurance backend listening on ${port}`));
