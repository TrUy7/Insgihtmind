import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../../../core/api_config.dart'; // Sesuaikan path ApiConfig Anda

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isPasswordVisible = false;
  bool _isLoading = false;

  Future<void> _handleRegister() async {
    if (_nameController.text.isEmpty || _emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showError("Semua field harus diisi");
      return;
    }

    setState(() => _isLoading = true);

    try {
      // 1. Register ke Firebase Auth
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      // 2. Kirim data ke Node.js untuk disimpan di Firestore Kelompok
      if (userCredential.user != null) {
        await _saveUserToDatabase(
          userCredential.user!.uid,
          _nameController.text.trim(),
          _emailController.text.trim(),
        );

        // 🔥 LOGIKA BARU: Paksa Logout agar tidak langsung masuk ke Home
        await FirebaseAuth.instance.signOut();
      }

      if (!mounted) return;
      
      // Kembali ke Login setelah sukses
      Navigator.pop(context); 
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Registrasi Berhasil! Silahkan Login dengan akun Anda"), 
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
    } on FirebaseAuthException catch (e) {
      _showError(e.message ?? "Registrasi Gagal");
    } catch (e) {
      _showError("Terjadi kesalahan jaringan");
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _saveUserToDatabase(String uid, String name, String email) async {
    try {
      await http.post(
        Uri.parse('${ApiConfig.baseUrl}/register'),
        headers: ApiConfig.headers,
        body: jsonEncode({
          'uid': uid,
          'name': name,
          'email': email,
        }),
      );
    } catch (e) {
      print("Error saving user profile: $e");
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(backgroundColor: const Color(0xFFE8F5E8), elevation: 0, foregroundColor: Colors.black),
      body: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFE8F5E8), Color(0xFFF3E5F5), Color(0xFFE3F2FD)],
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            children: [
              const SizedBox(height: 20),
              _buildLogo(),
              const SizedBox(height: 32),
              const Text("Daftar Akun", style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold)),
              const Text("Mulai pantau kesehatan mental Anda", style: TextStyle(color: Colors.grey)),
              const SizedBox(height: 40),
              
              _buildTextField(_nameController, "Nama Lengkap", Icons.person_outline),
              const SizedBox(height: 16),
              _buildTextField(_emailController, "Email", Icons.email_outlined),
              const SizedBox(height: 16),
              
              // Input Password
              TextField(
                controller: _passwordController,
                obscureText: !_isPasswordVisible,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white,
                  hintText: "Password",
                  prefixIcon: const Icon(Icons.lock_outline),
                  suffixIcon: IconButton(
                    icon: Icon(_isPasswordVisible ? Icons.visibility : Icons.visibility_off),
                    onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
                  ),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                ),
              ),
              const SizedBox(height: 32),
              
              SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6366F1),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  child: _isLoading 
                    ? const CircularProgressIndicator(color: Colors.white) 
                    : const Text("DAFTAR SEKARANG", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String hint, IconData icon) {
    return TextField(
      controller: controller,
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.white,
        hintText: hint,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: const BoxDecoration(color: Color(0xFF6366F1), shape: BoxShape.circle),
      child: const Icon(Icons.psychology_alt_rounded, size: 50, color: Colors.white),
    );
  }
}