class ApiConfig {
  // 1. Jika Anda menggunakan Emulator Android, gunakan IP: 10.0.2.2
  // 2. Jika menggunakan HP Fisik, gunakan IP Laptop Anda (misal: 192.168.1.xx)
  // 3. Jika sudah deploy ke Firebase Hosting, gunakan URL Cloud Functions Anda
  static const String baseUrl = 'http://10.0.2.2:3000/api'; 

  // Endpoint untuk Riwayat (History)
  static const String history = '$baseUrl/history';

  // Endpoint untuk Catatan Harian (Journal)
  static const String journal = '$baseUrl/journal';

  // Endpoint untuk Data Sensor (PPG/Akselerometer)
  static const String sensor = '$baseUrl/sensor';

  static const String authGoogle = '$baseUrl/auth/google';

  // Header Standar untuk API JSON
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };
}