import 'package:flutter/material.dart';
import 'package:flutter_application_1/databse/dummy_data_service.dart';
import '../models/kohort_model.dart';

class KohortFormScreen extends StatefulWidget {
  const KohortFormScreen({super.key});

  @override
  State<KohortFormScreen> createState() => _KohortFormScreenState();
}

class _KohortFormScreenState extends State<KohortFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _namaController = TextEditingController();
  final _alamatController = TextEditingController();
  final _deskripsiController = TextEditingController();

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      final kohortBaru = Kohort(
        nama: _namaController.text,
        alamat: _alamatController.text,
        deskripsi: _deskripsiController.text,
        tanggalDibuat: DateTime.now(),
      );
      await DummyDataService().insertKohort(kohortBaru);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Buat Kohort Baru')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _namaController,
                decoration: const InputDecoration(labelText: 'Nama Kohort / Kelompok', border: OutlineInputBorder()),
                validator: (value) => value!.isEmpty ? 'Nama tidak boleh kosong' : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _alamatController,
                decoration: const InputDecoration(labelText: 'Alamat (Opsional)', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _deskripsiController,
                decoration: const InputDecoration(labelText: 'Deskripsi Singkat (Opsional)', border: OutlineInputBorder()),
                maxLines: 3,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _submitData,
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  textStyle: const TextStyle(fontSize: 16)
                ),
                child: const Text('Simpan Kohort'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}