// import 'package:flutter/material.dart';
// import 'package:flutter_application_1/API/authservice.dart';
// import 'package:flutter_application_1/widgets/login_background.dart';

// class RegistrationScreen extends StatefulWidget {
//   const RegistrationScreen({super.key});

//   @override
//   State<RegistrationScreen> createState() => _RegistrationScreenState();
// }

// class _RegistrationScreenState extends State<RegistrationScreen> {
//   final _formKey = GlobalKey<FormState>();
//   final _nameController = TextEditingController();
//   final _emailController = TextEditingController();
//   final _passwordController = TextEditingController();
//   final _confirmPasswordController = TextEditingController();

//   bool _isLoading = false;
//   bool _isPasswordVisible = false;

//   final AuthService _authService = AuthService();

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _emailController.dispose();
//     _passwordController.dispose();
//     _confirmPasswordController.dispose();
//     super.dispose();
//   }

//   Future<void> _prosesRegistrasi() async {
//     if (!_formKey.currentState!.validate()) {
//       return;
//     }

//     if (_passwordController.text != _confirmPasswordController.text) {
//         ScaffoldMessenger.of(context).showSnackBar(
//             const SnackBar(
//                 content: Text('Password dan konfirmasi password tidak cocok.'),
//                 backgroundColor: Colors.orange,
//             ),
//         );
//         return;
//     }

//     setState(() {
//       _isLoading = true;
//     });

//     try {
//       await _authService.register(
//         name: _nameController.text,
//         email: _emailController.text,
//         password: _passwordController.text,
//         passwordConfirmation: _confirmPasswordController.text,
//       );

//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('Registrasi berhasil! Silakan login.'),
//             backgroundColor: Colors.green,
//           ),
//         );
//         Navigator.of(context).pop(); // Kembali ke halaman login
//       }
//     } catch (e) {
//       if (mounted) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Gagal registrasi: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     } finally {
//       if (mounted) {
//         setState(() {
//           _isLoading = false;
//         });
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Buat Akun Baru'),
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//       ),
//       extendBodyBehindAppBar: true,
//       body: Stack(
//         children: [
//           const LoginBackground(), // Widget background Anda
//           Center(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24.0),
//               child: Card(
//                  elevation: 8,
//                 shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//                 child: Padding(
//                   padding: const EdgeInsets.all(24.0),
//                   child: Form(
//                     key: _formKey,
//                     child: Column(
//                       mainAxisSize: MainAxisSize.min,
//                       crossAxisAlignment: CrossAxisAlignment.stretch,
//                       children: [
//                         TextFormField(
//                           controller: _nameController,
//                           decoration: const InputDecoration(
//                             labelText: 'Nama Lengkap',
//                             prefixIcon: Icon(Icons.person_outline),
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) => value == null || value.isEmpty ? 'Nama tidak boleh kosong' : null,
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _emailController,
//                           decoration: const InputDecoration(
//                             labelText: 'Email',
//                             prefixIcon: Icon(Icons.email_outlined),
//                             border: OutlineInputBorder(),
//                           ),
//                           keyboardType: TextInputType.emailAddress,
//                            validator: (value) {
//                             if (value == null || value.isEmpty) return 'Email tidak boleh kosong';
//                             if (!RegExp(r'\S+@\S+\.\S+').hasMatch(value)) return 'Format email tidak valid';
//                             return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _passwordController,
//                           obscureText: !_isPasswordVisible,
//                           decoration: InputDecoration(
//                             labelText: 'Password',
//                             prefixIcon: const Icon(Icons.lock_outline),
//                             border: const OutlineInputBorder(),
//                              suffixIcon: IconButton(
//                               icon: Icon(_isPasswordVisible ? Icons.visibility_off : Icons.visibility),
//                               onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
//                             ),
//                           ),
//                           validator: (value) {
//                              if (value == null || value.isEmpty) return 'Password tidak boleh kosong';
//                              if (value.length < 8) return 'Password minimal 8 karakter';
//                              return null;
//                           },
//                         ),
//                         const SizedBox(height: 16),
//                         TextFormField(
//                           controller: _confirmPasswordController,
//                           obscureText: !_isPasswordVisible,
//                           decoration: const InputDecoration(
//                             labelText: 'Konfirmasi Password',
//                             prefixIcon: Icon(Icons.lock_outline),
//                             border: OutlineInputBorder(),
//                           ),
//                           validator: (value) => value == null || value.isEmpty ? 'Konfirmasi password tidak boleh kosong' : null,
//                         ),
//                         const SizedBox(height: 24),
//                         ElevatedButton(
//                           onPressed: _isLoading ? null : _prosesRegistrasi,
//                           style: ElevatedButton.styleFrom(
//                             padding: const EdgeInsets.symmetric(vertical: 16),
//                           ),
//                           child: _isLoading
//                               ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white))
//                               : const Text('Daftar'),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }
// }
