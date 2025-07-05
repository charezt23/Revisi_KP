import 'package:flutter/material.dart';
import 'package:flutter_application_1/API/BalitaService.dart';
import 'package:flutter_application_1/models/balitaModel.dart';
import 'package:flutter_application_1/widgets/login_background.dart';

class BalitaFormScreen extends StatefulWidget {
  final int posyanduId;
  final BalitaModel? balita; // Untuk edit, bisa null untuk tambah baru
  const BalitaFormScreen({super.key, required this.posyanduId, this.balita});

  @override
  State<BalitaFormScreen> createState() => _BalitaFormScreenState();
}

// Ubah stateful widget untuk menangani form
class _BalitaFormScreenState extends State<BalitaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _balitaService = Balitaservice();
  final _namaController = TextEditingController();
  late TextEditingController _nikController;
  late TextEditingController _alamatController;
  late TextEditingController _tanggalLahirController;
  DateTime _tanggalLahir = DateTime.now();
  String _jenisKelamin = 'Laki-laki'; // Default value
  final List<String> _jenisKelaminOptions = ['Laki-laki', 'Perempuan'];
  final _namaIbuController = TextEditingController();
  String _bukuKIAStatus = 'ada'; // Default value
  final List<String> _bukuKIAOptions = ['ada', 'tidak_ada'];

  @override
  void initState() {
    super.initState();

    if (widget.balita != null) {
      // Mode Edit: isi form dengan data balita yang ada
      _namaController.text = widget.balita!.nama;
      _nikController = TextEditingController(text: widget.balita!.nik);
      _alamatController = TextEditingController(text: widget.balita!.alamat);
      _tanggalLahir = widget.balita!.tanggalLahir;
      _tanggalLahirController = TextEditingController(
        text: _formatDate(widget.balita!.tanggalLahir),
      );
      // Konversi 'L'/'P' dari model ke teks yang bisa dibaca
      _jenisKelamin =
          widget.balita!.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan';
      _bukuKIAStatus = widget.balita!.bukuKIA;
      // Mengisi field nama orang tua jika dalam mode edit
      _namaIbuController.text = widget.balita!.namaIbu;
    } else {
      // Mode Tambah: inisialisasi controller kosong
      _nikController = TextEditingController();
      _alamatController = TextEditingController();
      _tanggalLahirController = TextEditingController(
        text: _formatDate(_tanggalLahir),
      );
    }
  }

  @override
  void dispose() {
    _namaController.dispose();
    _nikController.dispose();
    _alamatController.dispose();
    _tanggalLahirController.dispose();
    _namaIbuController.dispose();
    super.dispose();
  }

  String _formatDate(DateTime date) {
    return "${date.day}-${date.month}-${date.year}";
  }

  Future<void> _pilihTanggalLahir(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
    );
    if (picked != null && picked != _tanggalLahir) {
      setState(() {
        _tanggalLahir = picked;
        _tanggalLahirController.text = _formatDate(picked);
      });
    }
  }

  void _simpanData() async {
    if (_formKey.currentState!.validate()) {
      // Konversi nilai jenis kelamin ke format yang diharapkan backend ('L' atau 'P')
      final jenisKelaminValue = _jenisKelamin == 'Laki-laki' ? 'L' : 'P';
      try {
        if (widget.balita == null) {
          // Tambah baru
          await _balitaService.CreateBalita(
            _namaController.text,
            _nikController.text,
            _tanggalLahir,
            _alamatController.text,
            jenisKelaminValue,
            widget.posyanduId,
            _namaIbuController.text,
            _bukuKIAStatus, // Kirim status 'ada' atau 'tidak_ada'
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data balita berhasil ditambahkan.'),
              backgroundColor: Colors.green,
            ),
          );
        } else {
          // Edit
          await _balitaService.UpdateBalita(
            widget.balita!.id!,
            _namaController.text,
            _nikController.text,
            _tanggalLahir,
            _alamatController.text,
            jenisKelaminValue,
            widget.posyanduId,
            _namaIbuController.text,
            _bukuKIAStatus, // Kirim status 'ada' atau 'tidak_ada'
          );
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data balita berhasil diperbarui.'),
              backgroundColor: Colors.green,
            ),
          );
        }

        Navigator.pop(context, true); // Kirim sinyal berhasil kembali
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.balita == null ? 'Tambah Balita' : 'Edit Balita'),
      ),
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
                    decoration: const InputDecoration(labelText: 'Nama Balita'),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Nama tidak boleh kosong' : null,
                  ),
                  TextFormField(
                    controller: _namaIbuController,
                    decoration: const InputDecoration(labelText: 'Nama Ibu'),
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Nama Ibu tidak boleh kosong'
                                : null,
                  ),
                  TextFormField(
                    controller: _nikController,
                    decoration: const InputDecoration(labelText: 'NIK'),
                    keyboardType: TextInputType.number,
                    validator:
                        (value) =>
                            value!.isEmpty ? 'NIK tidak boleh kosong' : null,
                  ),
                  TextFormField(
                    controller: _tanggalLahirController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Lahir',
                    ),
                    readOnly: true,
                    onTap: () => _pilihTanggalLahir(context),
                  ),
                  // Radio Buttons untuk Status Buku KIA
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Status Buku KIA'),
                      Row(
                        children:
                            _bukuKIAOptions.map((status) {
                              return Row(
                                children: [
                                  Radio<String>(
                                    value: status,
                                    groupValue: _bukuKIAStatus,
                                    onChanged: (value) {
                                      setState(() {
                                        _bukuKIAStatus = value!;
                                      });
                                    },
                                  ),
                                  Text(status == 'ada' ? 'Ada' : 'Tidak Ada'),
                                ],
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                  // Radio Buttons untuk Jenis Kelamin
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('Jenis Kelamin'),
                      Row(
                        children:
                            _jenisKelaminOptions.map((kelamin) {
                              return Row(
                                children: [
                                  Radio<String>(
                                    value: kelamin,
                                    groupValue: _jenisKelamin,
                                    onChanged: (value) {
                                      setState(() {
                                        _jenisKelamin = value!;
                                      });
                                    },
                                  ),
                                  Text(kelamin),
                                ],
                              );
                            }).toList(),
                      ),
                    ],
                  ),
                  TextFormField(
                    controller: _alamatController,
                    decoration: const InputDecoration(labelText: 'Alamat'),
                    validator:
                        (value) =>
                            value!.isEmpty ? 'Alamat tidak boleh kosong' : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: _simpanData,
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child: Text(
                      widget.balita == null ? 'Tambah' : 'Simpan Perubahan',
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
