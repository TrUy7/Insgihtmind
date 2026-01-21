const admin = require('firebase-admin');
const serviceAccount = require("./serviceAccountKey.json");

// Inisialisasi SDK sekali saja
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount)
});

const db = admin.firestore();

console.log("-----------------------------------------");
console.log("Firebase Admin SDK Berhasil Terhubung!");
console.log("-----------------------------------------");

module.exports = db;