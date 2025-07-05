import 'package:flutter/material.dart';
import 'package:flutter_application_1/databse/dummy_data_service.dart';
import 'package:intl/intl.dart';
import '../models/pemeriksaan_model.dart';

class PemeriksaanFormScreen extends StatefulWidget {
  final int anggotaId;
  const PemeriksaanFormScreen({super.key, required this.anggotaId});

  @override
  State<PemeriksaanFormScreen> createState() => _PemeriksaanFormScreenState();
}

class _PemeriksaanFormScreenState extends State<PemeriksaanFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _bbController = TextEditingController();
  final _tbController = TextEditingController();
  final _ketController = TextEditingController();
  DateTime _tanggalPemeriksaan = DateTime.now();

  Future<void> _selectTanggal(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalPemeriksaan,
      firstDate: DateTime(2015),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _tanggalPemeriksaan) {
      setState(() {
        _tanggalPemeriksaan = picked;
      });
    }
  }

  void _submitData() async {
    if (_formKey.currentState!.validate()) {
      final pemeriksaanBaru = Pemeriksaan(
        anggotaId: widget.anggotaId,
        tanggalPemeriksaan: _tanggalPemeriksaan,
        beratBadan: double.parse(_bbController.text),
        tinggiBadan: double.parse(_tbController.text),
        keterangan: _ketController.text,
      );
      await DummyDataService().insertPemeriksaan(pemeriksaanBaru);
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tambah Pemeriksaan')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Tanggal: ${DateFormat('dd MMMM yyyy').format(_tanggalPemeriksaan)}',
                    ),
                  ),
                  TextButton(
                    onPressed: () => _selectTanggal(context),
                    child: const Text('Pilih Tanggal'),
                  ),
                ],
              ),
              TextFormField(
                controller: _bbController,
                decoration: const InputDecoration(
                  labelText: 'Berat Badan (kg)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _tbController,
                decoration: const InputDecoration(
                  labelText: 'Tinggi Badan (cm)',
                ),
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                validator: (value) =>
                    value!.isEmpty ? 'Tidak boleh kosong' : null,
              ),
              TextFormField(
                controller: _ketController,
                decoration: const InputDecoration(
                  labelText: 'Keterangan (opsional)',
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitData,
                child: const Text('Simpan Pemeriksaan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
