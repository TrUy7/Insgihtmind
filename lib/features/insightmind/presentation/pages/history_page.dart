import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:http/http.dart' as http;
import '../providers/history_provider.dart';
import 'package:insightmind_app/core/api_config.dart';
import '../../domain/entities/history_item.dart';

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
    // Memuat data dari database secara otomatis saat halaman dibuka
    Future.microtask(() => _fetchHistoryFromDatabase());
  }

  /// Mengambil data riwayat dari backend Node.js dan memperbarui provider
 Future<void> _fetchHistoryFromDatabase() async {
    if (!mounted) return;
    setState(() => _isLoading = true);

    try {
      debugPrint("Menghubungi: ${ApiConfig.history}");
      final response = await http.get(
        Uri.parse(ApiConfig.history),
        headers: ApiConfig.headers,
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final List decodedData = jsonDecode(response.body);
        debugPrint("Data diterima: ${decodedData.length} item");

        // Konversi dengan aman
        final List<HistoryItem> fetchedItems = decodedData.map((itemJson) {
          return HistoryItem.fromJson(itemJson);
        }).toList();

        // URUTKAN: Data terbaru selalu di paling atas
        fetchedItems.sort((a, b) => b.date.compareTo(a.date));

        // UPDATE PROVIDER SEKALIGUS
        ref.read(historyProvider.notifier).clearHistory();
        
        // Gunakan spread operator jika notifier mendukung, atau loop yang sudah ada
        for (var item in fetchedItems) {
          ref.read(historyProvider.notifier).addHistory(item);
        }
        
        debugPrint("Sinkronisasi Berhasil.");
      } else {
        debugPrint("Gagal Ambil Data: ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("Kesalahan Jaringan: $e");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  /// Menghapus item tertentu dari cloud dan memperbarui state lokal
  Future<void> _deleteFromDatabase(String id) async {
    try {
      final response = await http.delete(
        Uri.parse('${ApiConfig.history}/$id'),
        headers: ApiConfig.headers,
      );

      if (response.statusCode == 200) {
        ref.read(historyProvider.notifier).removeHistory(id);
      }
    } catch (e) {
      debugPrint("Failed to delete from cloud: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    final history = ref.watch(historyProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Screening'),
        actions: [
          // Tombol refresh untuk memicu sinkronisasi manual
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchHistoryFromDatabase,
          ),
          // Tombol Hapus Semua telah dihilangkan dari sini
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