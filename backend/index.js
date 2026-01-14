const express = require('express');
const cors = require('cors');
const routes = require('./routes'); // Mengimpor rute yang sudah terhubung ke db.js

const app = express();

// 1. Middleware
// CORS sangat penting agar Flutter (Client) bisa mengakses Node.js (Server)
app.use(cors()); 
// Express.json wajib ada agar server bisa membaca body JSON yang dikirim Flutter
app.use(express.json()); 

// 2. Jalur API Utama
// Semua rute di file routes.js akan memiliki awalan /api
app.use('/api', routes); 

// 3. Jalankan Server
const PORT = process.env.PORT || 3000;

// Menggunakan '0.0.0.0' agar bisa diakses oleh Emulator (10.0.2.2) maupun HP Fisik (IP Laptop)
app.listen(PORT, '0.0.0.0', () => {
  console.log(`-----------------------------------------`);
  console.log(`Server InsightMind aktif di port: ${PORT}`);
  console.log(`Base URL: http://localhost:${PORT}/api`);
  console.log(`-----------------------------------------`);
});