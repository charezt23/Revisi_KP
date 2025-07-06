import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/anggota_model.dart';
import 'package:flutter_application_1/API/ImunisasiService.dart';
import 'package:flutter_application_1/widgets/login_background.dart';
import 'package:intl/intl.dart';

class ImunisasiFormScreen extends StatefulWidget {
  final Anggota anggota;

  const ImunisasiFormScreen({super.key, required this.anggota});

  @override
  State<ImunisasiFormScreen> createState() => _ImunisasiFormScreenState();
}

class _ImunisasiFormScreenState extends State<ImunisasiFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tanggalController = TextEditingController();
  String? _jenisImunisasiTerpilih;
  final List<String> _opsiImunisasi = [
    'BCG',
    'DPT',
    'Polio',
    'Campak',
    'Hepatitis B',
  ];

  // Instance dari ImunisasiService
  final ImunisasiService _imunisasiService = ImunisasiService();
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

  // --- IMPLEMENTASI LOGIKA PENYIMPANAN ---
  Future<void> _simpanPemeriksaan() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      // 1. Ubah format tanggal untuk API
      final DateFormat displayFormat = DateFormat('dd-MM-yyyy');
      final DateFormat apiFormat = DateFormat('yyyy-MM-dd');
      final DateTime parsedDate = displayFormat.parse(_tanggalController.text);
      final String formattedDateForApi = apiFormat.format(parsedDate);

      // 2. Siapkan data untuk dikirim
      Map<String, dynamic> data = {
        'balita_id': widget.anggota.id,
        'jenis_imunisasi': _jenisImunisasiTerpilih!,
        'tanggal_imunisasi': formattedDateForApi,
      };

      // 3. Panggil service
      await _imunisasiService.createImunisasi(data);

      // 4. Tampilkan pesan sukses dan kembali
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Imunisasi "$_jenisImunisasiTerpilih" untuk ${widget.anggota.nama} berhasil disimpan.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      // Tangani error
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
  void dispose() {
    _tanggalController.dispose();
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
