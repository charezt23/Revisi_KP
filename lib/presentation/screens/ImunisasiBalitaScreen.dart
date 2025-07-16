import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/posyanduModel.dart';
import 'package:flutter_application_1/data/API/BalitaService.dart';
import 'package:flutter_application_1/data/models/balitaModel.dart';
import 'package:flutter_application_1/presentation/screens/components/loading_indicator.dart';

class ImunisasiBalitaScreen extends StatefulWidget {
  final PosyanduModel posyandu;
  const ImunisasiBalitaScreen({super.key, required this.posyandu});

  @override
  State<ImunisasiBalitaScreen> createState() => _ImunisasiBalitaScreenState();
}

class _ImunisasiBalitaScreenState extends State<ImunisasiBalitaScreen> {
  final Balitaservice _balitaService = Balitaservice();
  late Future<List<BalitaModel>> _balitaList;
  String _filter = 'semua'; // 'semua', 'sudah', 'belum'

  @override
  void initState() {
    super.initState();
    _balitaList = _balitaService.GetBalitaByPosyandu(widget.posyandu.id!);
  }

  List<BalitaModel> _filterBalita(List<BalitaModel> allBalita) {
    if (_filter == 'sudah') {
      return allBalita.where((b) => b.sudahImunisasi == true).toList();
    } else if (_filter == 'belum') {
      return allBalita.where((b) => b.sudahImunisasi != true).toList();
    }
    return allBalita;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Daftar Balita - Imunisasi'),
        backgroundColor: Colors.red,
        actions: [
          DropdownButton<String>(
            value: _filter,
            items: const [
              DropdownMenuItem(value: 'semua', child: Text('Semua')),
              DropdownMenuItem(value: 'sudah', child: Text('Sudah Imunisasi')),
              DropdownMenuItem(value: 'belum', child: Text('Belum Imunisasi')),
            ],
            onChanged: (val) {
              setState(() {
                _filter = val!;
              });
            },
          ),
        ],
      ),
      body: FutureBuilder<List<BalitaModel>>(
        future: _balitaList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: LoadingIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('Belum ada data balita.'));
          }
          final filteredBalita = _filterBalita(snapshot.data!);
          if (filteredBalita.isEmpty) {
            return const Center(child: Text('Tidak ada data sesuai filter.'));
          }
          return ListView.builder(
            itemCount: filteredBalita.length,
            itemBuilder: (context, index) {
              final balita = filteredBalita[index];
              return Card(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: ListTile(
                  leading: Icon(
                    balita.sudahImunisasi == true
                        ? Icons.check_circle
                        : Icons.cancel,
                    color:
                        balita.sudahImunisasi == true
                            ? Colors.green
                            : Colors.grey,
                  ),
                  title: Text(balita.nama),
                  subtitle: Text('NIK: ${balita.nik}\nIbu: ${balita.namaIbu}'),
                  trailing: Text(
                    balita.sudahImunisasi == true ? 'Sudah' : 'Belum',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
