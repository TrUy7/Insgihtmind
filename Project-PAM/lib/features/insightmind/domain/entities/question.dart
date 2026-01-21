class AnswerOption {
  final String label;
  final int score;

  const AnswerOption({required this.label, required this.score});
}

class Question {
  final String id;
  final String text;
  final List<AnswerOption> options;

  const Question({required this.id, required this.text, required this.options});
}

// PHQ-9 Questions
const phq9Questions = [
  Question(
    id: 'phq1',
    text:
        'Selama 2 minggu terakhir, seberapa sering Anda memiliki sedikit minat atau kesenangan dalam melakukan hal-hal?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'phq2',
    text: 'Seberapa sering Anda merasa sedih, murung, atau putus asa?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'phq3',
    text:
        'Kesulitan tidur, sulit mempertahankan tidur, atau tidur terlalu banyak?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'phq4',
    text: 'Merasa lelah atau memiliki sedikit energi?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'phq5',
    text: 'Nafsu makan buruk atau makan berlebihan?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'phq6',
    text:
        'Merasa buruk tentang diri sendiri — merasa gagal atau mengecewakan diri/keluarga?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'phq7',
    text:
        'Kesulitan berkonsentrasi pada sesuatu, seperti membaca atau menonton televisi?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'phq8',
    text:
        'Bergerak atau berbicara sangat lambat sehingga orang lain memperhatikan, atau sebaliknya — merasa sangat gelisah atau resah?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
  Question(
    id: 'phq9',
    text:
        'Memiliki pikiran bahwa Anda akan lebih baik jika mati atau ingin menyakiti diri sendiri?',
    options: [
      AnswerOption(label: 'Tidak Pernah', score: 0),
      AnswerOption(label: 'Beberapa Hari', score: 1),
      AnswerOption(label: 'Lebih dari Separuh Hari', score: 2),
      AnswerOption(label: 'Hampir Setiap Hari', score: 3),
    ],
  ),
];

// DASS-21 Questions (Depression, Anxiety, Stress subscales)
const dass21Questions = [
  // Depression subscale
  Question(
    id: 'dass1',
    text: 'Saya merasa tidak berharga atau tidak berguna.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass2',
    text: 'Saya merasa pesimis tentang masa depan.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass3',
    text: 'Saya merasa gagal dalam hidup.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass4',
    text: 'Saya tidak mendapatkan kesenangan dari hal-hal yang biasanya saya nikmati.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass5',
    text: 'Saya merasa bersalah tanpa alasan.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass6',
    text: 'Saya merasa khawatir tentang berbagai hal.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass7',
    text: 'Saya tidak dapat mentoleransi hal-hal yang menghentikan saya melakukan apa yang harus saya lakukan.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  // Anxiety subscale
  Question(
    id: 'dass8',
    text: 'Saya merasa sulit untuk rileks.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass9',
    text: 'Saya merasa mulut saya kering.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass10',
    text: 'Saya tidak dapat merasakan perasaan positif.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass11',
    text: 'Saya mengalami kesulitan bernapas (misalnya, sering bernapas cepat, sulit bernapas meskipun tidak berolahraga).',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass12',
    text: 'Saya cenderung panik.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass13',
    text: 'Saya khawatir bahwa saya akan kehilangan kendali dan "gila".',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass14',
    text: 'Saya khawatir bahwa sesuatu yang buruk akan terjadi.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  // Stress subscale
  Question(
    id: 'dass15',
    text: 'Saya merasa bahwa saya menggunakan energi terlalu banyak.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass16',
    text: 'Saya merasa sulit untuk rileks.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass17',
    text: 'Saya merasa mudah tersinggung.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass18',
    text: 'Saya merasa gelisah.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass19',
    text: 'Saya menemukan sulit untuk mentoleransi gangguan terhadap apa yang sedang saya lakukan.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass20',
    text: 'Saya merasa bahwa saya agak tidak peka atau bereaksi berlebihan terhadap situasi.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
  Question(
    id: 'dass21',
    text: 'Saya merasa sulit untuk tenang setelah sesuatu yang mengganggu.',
    options: [
      AnswerOption(label: 'Tidak sesuai sama sekali', score: 0),
      AnswerOption(label: 'Sesuai pada tingkat rendah', score: 1),
      AnswerOption(label: 'Sesuai pada tingkat sedang', score: 2),
      AnswerOption(label: 'Sesuai pada tingkat tinggi', score: 3),
    ],
  ),
];

// For backward compatibility, keep defaultQuestions as PHQ-9
const defaultQuestions = phq9Questions;
