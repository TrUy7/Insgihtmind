import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../providers/history_provider.dart';
import 'package:insightmind_app/core/api_config.dart';
import '../../domain/entities/history_item.dart';
import 'package:insightmind_app/core/service/pdf_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class HistoryPage extends ConsumerStatefulWidget {
  const HistoryPage({super.key});

  @override
  ConsumerState<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends ConsumerState<HistoryPage> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    Future.microtask(() => _fetchHistoryFromDatabase());
  }

// Di dalam file history_page.dart
Future<void> _fetchHistoryFromDatabase() async {
  if (!mounted) return;
  setState(() => _isLoading = true);

  try {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    
    if (token != null) {
      // PANGGIL API NODE.JS (Bukan Firestore Langsung)
      final response = await http.get(
        Uri.parse(ApiConfig.history),
        headers: {
          "Authorization": "Bearer $token", // Wajib untuk verifyToken di Node.js
        },
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);
        
        // Mengonversi data JSON menggunakan model HistoryItem.fromJson Anda yang baru
        final fetchedItems = data.map((json) => HistoryItem.fromJson(json)).toList();

        // Bersihkan state lama dan perbarui dengan data baru yang sudah benar
        ref.read(historyProvider.notifier).clearHistory();
        for (var item in fetchedItems) {
          ref.read(historyProvider.notifier).addHistory(item);
        }
        debugPrint("Riwayat berhasil dimuat");
      }
    }
  } catch (e) {
    debugPrint("Gagal Muat Riwayat: $e");
  } finally {
    if (mounted) setState(() => _isLoading = false);
  }
}
  Future<void> _deleteFromDatabase(String id) async {
  try {
    final token = await FirebaseAuth.instance.currentUser?.getIdToken();
    
    final response = await http.delete(
      Uri.parse('${ApiConfig.history}/$id'),
      headers: {
        ...ApiConfig.headers,
        'Authorization': 'Bearer $token', // WAJIB untuk verifyToken
      },
    );

    if (response.statusCode == 200) {
      // Hapus dari tampilan lokal (Riverpod)
      ref.read(historyProvider.notifier).removeHistory(id);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Riwayat berhasil dihapus dari Cloud')),
        );
      }
    } else {
      debugPrint("Gagal hapus di server: ${response.body}");
    }
  } catch (e) {
    debugPrint("Failed to delete from cloud: $e");
  }
}

  // --- LOGIKA HAPUS SEMUA (OPTIMAL) ---
  Future<void> _deleteAllHistory() async {
    setState(() => _isLoading = true);

    try {
      // Panggil API /history/all
      final response = await http.delete(
        Uri.parse('${ApiConfig.history}/all'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        // Hapus dari state lokal
        ref.read(historyProvider.notifier).clearHistory();

        if(mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Seluruh riwayat screening berhasil dihapus.'))
          );
        }
      } else {
        throw Exception("Gagal menghapus data di server");
      }
    } catch (e) {
      debugPrint("Error Delete All History: $e");
      if(mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Gagal menghapus: $e'))
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _showDeleteAllConfirmation() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Semua Data?'),
        content: const Text('Apakah anda ingin menghapus seluruh riwayat screening?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Tidak')
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context); // Tutup dialog
              _deleteAllHistory();    // Eksekusi hapus
            },
            child: const Text('Ya', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Screening'),
        actions: [
          // TOMBOL EXPORT PDF
          IconButton(
            icon: const Icon(Icons.print),
            tooltip: 'Cetak Riwayat',
            onPressed: history.isEmpty
                ? null
                : () => PdfService.exportHistoryPDF(history),
          ),
          // TOMBOL HAPUS SEMUA
          IconButton(
            icon: const Icon(Icons.delete_forever, color: Colors.red),
            tooltip: 'Hapus Semua',
            onPressed: history.isEmpty
                ? null
                : _showDeleteAllConfirmation,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _fetchHistoryFromDatabase,
        child: history.isEmpty
            ? const Center(child: Text('Belum ada riwayat screening.'))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: history.length,
          itemBuilder: (context, index) {
            final item = history[index];
            return Card(
              elevation: 2,
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          DateFormat('dd MMM yyyy, HH:mm').format(item.date),
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete, color: Colors.red),
                          onPressed: () => _showSingleDeleteDialog(item.id),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text('Skor: ${item.score}'),
                    Text(
                      'Tingkat Risiko: ${item.riskLevel}',
                      style: TextStyle(
                        color: item.riskLevel == 'Tinggi'
                            ? Colors.red
                            : item.riskLevel == 'Sedang'
                            ? Colors.orange
                            : Colors.green,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text('Jawaban:', style: TextStyle(fontWeight: FontWeight.w500)),
                    Wrap(
                      spacing: 4,
                      children: item.answers
                          .map((a) => Chip(
                        label: Text('$a', style: const TextStyle(fontSize: 12)),
                        visualDensity: VisualDensity.compact,
                      ))
                          .toList(),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _showSingleDeleteDialog(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Riwayat'),
        content: const Text('Apakah Anda yakin ingin menghapus riwayat ini?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Batal')),
          TextButton(
            onPressed: () {
              _deleteFromDatabase(id);
              Navigator.pop(context);
            },
            child: const Text('Hapus', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}