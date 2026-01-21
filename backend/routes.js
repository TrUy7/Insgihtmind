const express = require('express');
const router = express.Router();
const db = require('./db');
const admin = require('firebase-admin');

/**
 * MIDDLEWARE: Verifikasi Token Firebase
 * Memastikan setiap request memiliki token yang valid dari aplikasi Flutter.
 */
const verifyToken = async (req, res, next) => {
    console.log(`[${new Date().toLocaleString()}] Request: ${req.method} ${req.originalUrl}`);
    const idToken = req.headers.authorization?.split('Bearer ')[1];
    
    if (!idToken) {
        console.log("Request ditolak: Token tidak ditemukan");
        return res.status(401).json({ message: "Akses ditolak: Tidak ada token." });
    }

    try {
        const decodedToken = await admin.auth().verifyIdToken(idToken);
        req.user = decodedToken; 
        console.log(`Token Valid. UID User: ${req.user.uid}`);
        next();
    } catch (error) {
        console.log("Token Salah:", error.message);
        res.status(401).json({ message: "Sesi tidak valid." });
    }
};

// --- 1. ENDPOINT REGISTER ---
router.post('/register', async (req, res) => {
    try {
        const { uid, name, email } = req.body;
        await db.collection('users').doc(uid).set({
            name, email,
            createdAt: admin.firestore.FieldValue.serverTimestamp()
        });
        console.log(`Profile created for: ${email}`);
        res.status(201).json({ message: "Profil user berhasil dibuat" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// --- 2. ENDPOINT SCREENING HISTORY ---

// POST: Simpan hasil screening ke tabel global
router.post('/history', verifyToken, async (req, res) => {
    try {
        const data = req.body;
        const uid = req.user.uid;

        await db.collection('history').doc(data.id).set({
            ...data,
            userId: uid, // Penanda kepemilikan data
            date: data.date ? new Date(data.date) : new Date(),
            serverTimestamp: admin.firestore.FieldValue.serverTimestamp()
        });

        console.log(`History ${data.testType} tersimpan untuk UID: ${uid}`);
        res.status(201).json({ message: "Riwayat berhasil disimpan!" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// GET: Ambil semua riwayat milik user
router.get('/history', verifyToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        const snapshot = await db.collection('history')
            .where('userId', '==', uid)
            .get();

        const history = snapshot.docs.map(doc => doc.data());
        console.log(`Mengirim ${history.length} data history ke UID: ${uid}`);
        res.status(200).json(history);
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE: Hapus satu riwayat screening
router.delete('/history/:id', verifyToken, async (req, res) => {
    try {
        const historyId = req.params.id;
        const uid = req.user.uid;
        const docRef = db.collection('history').doc(historyId);
        const doc = await docRef.get();

        if (!doc.exists) return res.status(404).json({ error: "Data tidak ditemukan" });
        if (doc.data().userId !== uid) return res.status(403).json({ error: "Akses ditolak" });

        await docRef.delete();
        res.status(200).json({ message: "Riwayat berhasil dihapus" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE ALL: Hapus semua riwayat screening user ini
router.delete('/history/all', verifyToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        const batch = db.batch();
        const snapshot = await db.collection('history').where('userId', '==', uid).get();

        snapshot.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
        res.status(200).json({ message: "Seluruh riwayat screening dihapus" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// --- 3. ENDPOINT DAILY JOURNAL ---

// POST: Simpan Jurnal
router.post('/journal', verifyToken, async (req, res) => {
    try {
        const { id, content, mood, date } = req.body;
        const uid = req.user.uid;

        await db.collection('journal').doc(id).set({
            id,
            userId: uid,
            content,
            mood,
            date: new Date(date),
            serverTimestamp: admin.firestore.FieldValue.serverTimestamp()
        });

        console.log(`Jurnal tersimpan untuk UID: ${uid}`);
        res.status(201).json({ message: "Jurnal tersimpan!" });
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// GET: Ambil Jurnal
router.get('/journal', verifyToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        const snapshot = await db.collection('journal')
            .where('userId', '==', uid)
            .get();

        const journals = snapshot.docs.map(doc => doc.data());
        res.status(200).json(journals);
    } catch (e) {
        res.status(500).json({ error: e.message });
    }
});

// DELETE: Hapus satu jurnal
router.delete('/journal/:id', verifyToken, async (req, res) => {
    try {
        const docId = req.params.id;
        const docRef = db.collection('journal').doc(docId);
        const doc = await docRef.get();

        if (!doc.exists) return res.status(404).json({ error: "Data tidak ditemukan" });
        if (doc.data().userId !== req.user.uid) return res.status(403).json({ error: "Akses ditolak" });

        await docRef.delete();
        res.status(200).json({ message: "Jurnal dihapus" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE ALL: Hapus semua jurnal user ini
router.delete('/journal/all', verifyToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        const batch = db.batch();
        // DIPERBAIKI: Mencari di koleksi global 'journal' berdasarkan userId
        const snapshot = await db.collection('journal').where('userId', '==', uid).get();

        snapshot.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
        console.log(`Seluruh jurnal UID ${uid} telah dihapus.`);
        res.status(200).json({ message: "Seluruh jurnal dihapus" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

module.exports = router;