import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/posyanduModel.dart';
import 'package:flutter_application_1/data/API/BalitaService.dart';
import 'package:flutter_application_1/data/models/balitaModel.dart';
import 'package:flutter_application_1/presentation/screens/components/loading_indicator.dart';
import 'package:flutter_application_1/data/API/ImunisasiService.dart';

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

  // Untuk filter, asumsikan sudahImunisasi tetap digunakan untuk filter global
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
        title: const Text(
          'Daftar Balita - Imunisasi',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.red,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
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
                child: InkWell(
                  onTap: () async {
                    showDialog(
                      context: context,
                      builder: (ctx) {
                        return AlertDialog(
                          title: Text('Riwayat Imunisasi ${balita.nama}'),
                          content: FutureBuilder<List<dynamic>>(
                            future: ImunisasiService().getImunisasiByBalita(
                              balita.id!,
                            ),
                            builder: (context, snapshot) {
                              if (snapshot.connectionState ==
                                  ConnectionState.waiting) {
                                return const SizedBox(
                                  width: 32,
                                  height: 32,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                );
                              }
                              if (snapshot.hasError) {
                                return Text(
                                  'Gagal memuat data imunisasi',
                                  style: TextStyle(color: Colors.red),
                                );
                              }
                              final imunisasiList = snapshot.data ?? [];
                              if (imunisasiList.isEmpty) {
                                return const Text(
                                  'Belum ada imunisasi yang dilakukan.',
                                );
                              }
                              return SizedBox(
                                width: 250,
                                child: ListView.builder(
                                  shrinkWrap: true,
                                  itemCount: imunisasiList.length,
                                  itemBuilder: (context, idx) {
                                    final imunisasi = imunisasiList[idx];
                                    return ListTile(
                                      leading: const Icon(
                                        Icons.vaccines,
                                        color: Colors.green,
                                      ),
                                      title: Text(
                                        imunisasi.jenisImunisasi ?? '-',
                                      ),
                                      subtitle: Text(
                                        imunisasi.tanggalImunisasi != null
                                            ? imunisasi.tanggalImunisasi
                                                .toString()
                                            : '-',
                                      ),
                                    );
                                  },
                                ),
                              );
                            },
                          ),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.of(ctx).pop(),
                              child: const Text('Tutup'),
                            ),
                          ],
                        );
                      },
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(child: Text(balita.nama)),
                            FutureBuilder<List<dynamic>>(
                              future: ImunisasiService().getImunisasiByBalita(
                                balita.id!,
                              ),
                              builder: (context, snapshot) {
                                if (snapshot.connectionState ==
                                    ConnectionState.waiting) {
                                  return Row(
                                    children: [
                                      const SizedBox(
                                        width: 20,
                                        height: 20,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Text('Memuat imunisasi...'),
                                    ],
                                  );
                                }
                                if (snapshot.hasError) {
                                  return Text(
                                    'Gagal memuat imunisasi',
                                    style: TextStyle(color: Colors.red),
                                  );
                                }
                                final imunisasiList = snapshot.data ?? [];
                                final imunisasiGiven =
                                    imunisasiList
                                        .map(
                                          (i) =>
                                              (i.jenisImunisasi ?? '')
                                                  .toString()
                                                  .toUpperCase(),
                                        )
                                        .toList();
                                final sudahDPT = imunisasiGiven.any(
                                  (given) => given == 'DPT',
                                );
                                final sudahCAMPAK = imunisasiGiven.any(
                                  (given) => given == 'CAMPAK',
                                );
                                return Row(
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 4.0,
                                      ),
                                      child:
                                          sudahDPT
                                              ? Chip(
                                                label: const Text('Sudah DPT'),
                                                backgroundColor:
                                                    Colors.green[200],
                                                avatar: const Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                  size: 18,
                                                ),
                                              )
                                              : Chip(
                                                label: const Text('Belum DPT'),
                                                backgroundColor:
                                                    Colors.grey[300],
                                                avatar: const Icon(
                                                  Icons.close,
                                                  color: Colors.grey,
                                                  size: 18,
                                                ),
                                              ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(
                                        right: 4.0,
                                      ),
                                      child:
                                          sudahCAMPAK
                                              ? Chip(
                                                label: const Text(
                                                  'Sudah CAMPAK',
                                                ),
                                                backgroundColor:
                                                    Colors.green[200],
                                                avatar: const Icon(
                                                  Icons.check,
                                                  color: Colors.green,
                                                  size: 18,
                                                ),
                                              )
                                              : Chip(
                                                label: const Text(
                                                  'Belum CAMPAK',
                                                ),
                                                backgroundColor:
                                                    Colors.grey[300],
                                                avatar: const Icon(
                                                  Icons.close,
                                                  color: Colors.grey,
                                                  size: 18,
                                                ),
                                              ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('NIK: ${balita.nik}\nIbu: ${balita.namaIbu}'),
                      ],
                    ),
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
