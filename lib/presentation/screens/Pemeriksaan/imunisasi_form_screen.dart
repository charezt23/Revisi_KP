import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/API/ImunisasiService.dart';
import 'package:flutter_application_1/data/models/balitaModel.dart';
import 'package:flutter_application_1/data/models/imunisasi.dart';
import 'package:flutter_application_1/presentation/widgets/login_background.dart';
import 'package:intl/intl.dart';

class ImunisasiFormScreen extends StatefulWidget {
  final BalitaModel balita;
  final Imunisasi? imunisasiToEdit;

  const ImunisasiFormScreen({
    super.key,
    required this.balita,
    this.imunisasiToEdit,
  });

  @override
  State<ImunisasiFormScreen> createState() => _ImunisasiFormScreenState();
}

class _ImunisasiFormScreenState extends State<ImunisasiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tanggalController = TextEditingController();
  String? _jenisImunisasiTerpilih;
  final List<String> _opsiImunisasi = ['DPT', 'Campak'];

  final _imunisasiService = ImunisasiService();
  DateTime? _selectedDate;
  bool _isLoading = false;

  // Getter untuk mengecek apakah ini mode edit atau buat baru
  bool get _isEditing => widget.imunisasiToEdit != null;

  @override
  void initState() {
    super.initState();
    // Jika ini mode edit, isi form dengan data yang ada
    if (_isEditing) {
      final imunisasi = widget.imunisasiToEdit!;
      _jenisImunisasiTerpilih = imunisasi.jenisImunisasi;
      _selectedDate = imunisasi.tanggalImunisasi;
      _tanggalController.text = DateFormat('dd-MM-yyyy').format(_selectedDate!);
    }
  }

  Future<void> _pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
        _tanggalController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  void _simpanPemeriksaan() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        bool isSuccess;
        String successMessage;

        if (_isEditing) {
          // --- LOGIKA UNTUK UPDATE ---
          // Pastikan service Anda memiliki method untuk update
          // dan Anda mengirim ID dari data yang akan di-edit.
          final dataToUpdate = {
            'jenis_imunisasi': _jenisImunisasiTerpilih!,
            'tanggal_imunisasi': DateFormat(
              'yyyy-MM-dd',
            ).format(_selectedDate!),
          };
          final idToUpdate = widget.imunisasiToEdit!.id;
          isSuccess = await _imunisasiService.updateImunisasi(
            idToUpdate,
            dataToUpdate,
          );
          successMessage = 'Data imunisasi berhasil diperbarui.';
        } else {
          // --- LOGIKA UNTUK CREATE (YANG SUDAH ADA) ---
          final dataToCreate = {
            'balita_id': widget.balita.id!,
            'jenis_imunisasi': _jenisImunisasiTerpilih!,
            'tanggal_imunisasi': DateFormat(
              'yyyy-MM-dd',
            ).format(_selectedDate!),
          };
          isSuccess = await _imunisasiService.createImunisasi(dataToCreate);
          successMessage =
              'Imunisasi "$_jenisImunisasiTerpilih" untuk ${widget.balita.nama} berhasil disimpan.';
        }

        if (!mounted) return;

        if (isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(successMessage),
              backgroundColor: Colors.green,
            ),
          );
          // Kembali ke halaman sebelumnya dengan nilai true untuk menandakan sukses
          Navigator.of(context).pop(true);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Gagal menyimpan data. Terjadi kesalahan di server.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) {
          return;
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan: $e'),
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
  void dispose() {
    _tanggalController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          _isEditing ? 'Edit Imunisasi' : 'Form Imunisasi',
          style: const TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.black, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
                          'Balita: ${widget.balita.nama}',
                          style: Theme.of(context).textTheme.titleMedium,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _tanggalController,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Imunisasi',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: _pilihTanggal,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal imunisasi tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        DropdownButtonFormField<String>(
                          value: _jenisImunisasiTerpilih,
                          decoration: const InputDecoration(
                            labelText: 'Jenis Imunisasi',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.vaccines_outlined),
                          ),
                          items:
                              _opsiImunisasi.map((String jenis) {
                                return DropdownMenuItem<String>(
                                  value: jenis,
                                  child: Text(jenis),
                                );
                              }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              _jenisImunisasiTerpilih = newValue;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Silakan pilih jenis imunisasi';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _simpanPemeriksaan,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                          child:
                              _isLoading
                                  ? const SizedBox(
                                    height: 24,
                                    width: 24,
                                    child: CircularProgressIndicator(
                                      color: Colors.white,
                                      strokeWidth: 3,
                                    ),
                                  )
                                  : const Text('Simpan'),
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
