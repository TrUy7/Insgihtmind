import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/entities/daily_journal.dart';
import '../providers/journal_provider.dart';
import 'package:uuid/uuid.dart';

class DailyJournalPage extends ConsumerWidget {
  const DailyJournalPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final journals = ref.watch(journalProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Catatan Harian'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _showAddJournalDialog(context, ref),
          ),
        ],
      ),
      body: journals.isEmpty
          ? const Center(
              child: Text('Belum ada catatan harian.'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: journals.length,
              itemBuilder: (context, index) {
                final journal = journals[index];
                return Card(
                  elevation: 2,
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
                              DateFormat('dd MMM yyyy').format(journal.date),
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium
                                  ?.copyWith(fontWeight: FontWeight.bold),
                            ),
                            Row(
                              children: [
                                Text(
                                  journal.mood,
                                  style: TextStyle(
                                    color: _getMoodColor(journal.mood),
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit, color: Colors.blue),
                                  onPressed: () => _showEditJournalDialog(context, ref, journal),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () => _showDeleteDialog(context, ref, journal.id),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(journal.content),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Color _getMoodColor(String mood) {
    switch (mood.toLowerCase()) {
      case 'happy':
        return Colors.green;
      case 'sad':
        return Colors.blue;
      case 'angry':
        return Colors.red;
      case 'neutral':
        return Colors.grey;
      default:
        return Colors.black;
    }
  }

  void _showAddJournalDialog(BuildContext context, WidgetRef ref) {
    final contentController = TextEditingController();
    String selectedMood = 'Neutral';
    DateTime selectedDate = DateTime.now();

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Tambah Catatan Harian'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Isi catatan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMood,
                  decoration: const InputDecoration(
                    labelText: 'Mood',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Happy', 'Sad', 'Angry', 'Neutral']
                      .map((mood) => DropdownMenuItem(
                            value: mood,
                            child: Text(mood),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedMood = value!);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Tanggal: '),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                      child: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (contentController.text.isNotEmpty) {
                  final journal = DailyJournal(
                    id: const Uuid().v4(),
                    date: selectedDate,
                    content: contentController.text,
                    mood: selectedMood,
                  );
                  ref.read(journalProvider.notifier).addJournal(journal);
                  Navigator.pop(context);
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
          title: const Text('Edit Catatan Harian'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contentController,
                  decoration: const InputDecoration(
                    labelText: 'Isi catatan',
                    border: OutlineInputBorder(),
                  ),
                  maxLines: 5,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  value: selectedMood,
                  decoration: const InputDecoration(
                    labelText: 'Mood',
                    border: OutlineInputBorder(),
                  ),
                  items: ['Happy', 'Sad', 'Angry', 'Neutral']
                      .map((mood) => DropdownMenuItem(
                            value: mood,
                            child: Text(mood),
                          ))
                      .toList(),
                  onChanged: (value) {
                    setState(() => selectedMood = value!);
                  },
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    const Text('Tanggal: '),
                    TextButton(
                      onPressed: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (date != null) {
                          setState(() => selectedDate = date);
                        }
                      },
                      child: Text(DateFormat('dd MMM yyyy').format(selectedDate)),
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                if (contentController.text.isNotEmpty) {
                  final updatedJournal = DailyJournal(
                    id: journal.id,
                    date: selectedDate,
                    content: contentController.text,
                    mood: selectedMood,
                  );
                  ref.read(journalProvider.notifier).updateJournal(updatedJournal);
                  Navigator.pop(context);
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, WidgetRef ref, String journalId) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hapus Catatan'),
        content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Batal'),
          ),
          TextButton(
            onPressed: () {
              ref.read(journalProvider.notifier).removeJournal(journalId);
              Navigator.pop(context);
            },
            child: const Text('Hapus'),
          ),
        ],
      ),
    );
  }
}
