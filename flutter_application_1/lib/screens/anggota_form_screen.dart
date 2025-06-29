import 'package:flutter/material.dart';
import 'package:flutter_application_1/databse/dummy_data_service.dart';// Ganti ke DatabaseHelper jika perlu
import 'package:flutter_application_1/widgets/login_background.dart';
import '../models/anggota_model.dart';

class AnggotaFormScreen extends StatefulWidget {
  final int kohortId;
  const AnggotaFormScreen({super.key, required this.kohortId});

  @override
  State<AnggotaFormScreen> createState() => _AnggotaFormScreenState();
}

class _AnggotaFormScreenState extends State<AnggotaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // DEKLARASI SEMUA CONTROLLER ADA DI SINI
  final _namaController = TextEditingController();
  final _keteranganController = TextEditingController();
  // --- BARIS YANG PERLU ANDA TAMBAHKAN ---
  final _riwayatPenyakitController = TextEditingController(); 
  // -----------------------------------------

  @override
  void dispose() {
    // Best practice: Selalu dispose controller untuk menghindari memory leak
    _namaController.dispose();
    _keteranganController.dispose();
    _riwayatPenyakitController.dispose();
    super.dispose();
  }


  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      final anggotaBaru = Anggota(
        kohortId: widget.kohortId,
        nama: _namaController.text,
        keterangan: _keteranganController.text,
        // Gunakan data dari controller yang baru
        riwayatPenyakit: _riwayatPenyakitController.text, 
      );
      
      await DummyDataService().insertAnggota(anggotaBaru);
      
      if (mounted) {
         Navigator.of(context).pop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Anggota Baru')),
      body: Stack(
        children: [
          const LoginBackground(),
          SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  TextFormField(
                    controller: _namaController,
                    decoration: const InputDecoration(labelText: 'Nama Lengkap Anggota'),
                    validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 16),

                  // TextFormField ini sekarang akan mengenali controller-nya
                  TextFormField(
                    controller: _riwayatPenyakitController,
                    decoration: const InputDecoration(labelText: 'Riwayat Penyakit (jika ada)'),
                  ),
                  const SizedBox(height: 16),

                  TextFormField(
                    controller: _keteranganController,
                    decoration: const InputDecoration(labelText: 'Keterangan (Opsional)'),
                  ),
                  const SizedBox(height: 24),
                  
                  ElevatedButton(
                    onPressed: _submitData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16)
                    ),
                    child: const Text('Simpan Anggota'),
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}