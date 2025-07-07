import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/balitaModel.dart';
import 'package:flutter_application_1/API/kematianService.dart';
import 'package:flutter_application_1/widgets/login_background.dart';
import 'package:intl/intl.dart';

class KematianFormScreen extends StatefulWidget {
  final BalitaModel balita;

  const KematianFormScreen({super.key, required this.balita});

  @override
  State<KematianFormScreen> createState() => _KematianFormScreenState();
}

class _KematianFormScreenState extends State<KematianFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tanggalController = TextEditingController();
  final _penyebabController = TextEditingController();
  final KematianService _kematianService = KematianService();
  bool _isSaving = false;
  DateTime? _selectedDate;

  @override
  void dispose() {
    _tanggalController.dispose();
    _penyebabController.dispose();
    super.dispose();
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
        // Format tanggal yang akan ditampilkan di UI
        _tanggalController.text = DateFormat(
          'dd MMMM yyyy',
          'id_ID',
        ).format(picked);
      });
    }
  }

  Future<void> _simpanPencatatan() async {
    if (!_formKey.currentState!.validate() || _isSaving) {
      return;
    }

    setState(() {
      _isSaving = true;
    });

    try {
      // Pastikan tanggal sudah dipilih
      if (_selectedDate == null) {
        throw Exception("Tanggal kematian harus dipilih");
      }

      // Format tanggal ke yyyy-MM-dd untuk dikirim ke API
      final String formattedDateForApi = DateFormat(
        'yyyy-MM-dd',
      ).format(_selectedDate!);

      Map<String, dynamic> data = {
        'balita_id': widget.balita.id,
        'tanggal_kematian': formattedDateForApi,
        'penyebab': _penyebabController.text, // Kunci disesuaikan
      };

      // Panggil service. Jika ada error, akan dilempar ke blok catch.
      await _kematianService.createKematian(data);

      // Jika kode mencapai baris ini, berarti sukses.
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Data kematian untuk ${widget.balita.nama} berhasil dicatat.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Kirim sinyal 'true' kembali ke halaman detail untuk refresh
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Menangani error dari 'throw Exception'
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
          _isSaving = false;
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
                          'Balita: ${widget.balita.nama}',
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
                            prefixIcon: Icon(
                              Icons.medical_information_outlined,
                            ),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Penyebab kematian tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 24),
                        ElevatedButton(
                          onPressed: _isSaving ? null : _simpanPencatatan,
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            backgroundColor: Colors.red.shade700,
                          ),
                          child:
                              _isSaving
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
