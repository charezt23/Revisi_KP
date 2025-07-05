import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anggota_model.dart';
import 'package:flutter_application_1/widgets/login_background.dart';

class ImunisasiFormScreen extends StatefulWidget {
  final Anggota anggota;

  const ImunisasiFormScreen({super.key, required this.anggota});

  @override
  State<ImunisasiFormScreen> createState() => _ImunisasiFormScreenState();
}

class _ImunisasiFormScreenState extends State<ImunisasiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _jenisImunisasiController = TextEditingController();

  void _simpanPemeriksaan() {
    if (_formKey.currentState!.validate()) {
      // TODO: Implementasikan logika penyimpanan data imunisasi ke database.
      // Contoh: await DummyDataService().addImunisasi(
      //   anggotaId: widget.anggota.id!,
      //   jenis: _jenisImunisasiController.text,
      // );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Imunisasi "${_jenisImunisasiController.text}" untuk ${widget.anggota.nama} berhasil disimpan.',
          ),
          backgroundColor: Colors.green,
        ),
      );
      // Kembali ke halaman detail kohort setelah menyimpan
      Navigator.of(context).pop();
    }
  }

  @override
  void dispose() {
    _jenisImunisasiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Imunisasi'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const LoginBackground(),
          Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Card(
                color: Colors.white.withOpacity(0.9),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'Pencatatan Imunisasi',
                          style: Theme.of(context).textTheme.headlineSmall,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Anggota: ${widget.anggota.nama}',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _jenisImunisasiController,
                          decoration: const InputDecoration(
                            labelText: 'Jenis Imunisasi',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.vaccines_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Jenis imunisasi tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _simpanPemeriksaan,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
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
