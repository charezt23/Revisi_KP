import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

// Ganti dengan path yang benar ke file service dan model Anda
import '../API/KunjunganBalitaService.dart';
import '../API/kematianService.dart';
import '../models/KunjunganBalitaModel.dart';
import '../models/kematian.dart';
import '../models/balitaModel.dart';
import '../models/anggota_model.dart';
import './Pemeriksaan/KunjunganFormScreen.dart';
import './Pemeriksaan/KematianFormScreen.dart';
import './pemeriksaan/imunisasi_form_screen.dart';
import '../widgets/login_background.dart';

enum JenisPemeriksaan { imunisasi, kunjungan, kematian }

// Wrapper class untuk menampung semua data yang di-fetch
class BalitaDetailData {
  final List<KunjunganModel> riwayatKunjungan;
  final Kematian? dataKematian;

  BalitaDetailData({required this.riwayatKunjungan, this.dataKematian});
}

class BalitaDetailScreen extends StatefulWidget {
  final BalitaModel balita;
  const BalitaDetailScreen({super.key, required this.balita});

  @override
  State<BalitaDetailScreen> createState() => _BalitaDetailScreenState();
}

class _BalitaDetailScreenState extends State<BalitaDetailScreen> {
  final Kunjunganbalitaservice _kunjunganService = Kunjunganbalitaservice();
  final KematianService _kematianService = KematianService();
  late Future<BalitaDetailData> _detailData;

  @override
  void initState() {
    super.initState();
    _updateData();
  }

  // Mengambil data dengan cara yang benar (tanpa Future.wait untuk tipe berbeda)
  Future<BalitaDetailData> _fetchData() async {
    // Panggil await satu per satu. Ini lebih aman dan jelas.
    final riwayatKunjungan = await _kunjunganService.GetKunjunganbalitaByBalita(
      widget.balita.id!,
    );
    final dataKematian = await _kematianService.getKematian(widget.balita.id!);

    return BalitaDetailData(
      riwayatKunjungan: riwayatKunjungan,
      dataKematian: dataKematian,
    );
  }

  void _updateData() {
    setState(() {
      _detailData = _fetchData();
    });
  }

  Future<void> _lakukanPemeriksaan() async {
    final JenisPemeriksaan? jenisTerpilih = await showDialog<JenisPemeriksaan>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Pilih Jenis Pemeriksaan'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed:
                  () => Navigator.pop(context, JenisPemeriksaan.imunisasi),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Imunisasi'),
              ),
            ),
            SimpleDialogOption(
              onPressed:
                  () => Navigator.pop(context, JenisPemeriksaan.kunjungan),
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Kunjungan'),
              ),
            ),
            SimpleDialogOption(
              onPressed:
                  () => Navigator.pop(context, JenisPemeriksaan.kematian),
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
      ).then((result) {
        // Hanya update data jika form ditutup dengan hasil 'true' (sukses).
        if (result == true) {
          _updateData();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Detail ${widget.balita.nama}')),
      body: FutureBuilder<BalitaDetailData>(
        future: _detailData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Gagal memuat data: ${snapshot.error}'));
          }

          if (!snapshot.hasData) {
            return const Center(child: Text('Data tidak ditemukan.'));
          }

          final detailData = snapshot.data!;
          final riwayat = detailData.riwayatKunjungan;
          final dataKematian = detailData.dataKematian;

          riwayat.sort(
            (a, b) => b.tanggalKunjungan.compareTo(a.tanggalKunjungan),
          );
          final kunjunganTerbaru = riwayat.isNotEmpty ? riwayat.first : null;

          return Stack(
            children: [
              const LoginBackground(),
              SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoDasar(),
                    const SizedBox(height: 16),
                    if (dataKematian != null)
                      _buildInfoKematian(dataKematian)
                    else ...[
                      _buildStatusSaatIni(kunjunganTerbaru),
                      const SizedBox(height: 24),
                      _buildRiwayat(riwayat),
                    ],
                  ],
                ),
              ),
            ],
          );
        },
      ),
      floatingActionButton: FutureBuilder<BalitaDetailData>(
        future: _detailData,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data!.dataKematian == null) {
            return FloatingActionButton(
              onPressed: _lakukanPemeriksaan,
              tooltip: 'Lakukan Pemeriksaan',
              child: const Icon(Icons.checklist_rtl),
            );
          }
          return const SizedBox.shrink();
        },
      ),
    );
  }

  // --- Widget Helper ---
  Widget _buildInfoDasar() {
    final balita = widget.balita;
    String jenisKelaminLengkap =
        (balita.jenisKelamin == 'L')
            ? 'Laki-laki'
            : (balita.jenisKelamin == 'P' ? 'Perempuan' : '-');

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

  Widget _buildInfoKematian(Kematian kematian) {
    return Card(
      color: Colors.grey.shade300,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Telah Meninggal Dunia',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(color: Colors.black87),
            ),
            const Divider(),
            Text(
              'Tanggal: ${DateFormat('dd MMMM yyyy', 'id_ID').format(kematian.tanggalKematian)}',
            ),
            Text('Penyebab: ${kematian.penyebab ?? 'Tidak diketahui'}'),
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
}
