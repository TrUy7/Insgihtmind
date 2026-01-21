import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';
import '../../domain/entities/daily_journal.dart';
import '../providers/journal_provider.dart';
import 'package:insightmind_app/core/api_config.dart';
import 'package:insightmind_app/core/service/pdf_service.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import PDF Service

class DailyJournalPage extends ConsumerStatefulWidget {
  const DailyJournalPage({super.key});

  @override
  ConsumerState<DailyJournalPage> createState() => _DailyJournalPageState();
}

class _DailyJournalPageState extends ConsumerState<DailyJournalPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchJournals());
  }

  // --- LOGIKA BACKEND ---
Future<void> _fetchJournals() async {
  setState(() => _isLoading = true); // Mulai loading
  try {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    if (token == null) return;

    final response = await http.get(
      Uri.parse(ApiConfig.journal),
      headers: ApiConfig.headersWithToken(token),
    );

    if (response.statusCode == 200) {
      final List data = jsonDecode(response.body);
      
      
      ref.read(journalProvider.notifier).setJournals(
        data.map((item) => DailyJournal.fromJson(item)).toList()
      );
    }
  } catch (e) {
    debugPrint("Gagal ambil data: $e");
  } finally {
    if (mounted) setState(() => _isLoading = false); // Berhenti loading
  }
}

Future<void> _saveToCloud(DailyJournal journal) async {
  try {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    
    // LOG UNTUK CEK TOKEN
    if (token == null) {
      debugPrint("ERROR: Token null, pastikan Anda sudah Login di Emulator!");
      return;
    }

    final response = await http.post(
      Uri.parse(ApiConfig.journal),
      headers: ApiConfig.headersWithToken(token), 
      body: jsonEncode(journal.toJson()),
    ).timeout(const Duration(seconds: 10));

    // LOG UNTUK CEK RESPON SERVER
    debugPrint("Status Code: ${response.statusCode}");
    debugPrint("erver Response: ${response.body}");

    if (response.statusCode == 201) {
      debugPrint("BERHASIL");
    } else {
      debugPrint("GAGAL(${response.statusCode})");
    }
  } catch (e) {
    debugPrint("MASALAH JARINGAN: $e");
    debugPrint("Tips: Pastikan server Node.js jalan dan baseUrl adalah 10.0.2.2");
  }
}

Future<void> _deleteFromCloud(String id) async {
  try {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    await http.delete(
      Uri.parse('${ApiConfig.journal}/$id'),
      headers: {
        ...ApiConfig.headers,
        'Authorization': 'Bearer $token', // WAJIB
      },
    );
  } catch (e) {
    debugPrint("Gagal hapus: $e");
  }
}

Future<void> _deleteAllJournals() async {
  setState(() => _isLoading = true);
  try {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    final response = await http.delete(
      Uri.parse('${ApiConfig.journal}/all'),
      headers: {
        ...ApiConfig.headers,
        'Authorization': 'Bearer $token', // WAJIB
      },
    );
    // ... sisa logika status code 200 ...
  } catch (e) { /* error handling */ }
}
  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Data?'),
        content: const Text('Apakah anda ingin menghapus seluruh catatan harian?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tidak')
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              _deleteAllJournals();   // Eksekusi hapus
            },
            child: const Text('Ya', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS ---
  @override
  Widget build(BuildContext context) {
    final journals = ref.watch(journalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Harian'),
        actions: [
          // TOMBOL EXPORT PDF
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Export PDF',
            onPressed: journals.isEmpty
                ? null
                : () => PdfService.exportJournalPDF(journals),
          ),
          // TOMBOL HAPUS SEMUA (Menggantikan Refresh)
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            tooltip: 'Hapus Semua',
            onPressed: journals.isEmpty
                ? null
                : _showDeleteAllConfirmation,
          ),
          // Tombol Tambah
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddJournalDialog(context, ref),
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : journals.isEmpty
          ? const Center(child: Text('Belum ada catatan harian.'))
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: journals.length,
        itemBuilder: (context, index) {
          final journal = journals[index];
          return _buildJournalCard(journal);
        },
      ),
    );
  }

  Widget _buildJournalCard(DailyJournal journal) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(DateFormat('dd MMM yyyy').format(journal.date),
                style: const TextStyle(fontWeight: FontWeight.bold)),
            _moodBadge(journal.mood),
          ],
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 8.0),
          child: Text(journal.content),
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
              onPressed: () => _showEditJournalDialog(context, ref, journal),
            ),
            IconButton(
              icon: const Icon(Icons.delete, color: Colors.red, size: 20),
              onPressed: () => _showDeleteDialog(context, ref, journal.id),
            ),
          ],
        ),
      ),
    );
  }

  Widget _moodBadge(String mood) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: _getMoodColor(mood).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(mood, style: TextStyle(color: _getMoodColor(mood), fontWeight: FontWeight.bold, fontSize: 12)),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy': return Colors.green;
      case 'sad': return Colors.blue;
      case 'angry': return Colors.red;
      case 'neutral': return Colors.grey;
      default: return Colors.black;
    }
  }

  // --- DIALOGS ---

  void _showAddJournalDialog(BuildContext context, WidgetRef ref) {
    final contentController = TextEditingController();
    String selectedMood = 'Neutral';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Center(child: Text('Tambah Catatan Harian', style: TextStyle(fontWeight: FontWeight.bold))),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: InputDecoration(
                    hintText: "Isi catatan",
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMood,
                  decoration: const InputDecoration(labelText: 'Mood', border: OutlineInputBorder()),
                  items: ['Happy', 'Sad', 'Angry', 'Neutral'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                  onChanged: (val) => setState(() => selectedMood = val!),
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Tanggal:  ', style: TextStyle(fontSize: 16)),
                    GestureDetector(
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2000),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) setState(() => selectedDate = date);
                      },
                      child: Text(
                        DateFormat('dd MMM yyyy').format(selectedDate),
                        style: const TextStyle(color: Colors.blueAccent, fontSize: 16),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                if (contentController.text.isNotEmpty) {
                  final journal = DailyJournal(
                    id: const Uuid().v4(),
                    date: selectedDate,
                    content: contentController.text,
                    mood: selectedMood,
                  );
                  Navigator.pop(context);
                  ref.read(journalProvider.notifier).addJournal(journal);
                  await _saveToCloud(journal);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditJournalDialog(BuildContext context, WidgetRef ref, DailyJournal journal) {
    final contentController = TextEditingController(text: journal.content);
    String selectedMood = journal.mood;
    DateTime selectedDate = journal.date;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Center(child: Text('Edit Catatan Harian', style: TextStyle(fontWeight: FontWeight.bold))),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(controller: contentController, maxLines: 5, decoration: const InputDecoration(border: OutlineInputBorder())),
              const SizedBox(height: 16),
              DropdownButtonFormField<String>(
                value: selectedMood,
                items: ['Happy', 'Sad', 'Angry', 'Neutral'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                onChanged: (val) => setState(() => selectedMood = val!),
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  const Text('Tanggal:  '),
                  GestureDetector(
                    onTap: () async {
                      final date = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2000), lastDate: DateTime.now());
                      if (date != null) setState(() => selectedDate = date);
                    },
                    child: Text(DateFormat('dd MMM yyyy').format(selectedDate), style: const TextStyle(color: Colors.blueAccent)),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
            TextButton(
              onPressed: () async {
                final updated = DailyJournal(id: journal.id, date: selectedDate, content: contentController.text, mood: selectedMood);
                Navigator.pop(context);
                ref.read(journalProvider.notifier).updateJournal(updated);
                await _saveToCloud(updated);
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              ref.read(journalProvider.notifier).removeJournal(id);
              await _deleteFromCloud(id);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}