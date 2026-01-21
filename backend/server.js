const express = require('express');
const cors = require('cors');
const routes = require('./routes');

const app = express();

// Middleware
app.use(cors()); 
app.use(express.json());

// Jalur API Utama
app.use('/api', routes);

// Jalankan Server
const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server Backend InsightMind aktif di port ${PORT}`);
  console.log(`Cek API History di: http://localhost:${PORT}/api/history`);
});