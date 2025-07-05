import 'package:flutter/material.dart';
import 'package:flutter_application_1/API/KunjunganBalitaService.dart';
import 'package:flutter_application_1/models/KunjunganBalitaModel.dart';
import 'package:flutter_application_1/models/balitaModel.dart';
import 'package:flutter_application_1/screens/Pemeriksaan/KunjunganFormScreen.dart';
import 'package:flutter_application_1/screens/Pemeriksaan/KematianFormScreen.dart';
import 'package:flutter_application_1/screens/pemeriksaan/imunisasi_form_screen.dart';
import 'package:flutter_application_1/widgets/login_background.dart';
import 'package:intl/intl.dart';

// TODO: Hapus import ini setelah semua screen pemeriksaan diubah ke BalitaModel
import 'package:flutter_application_1/models/anggota_model.dart';

enum JenisPemeriksaan { imunisasi, kunjungan, kematian }

class BalitaDetailScreen extends StatefulWidget {
  final BalitaModel balita;
  const BalitaDetailScreen({super.key, required this.balita});

  @override
  State<BalitaDetailScreen> createState() => _BalitaDetailScreenState();
}

class _BalitaDetailScreenState extends State<BalitaDetailScreen> {
  final Kunjunganbalitaservice _kunjunganService = Kunjunganbalitaservice();
  late Future<List<KunjunganModel>> _riwayatKunjungan;

  @override
  void initState() {
    super.initState();
    _updateRiwayat();
  }

  // Helper untuk memanggil service dan memastikan tipe data yang kembali benar
  Future<List<KunjunganModel>> _fetchRiwayat() async {
    // Memanggil fungsi lama yang tidak mengembalikan nilai
    await _kunjunganService.GetKunjunganbalitaByBalita(widget.balita.id!);
    // Mengembalikan hasil dari variabel global yang diisi oleh fungsi di atas
    return List<KunjunganModel>.from(KunjunganList);
  }

  void _updateRiwayat() {
    setState(() {
      // Menggunakan helper baru yang sudah memiliki tipe data yang benar
      _riwayatKunjungan = _fetchRiwayat();
    });
  }

  // Fungsi untuk menampilkan pop-up pilihan jenis pemeriksaan
  void _lakukanPemeriksaan() async {
    final JenisPemeriksaan? jenisTerpilih = await showDialog<JenisPemeriksaan>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Pilih Jenis Pemeriksaan'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, JenisPemeriksaan.imunisasi);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Imunisasi'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, JenisPemeriksaan.kunjungan);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Kunjungan'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, JenisPemeriksaan.kematian);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Kematian'),
              ),
            ),
          ],
        );
      },
    );

    if (jenisTerpilih == null || !mounted) return;

    final balita = widget.balita;
    // Jembatan sementara: Membuat objek Anggota dari BalitaModel
    final anggotaDummy = Anggota(
      id: balita.id,
      kohortId: balita.posyanduId,
      nama: balita.nama,
      keterangan: 'NIK: ${balita.nik}',
      riwayatPenyakit: '',
    );

    Widget? nextPage;
    switch (jenisTerpilih) {
      case JenisPemeriksaan.imunisasi:
        nextPage = ImunisasiFormScreen(anggota: anggotaDummy);
        break;
      case JenisPemeriksaan.kunjungan:
        nextPage = KunjunganFormScreen(balita: balita);
        break;
      case JenisPemeriksaan.kematian:
        nextPage = KematianFormScreen(anggota: anggotaDummy);
        break;
    }

    if (nextPage != null) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => nextPage!),
      ).then((_) => _updateRiwayat());
    }
    ;
  }

  // --- Widget Helper untuk merapikan kode ---

  Widget _buildInfoDasar() {
    final balita = widget.balita;
    String jenisKelaminLengkap = '-';
    if (balita.jenisKelamin == 'L') {
      jenisKelaminLengkap = 'Laki-laki';
    } else if (balita.jenisKelamin == 'P') {
      jenisKelaminLengkap = 'Perempuan';
    }

    return Card(
      color: Colors.white.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(balita.nama, style: Theme.of(context).textTheme.headlineSmall),
            const Divider(),
            const SizedBox(height: 8),
            Text('NIK: ${balita.nik}'),
            Text('Nama Ibu: ${balita.namaIbu}'),
            Text(
              'Tanggal Lahir: ${DateFormat('dd MMMM yyyy', 'id_ID').format(balita.tanggalLahir)}',
            ),
            Text('Jenis Kelamin: $jenisKelaminLengkap'),
            Text('Alamat: ${balita.alamat}'),
            Text('Buku KIA: ${balita.bukuKIA == 'ada' ? 'Ada' : 'Tidak Ada'}'),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSaatIni(KunjunganModel? kunjunganTerbaru) {
    if (kunjunganTerbaru == null) {
      return Card(
        color: Colors.white.withOpacity(0.85),
        child: const ListTile(
          title: Text('Status Pemeriksaan Terakhir'),
          subtitle: Text('Belum ada data pemeriksaan.'),
        ),
      );
    }

    return Card(
      color: Colors.blue.shade50.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Kunjungan Terakhir (${DateFormat('dd MMM yyyy', 'id_ID').format(kunjunganTerbaru.tanggalKunjungan)})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            Text('Berat Badan: ${kunjunganTerbaru.beratBadan} kg'),
            Text('Tinggi Badan: ${kunjunganTerbaru.tinggiBadan} cm'),
            Text('Status Gizi: ${kunjunganTerbaru.statusGizi}'),
            Text('Rambu Gizi: ${kunjunganTerbaru.rambuGizi}'),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayat(List<KunjunganModel> riwayat) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Judul dikembalikan menjadi Text biasa
        Text(
          'Riwayat Pemeriksaan',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 8),
        if (riwayat.isEmpty)
          const Text('Tidak ada riwayat.')
        else
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: riwayat.length,
            itemBuilder: (context, index) {
              final kunjungan = riwayat[index];
              return Card(
                color: Colors.white.withOpacity(0.85),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    DateFormat(
                      'dd MMMM yyyy',
                      'id_ID',
                    ).format(kunjungan.tanggalKunjungan),
                  ),
                  subtitle: Text(
                    'BB: ${kunjungan.beratBadan} kg, TB: ${kunjungan.tinggiBadan} cm',
                  ),
                ),
              );
            },
          ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail ${widget.balita.nama}')),
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
                  child: Text('Gagal memuat data: ${snapshot.error}'),
                );
              }
              // Urutkan riwayat berdasarkan tanggal, dari yang terbaru ke terlama
              final riwayat = snapshot.data ?? [];
              riwayat.sort(
                (a, b) => b.tanggalKunjungan.compareTo(a.tanggalKunjungan),
              );
              final kunjunganTerbaru =
                  riwayat.isNotEmpty ? riwayat.first : null;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoDasar(),
                    const SizedBox(height: 16),
                    _buildStatusSaatIni(kunjunganTerbaru),
                    const SizedBox(height: 24),
                    _buildRiwayat(riwayat),
                  ],
                ),
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _lakukanPemeriksaan,
        tooltip: 'Lakukan Pemeriksaan',
        child: const Icon(Icons.checklist_rtl),
      ),
    );
  }
}
