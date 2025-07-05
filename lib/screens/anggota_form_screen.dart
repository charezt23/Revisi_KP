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
  final _bukuKIAController = TextEditingController();

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
      _jenisKelamin = widget.balita!.jenisKelamin;
      _bukuKIAController.text = widget.balita!.bukuKIA;
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
    _bukuKIAController.dispose();
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
      try {
        if (widget.balita == null) {
          // Tambah baru
          await _balitaService.CreateBalita(
            _namaController.text,
            _nikController.text,
            _tanggalLahir,
            _alamatController.text,
            _jenisKelamin,
            widget.posyanduId,
            _bukuKIAController.text,
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
            widget.balita!.id,
            _namaController.text,
            _nikController.text,
            _tanggalLahir,
            _alamatController.text,
            _jenisKelamin,
            widget.posyanduId,
            _bukuKIAController.text,
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
                  TextFormField(
                    controller: _bukuKIAController,
                    decoration: const InputDecoration(
                      labelText: 'Nomor Buku KIA',
                    ),
                    validator:
                        (value) =>
                            value!.isEmpty
                                ? 'Nomor Buku KIA tidak boleh kosong'
                                : null,
                  ),
                  DropdownButtonFormField<String>(
                    value: _jenisKelamin,
                    decoration: const InputDecoration(
                      labelText: 'Jenis Kelamin',
                    ),
                    items:
                        _jenisKelaminOptions
                            .map(
                              (String value) => DropdownMenuItem<String>(
                                value: value,
                                child: Text(value),
                              ),
                            )
                            .toList(),
                    onChanged:
                        (newValue) => setState(() => _jenisKelamin = newValue!),
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
