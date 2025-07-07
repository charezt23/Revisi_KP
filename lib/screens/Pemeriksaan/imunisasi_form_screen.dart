import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/balitaModel.dart';
import 'package:flutter_application_1/models/imunisasi.dart';
import 'package:flutter_application_1/widgets/login_background.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/API/ImunisasiService.dart';

class ImunisasiFormScreen extends StatefulWidget {
  final BalitaModel balita;

  final dynamic imunisasiToEdit;

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
        // Sesuaikan payload dengan yang diharapkan oleh service (Map<String, dynamic>)
        final data = {
          'balita_id': widget.balita.id!,
          'jenis_imunisasi': _jenisImunisasiTerpilih!,
          'tanggal_imunisasi': DateFormat('yyyy-MM-dd').format(_selectedDate!),
        };

        // Panggil service dan tangkap hasilnya (boolean)
        final bool isSuccess = await _imunisasiService.createImunisasi(data);

        if (!mounted) return;

        if (isSuccess) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Imunisasi "$_jenisImunisasiTerpilih" untuk ${widget.balita.nama} berhasil disimpan.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          // Kembali ke halaman sebelumnya dengan nilai true untuk menandakan sukses
          Navigator.of(context).pop(true);
        } else {
          // Tampilkan error jika service mengembalikan false
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text(
                'Gagal menyimpan data. Server merespon dengan error.',
              ),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (!mounted) return;
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
