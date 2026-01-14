import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';
import 'package:intl/intl.dart';
import 'package:insightmind_app/features/insightmind/domain/entities/daily_journal.dart';
import 'package:insightmind_app/features/insightmind/domain/entities/history_item.dart';
import 'package:insightmind_app/features/insightmind/presentation/providers/analysis_provider.dart';

class PdfService {
  // 1. Ekspor untuk Halaman Jurnal
  static Future<void> exportJournalPDF(List<DailyJournal> journals) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd MMMM yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text("Laporan Catatan Harian InsightMind",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Text("Dicetak pada: $dateStr"),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
              headerHeight: 30,
              cellHeight: 40,
              headers: ['Tanggal', 'Mood', 'Isi Catatan'],
              data: journals.map((item) => [
                DateFormat('dd/MM/yyyy').format(item.date),
                item.mood,
                item.content,
              ]).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'Catatan_Harian.pdf');
  }

  // 2. Ekspor untuk Halaman Laporan/Grafik
  static Future<void> exportAnalysisPDF(AnalysisData analysis) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (pw.Context context) {
          return pw.Column(
            // --- PERBAIKAN ERROR 'cross' ---
            // Parameter yang benar adalah 'crossAxisAlignment', bukan 'cross'
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Text("Dashboard Analisis Kesehatan Mental",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
              pw.SizedBox(height: 10),
              pw.Divider(),
              pw.SizedBox(height: 20),
              pw.Text("Ringkasan Statistik:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.Bullet(text: "Skor Rata-rata: ${analysis.averageScore}"),
              pw.Bullet(text: "Tingkat Risiko: ${analysis.overallRisk}"),
              pw.Bullet(text: "Total Jurnal: ${analysis.journalCount}"),
              pw.SizedBox(height: 20),
              pw.Text("Distribusi Mood:", style: pw.TextStyle(fontSize: 18, fontWeight: pw.FontWeight.bold)),
              pw.TableHelper.fromTextArray(
                headers: ['Mood', 'Jumlah'],
                data: analysis.moodCounts.entries.map((e) => [e.key, e.value.toString()]).toList(),
              ),
              pw.SizedBox(height: 30),
              pw.Container(
                  padding: const pw.EdgeInsets.all(10),
                  decoration: const pw.BoxDecoration(color: PdfColors.amber100),
                  child: pw.Column(
                    // --- PERBAIKAN ERROR 'cross' ---
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text("Rekomendasi:", style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
                        pw.Text(analysis.overallRisk == 'Tinggi'
                            ? "Sangat disarankan untuk berkonsultasi dengan profesional."
                            : "Pertahankan pola hidup sehat dan rutin menulis jurnal."),
                      ]
                  )
              )
            ],
          );
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'Laporan_Kesehatan_Mental.pdf');
  }

  // 3. Ekspor untuk Halaman Riwayat Screening
  static Future<void> exportHistoryPDF(List<HistoryItem> historyList) async {
    final pdf = pw.Document();
    final dateStr = DateFormat('dd MMMM yyyy').format(DateTime.now());

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return [
            pw.Header(
              level: 0,
              child: pw.Text("Riwayat Screening Kesehatan Mental",
                  style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Text("Dicetak pada: $dateStr"),
            pw.SizedBox(height: 20),
            pw.TableHelper.fromTextArray(
              border: pw.TableBorder.all(color: PdfColors.grey300),
              headerDecoration: const pw.BoxDecoration(color: PdfColors.grey100),
              headerHeight: 30,
              cellHeight: 40,
              columnWidths: {
                0: const pw.FlexColumnWidth(2), // Tanggal
                1: const pw.FlexColumnWidth(1), // Skor
                2: const pw.FlexColumnWidth(1), // Risiko
                3: const pw.FlexColumnWidth(3), // Jawaban
              },
              headers: ['Tanggal', 'Skor', 'Risiko', 'Jawaban'],
              data: historyList.map((item) => [
                DateFormat('dd/MM/yyyy HH:mm').format(item.date),
                item.score.toString(),
                item.riskLevel,
                item.answers.join(", "),
              ]).toList(),
            ),
          ];
        },
      ),
    );

    await Printing.layoutPdf(onLayout: (format) async => pdf.save(), name: 'Riwayat_Screening.pdf');
  }
}