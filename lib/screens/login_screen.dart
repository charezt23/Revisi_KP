import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/register_screen.dart';
import 'package:flutter_application_1/widgets/login_background.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_application_1/API/authservice.dart';
import 'Home_Screen.dart'
    hide LoginBackground; // <-- Import HomeScreen untuk navigasi

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Controller untuk mengambil teks dari TextField
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  // State untuk visibilitas password, remember me, dan loading
  bool _isPasswordVisible = false;
  bool _rememberMe = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // --- FUNGSI UNTUK LOGIKA LOGIN ---
  void _login() async {
    // Validasi input
    if (_emailController.text.isEmpty || _passwordController.text.isEmpty) {
      _showErrorDialog('Email dan password tidak boleh kosong');
      return;
    }

    // Tampilkan loading indicator
    setState(() {
      _isLoading = true;
    });

    try {
      // Panggil AuthService untuk login
      final loginResponse = await AuthService.login(
        _emailController.text.trim(),
        _passwordController.text,
      );

      if (loginResponse.success) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loginResponse.message),
            backgroundColor: Colors.green,
          ),
        );
        await Future.delayed(const Duration(seconds: 4));
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const HomeScreen()),
        );
      } else {
        // Jika gagal, tampilkan pesan error
        _showErrorDialog(loginResponse.message);
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

  // Widget untuk input email
  Widget _buildEmailField() {
    return TextField(
      controller: _emailController,
      keyboardType: TextInputType.emailAddress,
      decoration: InputDecoration(
        hintText: 'Email',
        prefixIcon: const Icon(Icons.email_outlined, color: Colors.black54),
        filled: true,
        fillColor: const Color.fromARGB(255, 136, 136, 136).withOpacity(0.75),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Widget untuk input password
  Widget _buildPasswordField() {
    return TextField(
      controller: _passwordController,
      obscureText: !_isPasswordVisible,
      decoration: InputDecoration(
        hintText: 'Password',
        prefixIcon: const Icon(Icons.lock_outline, color: Colors.black54),
        suffixIcon: IconButton(
          icon: Icon(
            _isPasswordVisible ? Icons.visibility_off : Icons.visibility,
          ),
          onPressed:
              () => setState(() => _isPasswordVisible = !_isPasswordVisible),
        ),
        filled: true,
        fillColor: const Color.fromARGB(255, 136, 136, 136).withOpacity(0.75),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 16,
          horizontal: 16,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  // Widget untuk checkbox remember me
  Widget _buildRememberMe() {
    return Row(
      children: [
        Expanded(
          child: Row(
            children: [
              Checkbox(
                activeColor: Colors.deepPurple,
                value: _rememberMe,
                onChanged: (value) => setState(() => _rememberMe = value!),
              ),
              Flexible(
                child: Text(
                  'Ingat Saya',
                  style: GoogleFonts.poppins(
                    color: _rememberMe ? Colors.deepPurple : Colors.black87,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // Widget untuk tombol login
  Widget _buildLoginButton() {
    return ElevatedButton(
      onPressed: _isLoading ? null : _login,
      style: ElevatedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 16),
        backgroundColor: Colors.deepPurple,
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
      child:
          _isLoading
              ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              )
              : Text(
                'MASUK',
                style: GoogleFonts.poppins(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.white,
                ),
              ),
    );
  }

  // Widget untuk bagian register
  Widget _buildRegisterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Belum punya akun?",
          style: GoogleFonts.poppins(
            color: Colors.black87,
            fontWeight: FontWeight.w500,
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            textStyle: GoogleFonts.poppins(fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.of(
              context,
            ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
          },
          child: Text(
            'Daftar di sini',
            style: GoogleFonts.poppins(
              fontWeight: FontWeight.bold,
              color: Colors.deepPurple,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          const LoginBackground(),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: EdgeInsets.only(
                  left: 32.0,
                  right: 32.0,
                  top: 5.0,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 32.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: <Widget>[
                    Image.asset('assets/images/iconGambar.png', height: 200),
                    Text(
                      'Masuk untuk melanjutkan pencatatan',
                      textAlign: TextAlign.center,
                      style: GoogleFonts.poppins(
                        fontSize: 16,
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _buildEmailField(),
                    const SizedBox(height: 16),
                    _buildPasswordField(),
                    const SizedBox(height: 8),
                    _buildRememberMe(),
                    const SizedBox(height: 24),
                    _buildLoginButton(),
                    const SizedBox(height: 24),
                    _buildRegisterSection(),
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
