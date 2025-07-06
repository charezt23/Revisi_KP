import 'package:flutter/material.dart';
import 'package:flutter_application_1/API/KunjunganBalitaService.dart';
import 'package:flutter_application_1/models/balitaModel.dart';
import 'package:flutter_application_1/widgets/login_background.dart';
import 'package:intl/intl.dart';

class KunjunganFormScreen extends StatefulWidget {
  final BalitaModel balita;

  const KunjunganFormScreen({super.key, required this.balita});

  @override
  State<KunjunganFormScreen> createState() => _KunjunganFormScreenState();
}

class _KunjunganFormScreenState extends State<KunjunganFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _kunjunganService = Kunjunganbalitaservice();

  final _tanggalController = TextEditingController();
  final _beratBadanController = TextEditingController();
  final _tinggiBadanController = TextEditingController();

  DateTime _selectedDate = DateTime.now();

  // State untuk Radio Button
  String? _selectedStatusGizi;
  final Map<String, String> _statusGiziOptions = {
    'N': 'Normal',
    'K': 'Kurang',
    'T': 'Tinggi/Obesitas',
  };

  String? _selectedRambuGizi;
  final List<String> _rambuGiziOptions = ['O', 'N1', 'N2', 'T1', 'T2', 'T3'];

  // State untuk loading indicator
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tanggalController.text = DateFormat('dd-MM-yyyy').format(_selectedDate);
  }

  Future<void> _pilihTanggal() async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      locale: const Locale('id', 'ID'),
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
        final kunjunganBaru = await _kunjunganService.CreateKunjunganBalita(
          widget.balita.id!,
          _selectedDate,
          // Menggunakan replaceAll untuk memastikan format angka benar
          // jika pengguna memasukkan koma sebagai desimal.
          double.parse(_beratBadanController.text.replaceAll(',', '.')),
          double.parse(_tinggiBadanController.text.replaceAll(',', '.')),
          _selectedStatusGizi!,
          _selectedRambuGizi!,
        );

        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Kunjungan untuk ${widget.balita.nama} berhasil dicatat.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Kembali ke halaman sebelumnya dengan data baru untuk menandakan sukses
        Navigator.of(context).pop(kunjunganBaru);
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menyimpan data: $e'),
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
    _beratBadanController.dispose();
    _tinggiBadanController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Form Kunjungan Balita'),
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
                          'Pencatatan Kunjungan',
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
                            labelText: 'Tanggal Kunjungan',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.calendar_today),
                          ),
                          readOnly: true,
                          onTap: _pilihTanggal,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tanggal kunjungan tidak boleh kosong';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _beratBadanController,
                          decoration: const InputDecoration(
                            labelText: 'Berat Badan (kg)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.monitor_weight_outlined),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Berat badan tidak boleh kosong';
                            }
                            if (double.tryParse(value.replaceAll(',', '.')) ==
                                null) {
                              return 'Masukkan angka yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _tinggiBadanController,
                          decoration: const InputDecoration(
                            labelText: 'Tinggi Badan (cm)',
                            border: OutlineInputBorder(),
                            prefixIcon: Icon(Icons.height_outlined),
                          ),
                          keyboardType: const TextInputType.numberWithOptions(
                            decimal: true,
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Tinggi badan tidak boleh kosong';
                            }
                            if (double.tryParse(value.replaceAll(',', '.')) ==
                                null) {
                              return 'Masukkan angka yang valid';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 16),
                        // --- Radio Button untuk Status Gizi ---
                        FormField<String>(
                          validator: (value) {
                            if (_selectedStatusGizi == null) {
                              return 'Status gizi harus dipilih.';
                            }
                            return null;
                          },
                          builder:
                              (state) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Status Gizi',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Row(
                                    children:
                                        _statusGiziOptions.entries.map((entry) {
                                          return Expanded(
                                            child: RadioListTile<String>(
                                              title: Text(entry.value),
                                              value: entry.key,
                                              groupValue: _selectedStatusGizi,
                                              onChanged: (value) {
                                                setState(
                                                  () =>
                                                      _selectedStatusGizi =
                                                          value,
                                                );
                                                state.didChange(value);
                                              },
                                              contentPadding: EdgeInsets.zero,
                                            ),
                                          );
                                        }).toList(),
                                  ),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                      ),
                                      child: Text(
                                        state.errorText!,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                        ),
                        const SizedBox(height: 16),
                        // --- Radio Button untuk Rambu Gizi ---
                        FormField<String>(
                          validator: (value) {
                            if (_selectedRambuGizi == null) {
                              return 'Rambu gizi harus dipilih.';
                            }
                            return null;
                          },
                          builder:
                              (state) => Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Rambu Gizi',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  Column(
                                    children: [
                                      Row(
                                        children:
                                            _rambuGiziOptions
                                                .sublist(0, 3)
                                                .map(
                                                  (option) => Expanded(
                                                    child: RadioListTile<
                                                      String
                                                    >(
                                                      title: Text(option),
                                                      value: option,
                                                      groupValue:
                                                          _selectedRambuGizi,
                                                      onChanged: (value) {
                                                        setState(
                                                          () =>
                                                              _selectedRambuGizi =
                                                                  value,
                                                        );
                                                        state.didChange(value);
                                                      },
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                      Row(
                                        children:
                                            _rambuGiziOptions
                                                .sublist(3, 6)
                                                .map(
                                                  (option) => Expanded(
                                                    child: RadioListTile<
                                                      String
                                                    >(
                                                      title: Text(option),
                                                      value: option,
                                                      groupValue:
                                                          _selectedRambuGizi,
                                                      onChanged: (value) {
                                                        setState(
                                                          () =>
                                                              _selectedRambuGizi =
                                                                  value,
                                                        );
                                                        state.didChange(value);
                                                      },
                                                      contentPadding:
                                                          EdgeInsets.zero,
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                      ),
                                    ],
                                  ),
                                  if (state.hasError)
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        left: 12.0,
                                      ),
                                      child: Text(
                                        state.errorText!,
                                        style: TextStyle(
                                          color:
                                              Theme.of(
                                                context,
                                              ).colorScheme.error,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
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
