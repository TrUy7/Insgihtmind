class ApiConfig {
  static const String baseUrl = 'http://10.0.2.2:3000/api'; 

  static const String history = '$baseUrl/history';
  static const String journal = '$baseUrl/journal';
  static const String sensor = '$baseUrl/sensor';
  static const String authGoogle = '$baseUrl/auth/google';

  // 1. Header Standar (Tanpa Token - untuk Login/Register)
  static Map<String, String> get headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
  };

  // 2. Header dengan Token (UNTUK JOURNAL & HISTORY)
  static Map<String, String> headersWithToken(String token) {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
}