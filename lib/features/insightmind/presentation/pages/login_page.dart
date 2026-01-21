import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'register_page.dart'; // Pastikan Anda sudah membuat file ini

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleLogin() async {
    // Validasi input kosong
    if (_emailController.text.trim().isEmpty || _passwordController.text.trim().isEmpty) {
      _showSnackBar("Email dan Password tidak boleh kosong", Colors.orange);
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Login menggunakan Firebase Auth
      await FirebaseAuth.instance.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );
      
      // Berhasil login: Tidak perlu Navigator.push karena biasanya 
      // StreamBuilder di main.dart/app.dart akan mendeteksi perubahan status auth
      
    } on FirebaseAuthException catch (e) {
      if (!mounted) return; // Mencegah error setState setelah dispose
      
      String message = "Login Gagal";
      if (e.code == 'user-not-found') message = "Pengguna tidak ditemukan";
      else if (e.code == 'wrong-password') message = "Password salah";
      
      _showSnackBar(e.message ?? message, Colors.red);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E8), Color(0xFFF3E5F5), Color(0xFFE3F2FD)],
          ),
        ),
        child: SingleChildScrollView( // Tambahkan scroll agar aman di layar kecil
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 80.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildLogo(),
                const SizedBox(height: 32),
                const Text("InsightMind", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
                const Text("Masuk untuk melanjutkan pemantauan", style: TextStyle(color: Colors.grey)),
                const SizedBox(height: 40),
                
                // Input Email
                _buildTextField(
                  controller: _emailController,
                  hint: "Email",
                  icon: Icons.email_outlined,
                ),
                const SizedBox(height: 16),
                
                // Input Password
                _buildTextField(
                  controller: _passwordController,
                  hint: "Password",
                  icon: Icons.lock_outline,
                  isPassword: true,
                ),
                const SizedBox(height: 24),
                
                // Tombol Login
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF6366F1),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                    child: _isLoading 
                      ? const CircularProgressIndicator(color: Colors.white) 
                      : const Text("LOGIN", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Navigasi ke Register
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text("Belum punya akun? "),
                    GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const RegisterPage()),
                        );
                      },
                      child: const Text(
                        "Daftar di sini",
                        style: TextStyle(
                          color: Color(0xFF6366F1),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool isPassword = false,
  }) {
    return TextField(
      controller: controller,
      obscureText: isPassword ? !_isPasswordVisible : false,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        prefixIcon: Icon(icon),
        suffixIcon: isPassword 
          ? IconButton(
              icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
              onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
            )
          : null,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16), 
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle),
      child: const Icon(Icons.psychology_alt_rounded, size: 80, color: Colors.white),
    );
  }
}