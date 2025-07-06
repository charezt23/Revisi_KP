import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anggota_model.dart';
import 'package:flutter_application_1/API/kematianService.dart';
import 'package:flutter_application_1/widgets/login_background.dart';
import 'package:intl/intl.dart';

class KematianFormScreen extends StatefulWidget {
  final Anggota anggota;

  const KematianFormScreen({super.key, required this.anggota});

  @override
  State<KematianFormScreen> createState() => _KematianFormScreenState();
}

class _KematianFormScreenState extends State<KematianFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tanggalController = TextEditingController();
  final _penyebabController = TextEditingController();

  // Instance dari KematianService
  final KematianService _kematianService = KematianService();

  // State untuk menangani proses loading
  bool _isLoading = false;

  Future<void> _pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _tanggalController.text = DateFormat('dd-MM-yyyy').format(picked);
      });
    }
  }

  Future<void> _simpanPencatatan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // Mengubah format tanggal agar sesuai dengan standar API (yyyy-MM-dd)
      final DateFormat displayFormat = DateFormat('dd-MM-yyyy');
      final DateFormat apiFormat = DateFormat('yyyy-MM-dd');
      final DateTime parsedDate = displayFormat.parse(_tanggalController.text);
      final String formattedDateForApi = apiFormat.format(parsedDate);

      // Membuat Map dengan kunci yang benar sesuai permintaan server
      Map<String, dynamic> data = {
        'balita_id': widget.anggota.id,
        'tanggal_kematian': formattedDateForApi,
        // --- PERBAIKAN DI SINI ---
        'penyebab_kematian': _penyebabController.text,
      };

      // Memanggil service untuk membuat data kematian
      // Disini kita menggunakan service yang mengembalikan Future<bool>
      bool isSuccess = await _kematianService.createKematian(data);

      if (isSuccess && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data kematian untuk ${widget.anggota.nama} berhasil dicatat.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } else if (!isSuccess && mounted) {
        // Jika service mengembalikan false, tampilkan pesan error umum
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Gagal menyimpan data. Silakan coba lagi.'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      // Menangani error dari 'throw Exception' jika service Anda menggunakannya
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
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
        title: const Text('Form Kematian'),
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
                          'Pencatatan Kematian',
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
                          controller: _tanggalController,
                          decoration: const InputDecoration(
                            labelText: 'Tanggal Kematian',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: _pilihTanggal,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _penyebabController,
                          decoration: const InputDecoration(
                            labelText: 'Penyebab Kematian',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.medical_services_outlined),
                          ),
                          validator: (value) {
                            // Menambahkan validasi agar field ini tidak kosong
                            if (value == null || value.isEmpty) {
                              return 'Penyebab kematian tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _simpanPencatatan,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.red.shade700,
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
                                  : const Text('Simpan Data Kematian'),
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
