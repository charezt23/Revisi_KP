import 'package:flutter/material.dart';
import 'package:flutter_application_1/API/PosyanduService.dart';
import 'package:flutter_application_1/screens/home_screen.dart';

class KohortFormScreen extends StatefulWidget {
  // Meskipun bernama KohortFormScreen, form ini akan membuat data Posyandu
  // sesuai dengan permintaan.
  const KohortFormScreen({super.key});

  @override
  State<KohortFormScreen> createState() => _KohortFormScreenState();
}

class _KohortFormScreenState extends State<KohortFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaPosyanduController = TextEditingController();
  final _namaDesaController = TextEditingController();
  final _posyanduService = Posyanduservice();
  bool _isLoading = false;

  @override
  void dispose() {
    _namaPosyanduController.dispose();
    _namaDesaController.dispose();
    super.dispose();
  }

  Future<void> _submitForm() async {
    // Validasi form
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        // TODO: Ganti '1' dengan ID user yang sedang login dari SharedPreferences.
        // Panggil API untuk membuat Posyandu.
        // Kita akan mengasumsikan proses ini sukses jika tidak ada error yang terjadi.
        await _posyanduService.CreatePosyandu(
          _namaPosyanduController.text,
          _namaDesaController.text,
          1, // Untuk sementara, ID pengguna di-hardcode
        );

        // Jika kode berhasil mencapai baris ini, berarti tidak ada error.
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Posyandu berhasil dibuat!'),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke halaman sebelumnya (HomeScreen)
        Navigator.pop(context);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Buat Posyandu Baru'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Stack(
        children: [
          const LoginBackground(), // Menggunakan background yang sama
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: Card(
                color: Colors.white.withOpacity(0.95),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        TextFormField(
                          controller: _namaPosyanduController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Posyandu',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.local_hospital),
                          ),
                          validator:
                              (value) =>
                                  (value == null || value.isEmpty)
                                      ? 'Nama Posyandu tidak boleh kosong'
                                      : null,
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _namaDesaController,
                          decoration: const InputDecoration(
                            labelText: 'Nama Desa/Kelurahan',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.location_city),
                          ),
                          validator:
                              (value) =>
                                  (value == null || value.isEmpty)
                                      ? 'Nama Desa tidak boleh kosong'
                                      : null,
                        ),
                        const SizedBox(height: 24),
                        _isLoading
                            ? const CircularProgressIndicator()
                            : ElevatedButton(
                              onPressed: _submitForm,
                              style: ElevatedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 50,
                                  vertical: 15,
                                ),
                              ),
                              child: const Text('Simpan'),
                            ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
