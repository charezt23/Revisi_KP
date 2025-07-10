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

class _BalitaFormScreenState extends State<BalitaFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _balitaService = Balitaservice();

  // --- State Variables ---
  bool _isLoading = false; // DIPINDAHKAN ke dalam state
  final _namaController = TextEditingController();
  final _namaIbuController = TextEditingController();
  late TextEditingController _nikController;
  late TextEditingController _alamatController;
  late TextEditingController _tanggalLahirController;
  DateTime _tanggalLahir = DateTime.now();
  String _jenisKelamin = 'Laki-laki';
  String _bukuKIAStatus = 'ada';

  final List<String> _jenisKelaminOptions = ['Laki-laki', 'Perempuan'];
  final List<String> _bukuKIAOptions = ['ada', 'tidak_ada'];

  @override
  void initState() {
    super.initState();
    _nikController = TextEditingController();
    _alamatController = TextEditingController();
    _tanggalLahirController = TextEditingController(
      text: _formatDate(_tanggalLahir),
    );

    if (widget.balita != null) {
      // Mode Edit
      final balita = widget.balita!;
      _namaController.text = balita.nama;
      _namaIbuController.text = balita.namaIbu;
      _nikController.text = balita.nik;
      _alamatController.text = balita.alamat;
      _tanggalLahir = balita.tanggalLahir;
      _tanggalLahirController.text = _formatDate(balita.tanggalLahir);
      _jenisKelamin = balita.jenisKelamin == 'L' ? 'Laki-laki' : 'Perempuan';
      _bukuKIAStatus = balita.bukuKIA;
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
    return "${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}";
  }

  Future<void> _pilihTanggalLahir(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _tanggalLahir,
      firstDate: DateTime(DateTime.now().year - 5), // Batas 5 tahun ke belakang
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

  Future<void> _simpanData() async {
    // Validasi form
    if (!_formKey.currentState!.validate()) {
      return;
    }
    // Hentikan jika sedang dalam proses menyimpan
    if (_isLoading) return;

    setState(() {
      _isLoading = true;
    });

    try {
      final jenisKelaminValue = _jenisKelamin == 'Laki-laki' ? 'L' : 'P';
      String pesanSukses;

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
          _bukuKIAStatus,
        );
        pesanSukses = 'Data balita berhasil ditambahkan.';
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
          _bukuKIAStatus,
        );
        pesanSukses = 'Data balita berhasil diperbarui.';
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(pesanSukses), backgroundColor: Colors.green),
        );
        Navigator.pop(context, true); // Kirim sinyal berhasil
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
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
                            value!.trim().isEmpty
                                ? 'Nama tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _namaIbuController,
                    decoration: const InputDecoration(labelText: 'Nama Ibu'),
                    validator:
                        (value) =>
                            value!.trim().isEmpty
                                ? 'Nama Ibu tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _nikController,
                    decoration: const InputDecoration(labelText: 'NIK'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      final nik = value?.trim() ?? '';
                      if (nik.isEmpty) return 'NIK tidak boleh kosong';
                      if (nik.length != 16) return 'NIK harus 16 digit';
                      if (!RegExp(r'^\d{16}\$').hasMatch(nik))
                        return 'NIK hanya boleh berisi angka';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _tanggalLahirController,
                    decoration: const InputDecoration(
                      labelText: 'Tanggal Lahir',
                      suffixIcon: Icon(Icons.calendar_today),
                    ),
                    readOnly: true,
                    onTap: () => _pilihTanggalLahir(context),
                  ),
                  const SizedBox(height: 16),
                  _buildRadioGroup(
                    title: 'Status Buku KIA',
                    options: _bukuKIAOptions,
                    groupValue: _bukuKIAStatus,
                    onChanged:
                        (value) => setState(() => _bukuKIAStatus = value!),
                    displayLabels: {'ada': 'Ada', 'tidak_ada': 'Tidak Ada'},
                  ),
                  const SizedBox(height: 16),
                  _buildRadioGroup(
                    title: 'Jenis Kelamin',
                    options: _jenisKelaminOptions,
                    groupValue: _jenisKelamin,
                    onChanged:
                        (value) => setState(() => _jenisKelamin = value!),
                  ),
                  const SizedBox(height: 12),
                  TextFormField(
                    controller: _alamatController,
                    decoration: const InputDecoration(labelText: 'Alamat'),
                    validator:
                        (value) =>
                            value!.trim().isEmpty
                                ? 'Alamat tidak boleh kosong'
                                : null,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed:
                        _isLoading
                            ? null
                            : _simpanData, // Nonaktifkan tombol saat loading
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    child:
                        _isLoading
                            ? const SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 3,
                              ),
                            )
                            : Text(
                              widget.balita == null
                                  ? 'Tambah'
                                  : 'Simpan Perubahan',
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

  // Widget helper untuk radio group agar tidak duplikasi kode
  Widget _buildRadioGroup({
    required String title,
    required List<String> options,
    required String groupValue,
    required ValueChanged<String?> onChanged,
    Map<String, String>? displayLabels,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: Theme.of(context).textTheme.bodyLarge),
        Row(
          children:
              options.map((option) {
                return Expanded(
                  child: RadioListTile<String>(
                    title: Text(displayLabels?[option] ?? option),
                    value: option,
                    groupValue: groupValue,
                    onChanged: onChanged,
                    contentPadding: EdgeInsets.zero,
                  ),
                );
              }).toList(),
        ),
      ],
    );
  }
}
