import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/API/authservice.dart';
import 'package:flutter_application_1/presentation/widgets/login_background.dart';
import 'package:google_fonts/google_fonts.dart';
import 'login_screen.dart';
import 'package:flutter_application_1/presentation/screens/components/custom_button.dart';
import 'package:flutter_application_1/presentation/screens/components/loading_indicator.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Controller untuk mengambil teks dari TextField
  final _namaController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  // State untuk visibilitas password dan loading
  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _namaController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // --- FUNGSI UNTUK LOGIKA REGISTER ---
  void _register() async {
    // Validasi input
    if (_namaController.text.isEmpty ||
        _emailController.text.isEmpty ||
        _passwordController.text.isEmpty ||
        _confirmPasswordController.text.isEmpty) {
      _showErrorDialog('Semua field harus diisi');
      return;
    }

    // Validasi email format
    if (!RegExp(
      r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$',
    ).hasMatch(_emailController.text.trim())) {
      _showErrorDialog('Format email tidak valid');
      return;
    }

    // Validasi password minimum 6 karakter
    if (_passwordController.text.length < 6) {
      _showErrorDialog('Password minimal 6 karakter');
      return;
    }

    // Validasi konfirmasi password
    if (_passwordController.text != _confirmPasswordController.text) {
      _showErrorDialog('Password dan konfirmasi password tidak sama');
      return;
    }

    // Tampilkan loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // TODO: Implement register API call
      final registerResponse = await AuthService.register(
        _namaController.text.trim(),
        _emailController.text.trim(),
        _passwordController.text,
      );

      await Future.delayed(const Duration(seconds: 2));
      if (registerResponse == false) {
        _showErrorDialog('Registrasi gagal, silakan coba lagi');
        return;
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Registrasi berhasil! Silakan login'),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 4));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
      }
    } catch (e) {
      // Handle error yang tidak terduga
      _showErrorDialog('Terjadi kesalahan: ${e.toString()}');
    } finally {
      // Matikan loading indicator
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Fungsi untuk menampilkan dialog error
  void _showErrorDialog(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset:
          false, // Mengizinkan resize saat keyboard muncul
      body: Stack(
        children: [
          // Background di belakang
          const LoginBackground(),

          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 32.0,
                  right: 32.0,
                  top: 10.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Image.asset(
                      'assets/images/iconGambar.png', // Corrected path and filename
                      height: 200,
                    ),
                    Text(
                      'Daftar Akun Baru',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 24,
                        color: Colors.black87,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 32),
                    // Input Field Nama
                    TextField(
                      controller: _namaController,
                      keyboardType: TextInputType.name,
                      decoration: InputDecoration(
                        hintText: 'Nama Lengkap',
                        prefixIcon: const Icon(
                          Icons.person_outline,
                          color: Colors.black54,
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(
                          255,
                          136,
                          136,
                          136,
                        ).withOpacity(0.75),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Field Email
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      decoration: InputDecoration(
                        hintText: 'Email',
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: Colors.black54,
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(
                          255,
                          136,
                          136,
                          136,
                        ).withOpacity(0.75),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Field Password
                    TextField(
                      controller: _passwordController,
                      obscureText: !_isPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Password',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.black54,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed:
                              () => setState(
                                () => _isPasswordVisible = !_isPasswordVisible,
                              ),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(
                          255,
                          136,
                          136,
                          136,
                        ).withOpacity(0.75),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Field Konfirmasi Password
                    TextField(
                      controller: _confirmPasswordController,
                      obscureText: !_isConfirmPasswordVisible,
                      decoration: InputDecoration(
                        hintText: 'Konfirmasi Password',
                        prefixIcon: const Icon(
                          Icons.lock_outline,
                          color: Colors.black54,
                        ),
                        suffixIcon: IconButton(
                          icon: Icon(
                            _isConfirmPasswordVisible
                                ? Icons.visibility_off
                                : Icons.visibility,
                          ),
                          onPressed:
                              () => setState(
                                () =>
                                    _isConfirmPasswordVisible =
                                        !_isConfirmPasswordVisible,
                              ),
                        ),
                        filled: true,
                        fillColor: const Color.fromARGB(
                          255,
                          136,
                          136,
                          136,
                        ).withOpacity(0.75),
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 16,
                          horizontal: 16,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Tombol Register
                    CustomButton(
                      text: _isLoading ? '' : 'DAFTAR',
                      onPressed: _isLoading ? () {} : _register,
                      color: Colors.deepPurple,
                      borderRadius: 10,
                    ),
                    if (_isLoading) const LoadingIndicator(),
                    const SizedBox(height: 24),

                    // Link ke Login
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          "Sudah punya akun?",
                          style: GoogleFonts.poppins(
                            color: Colors.black87,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextButton(
                          style: TextButton.styleFrom(
                            textStyle: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          onPressed: () {
                            Navigator.of(context).pushReplacement(
                              MaterialPageRoute(
                                builder: (_) => const LoginScreen(),
                              ),
                            );
                          },
                          child: Text(
                            'Masuk di sini',
                            style: GoogleFonts.poppins(
                              fontWeight: FontWeight.bold,
                              color: Colors.deepPurple,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
