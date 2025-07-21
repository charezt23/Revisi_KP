import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/posyanduModel.dart';
import 'package:flutter_application_1/data/API/BalitaService.dart';
import 'package:flutter_application_1/data/API/KunjunganBalitaService.dart';
import 'package:flutter_application_1/data/models/balitaModel.dart';
import 'package:flutter_application_1/presentation/screens/balita_detail_screen.dart';
import 'package:flutter_application_1/presentation/screens/components/loading_indicator.dart';
import 'package:flutter_application_1/presentation/screens/components/login_background.dart';

class KunjunganBalitaScreen extends StatefulWidget {
  final PosyanduModel posyandu;
  const KunjunganBalitaScreen({super.key, required this.posyandu});

  @override
  State<KunjunganBalitaScreen> createState() => _KunjunganBalitaScreenState();
}

class _KunjunganBalitaScreenState extends State<KunjunganBalitaScreen> {
  final Balitaservice _balitaService = Balitaservice();
  final Kunjunganbalitaservice _kunjunganService = Kunjunganbalitaservice();
  late Future<List<BalitaModel>> _balitaList;

  @override
  void initState() {
    super.initState();
    _balitaList = _balitaService.GetBalitaByPosyandu(widget.posyandu.id!);
  }

  Future<int> _getKunjunganCount(int balitaId) async {
    final kunjungan = await _kunjunganService.GetKunjunganbalitaByBalita(
      balitaId,
    );
    return kunjungan.length;
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const LoginBackground(),
        Scaffold(
          backgroundColor: Colors.white.withOpacity(0.9),
          appBar: AppBar(
            title: const Text(
              'Daftar Kunjungan Balita',
              style: TextStyle(color: Colors.white),
            ),
            backgroundColor: Colors.purple,
            leading: IconButton(
              icon: const Icon(
                Icons.arrow_back_ios,
                color: Colors.white,
                size: 20,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: FutureBuilder<List<BalitaModel>>(
            future: _balitaList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: LoadingIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text('Gagal memuat data: ${snapshot.error}'),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(child: Text('Belum ada data balita.'));
              }
              final balitaList = snapshot.data!;
              return ListView.builder(
                itemCount: balitaList.length,
                itemBuilder: (context, index) {
                  final balita = balitaList[index];
                  return Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    color: Colors.white,
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(16),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BalitaDetailScreen(balita: balita),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 16,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.purple[50],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              padding: const EdgeInsets.all(8),
                              child: const Icon(
                                Icons.event_note,
                                color: Colors.purple,
                                size: 44,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    balita.nama,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                      color: Colors.black,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    'NIK: ${balita.nik}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    'Ibu: ${balita.namaIbu}',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[700],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            FutureBuilder<int>(
                              future: _getKunjunganCount(balita.id!),
                              builder: (context, snap) {
                                if (snap.connectionState ==
                                    ConnectionState.waiting) {
                                  return const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                    ),
                                  );
                                }
                                if (snap.hasError) {
                                  return const Text('-');
                                }
                                return Column(
                                  children: [
                                    Chip(
                                      label: Text(
                                        'Kunjungan: ${snap.data ?? 0}',
                                      ),
                                      backgroundColor: Colors.purple[100],
                                    ),
                                    const SizedBox(height: 8),
                                    const Icon(
                                      Icons.chevron_right,
                                      color: Colors.purple,
                                      size: 32,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}
