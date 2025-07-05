import 'package:flutter/material.dart';
import 'package:flutter_application_1/API/KunjunganBalitaService.dart';
import 'package:flutter_application_1/models/KunjunganBalitaModel.dart';
import 'package:flutter_application_1/models/balitaModel.dart';
import 'package:flutter_application_1/widgets/login_background.dart';
import 'package:intl/intl.dart';

class RiwayatKunjunganScreen extends StatefulWidget {
  final BalitaModel balita;
  const RiwayatKunjunganScreen({super.key, required this.balita});

  @override
  State<RiwayatKunjunganScreen> createState() => _RiwayatKunjunganScreenState();
}

class _RiwayatKunjunganScreenState extends State<RiwayatKunjunganScreen> {
  final Kunjunganbalitaservice _kunjunganService = Kunjunganbalitaservice();
  late Future<List<KunjunganModel>> _riwayatKunjungan;

  @override
  void initState() {
    super.initState();
    _riwayatKunjungan = _fetchRiwayat();
  }

  // Helper untuk memanggil service dan memastikan tipe data yang kembali benar
  Future<List<KunjunganModel>> _fetchRiwayat() async {
    // Memanggil fungsi lama yang tidak mengembalikan nilai
    await _kunjunganService.GetKunjunganbalitaByBalita(widget.balita.id!);
    // Mengembalikan hasil dari variabel global yang diisi oleh fungsi di atas
    return List<KunjunganModel>.from(KunjunganList);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat ${widget.balita.nama}'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const LoginBackground(),
          FutureBuilder<List<KunjunganModel>>(
            future: _riwayatKunjungan,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Gagal memuat riwayat: ${snapshot.error}',
                    style: const TextStyle(color: Colors.red),
                    textAlign: TextAlign.center,
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada riwayat kunjungan.',
                    style: TextStyle(fontSize: 16),
                  ),
                );
              }

              final riwayatList = snapshot.data!;
              // Urutkan riwayat berdasarkan tanggal, dari yang terbaru ke terlama
              riwayatList.sort(
                (a, b) => b.tanggalKunjungan.compareTo(a.tanggalKunjungan),
              );
              return Column(
                children: [
                  SizedBox(
                    height:
                        kToolbarHeight +
                        MediaQuery.of(context).padding.top +
                        20,
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Card(
                      color: Colors.blue.shade100.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.calendar_today,
                              size: 40,
                              color: Colors.blue,
                            ),
                            const SizedBox(width: 16),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Total Kunjungan',
                                  style: TextStyle(fontSize: 16),
                                ),
                                Text(
                                  '${riwayatList.length} kali',
                                  style: Theme.of(
                                    context,
                                  ).textTheme.headlineSmall?.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.blue.shade800,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  Expanded(
                    child: ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: riwayatList.length,
                      itemBuilder: (context, index) {
                        final kunjungan = riwayatList[index];
                        return Card(
                          margin: const EdgeInsets.only(bottom: 16.0),
                          color: Colors.white.withOpacity(0.9),
                          child: ListTile(
                            isThreeLine: true,
                            leading: CircleAvatar(child: Text('${index + 1}')),
                            title: Text(
                              'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(kunjungan.tanggalKunjungan)}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'BB: ${kunjungan.beratBadan} kg, TB: ${kunjungan.tinggiBadan} cm\nStatus: ${kunjungan.statusGizi}, Rambu: ${kunjungan.rambuGizi}',
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
