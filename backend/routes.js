const express = require('express');
const router = express.Router();
const db = require('./db');

// --- ENDPOINT HISTORY ---

// GET: Ambil Semua Riwayat
router.get('/history', async (req, res) => {
    try {
        const snapshot = await db.collection('history').orderBy('date', 'desc').get();
        const results = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.status(200).json(results);
    } catch (error) {
        res.status(500).json({ message: "Gagal ambil data", error: error.message });
    }
});

// POST: Simpan Riwayat Screening Baru
router.post('/history', async (req, res) => {
    console.log("Data History Masuk:", req.body); // Cek log ini di terminal laptop!
    try {
        const data = req.body;

        if (!data.id) {
            return res.status(400).json({ message: "ID Riwayat diperlukan" });
        }

        // Simpan seluruh body sekaligus agar tidak ada data yang tertinggal
        await db.collection('history').doc(data.id).set({
            ...data,
            timestamp: new Date() // Pastikan ada timestamp asli server untuk sorting
        });

        console.log(`Riwayat ${data.testType} Berhasil disimpan.`);
        res.status(201).json({ message: "Riwayat berhasil disimpan!" });
    } catch (error) {
        console.error("ERROR Post History:", error);
        res.status(500).json({ error: error.message });
    }
});
// DELETE ALL HISTORY
router.delete('/history/all', async (req, res) => {
    console.log("LOG: Menghapus semua riwayat...");
    try {
        const snapshot = await db.collection('history').get();
        if (snapshot.empty) return res.status(200).json({ message: "Sudah kosong" });

        const batch = db.batch();
        snapshot.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();
        
        console.log("Semua riwayat berhasil dihapus");
        res.status(200).json({ message: "Semua riwayat berhasil dihapus" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE ONE HISTORY
router.delete('/history/:id', async (req, res) => {
    try {
        await db.collection('history').doc(req.params.id).delete();
        res.status(200).json({ message: "Data berhasil dihapus" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// --- ENDPOINT JOURNAL ---

// GET ALL JOURNAL
router.get('/journal', async (req, res) => {
    try {
        const snapshot = await db.collection('journal').orderBy('date', 'desc').get();
        const results = snapshot.docs.map(doc => ({ id: doc.id, ...doc.data() }));
        res.status(200).json(results);
    } catch (error) {
        res.status(500).json({ message: "Gagal ambil jurnal", error: error.message });
    }
});

// DELETE ALL JOURNAL
router.delete('/journal/all', async (req, res) => {
    console.log("LOG: Menghapus semua jurnal...");
    try {
        const snapshot = await db.collection('journal').get();
        if (snapshot.empty) return res.status(200).json({ message: "Database sudah kosong" });

        const batch = db.batch();
        snapshot.docs.forEach((doc) => batch.delete(doc.ref));
        await batch.commit();

        console.log("Semua jurnal berhasil dihapus dari Firestore");
        res.status(200).json({ message: "Semua jurnal berhasil dihapus" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// DELETE ONE JOURNAL
router.delete('/journal/:id', async (req, res) => {
    try {
        await db.collection('journal').doc(req.params.id).delete();
        res.status(200).json({ message: "Jurnal berhasil dihapus" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

// POST JOURNAL
router.post('/journal', async (req, res) => {
    try {
        const { id, date, content, mood } = req.body;
        if (!id) return res.status(400).json({ message: "ID Jurnal diperlukan" });
        
        await db.collection('journal').doc(id).set({
            id, date, content, mood,
            timestamp: new Date()
        });
        res.status(201).json({ message: "Jurnal berhasil disimpan!" });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});


module.exports = router;