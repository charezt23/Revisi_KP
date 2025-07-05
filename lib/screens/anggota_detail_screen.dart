import 'package:flutter/material.dart';
import 'package:flutter_application_1/databse/dummy_data_service.dart';
import 'package:flutter_application_1/widgets/login_background.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/models/anggota_model.dart';
import 'package:flutter_application_1/models/pemeriksaan_model.dart';
import 'package:flutter_application_1/screens/catatan_kesehatan_form_screen.dart';

class AnggotaDetailScreen extends StatefulWidget {
  final Anggota anggota;
  const AnggotaDetailScreen({super.key, required this.anggota});

  @override
  State<AnggotaDetailScreen> createState() => _AnggotaDetailScreenState();
}

class _AnggotaDetailScreenState extends State<AnggotaDetailScreen> {
  late Future<List<Pemeriksaan>> _riwayatPemeriksaan;

  @override
  void initState() {
    super.initState();
    _updateRiwayatPemeriksaan();
  }

  void _updateRiwayatPemeriksaan() {
    setState(() {
      // Asumsi: DummyDataService memiliki method getPemeriksaanList
      // yang mengembalikan data pemeriksaan untuk anakId tertentu
      _riwayatPemeriksaan = DummyDataService().getPemeriksaanList(
        widget.anggota.id!,
      );
    });
  }

  // --- Widget Helper untuk merapikan kode ---

  Widget _buildInfoDasar() {
    final anggota = widget.anggota;
    String jenisKelaminLengkap = '-';
    if (anggota.jenisKelamin == 'L') {
      jenisKelaminLengkap = 'Laki-laki';
    } else if (anggota.jenisKelamin == 'P') {
      jenisKelaminLengkap = 'Perempuan';
    }

    return Card(
      color: Colors.white.withOpacity(0.85),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              anggota.nama,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const Divider(),
            const SizedBox(height: 8),
            Text('NIK: ${anggota.nik ?? '-'}'),
            Text(
              'Tanggal Lahir: ${anggota.tanggalLahir != null ? DateFormat('dd MMMM yyyy').format(anggota.tanggalLahir!) : '-'}',
            ),
            Text('Jenis Kelamin: $jenisKelaminLengkap'),
            if (anggota.namaOrangTua != null &&
                anggota.namaOrangTua!.isNotEmpty)
              Text('Nama Orang Tua: ${anggota.namaOrangTua}'),
            Text('Alamat: ${anggota.alamat ?? '-'}'),
            const SizedBox(height: 8),
            const Divider(),
            Text(
              'Riwayat Penyakit: ${anggota.riwayatPenyakit.isNotEmpty ? anggota.riwayatPenyakit : '-'}',
            ),
            Text(
              'Keterangan Tambahan: ${anggota.keterangan.isNotEmpty ? anggota.keterangan : '-'}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSaatIni(Pemeriksaan? pemeriksaanTerbaru) {
    if (pemeriksaanTerbaru == null) {
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
              'Status Terbaru (${DateFormat('dd MMM yyyy').format(pemeriksaanTerbaru.tanggalPemeriksaan)})',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            Text('Berat Badan: ${pemeriksaanTerbaru.beratBadan} kg'),
            Text('Tinggi Badan: ${pemeriksaanTerbaru.tinggiBadan} cm'),
            Text(
              'Keterangan: ${pemeriksaanTerbaru.keterangan.isNotEmpty ? pemeriksaanTerbaru.keterangan : '-'}',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRiwayat(List<Pemeriksaan> riwayat) {
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
              final pemeriksaan = riwayat[index];
              return Card(
                color: Colors.white.withOpacity(0.85),
                margin: const EdgeInsets.symmetric(vertical: 4),
                child: ListTile(
                  title: Text(
                    DateFormat(
                      'dd MMMM yyyy',
                    ).format(pemeriksaan.tanggalPemeriksaan),
                  ),
                  subtitle: Text(
                    'BB: ${pemeriksaan.beratBadan} kg, TB: ${pemeriksaan.tinggiBadan} cm',
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
      appBar: AppBar(title: const Text('Detail Anggota')),
      body: Stack(
        children: [
          const LoginBackground(),
          FutureBuilder<List<Pemeriksaan>>(
            future: _riwayatPemeriksaan,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData) {
                return const Center(child: Text('Gagal memuat data.'));
              }
              final riwayat = snapshot.data!;
              final pemeriksaanTerbaru = riwayat.isNotEmpty
                  ? riwayat.first
                  : null;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildInfoDasar(),
                    const SizedBox(height: 16),
                    _buildStatusSaatIni(pemeriksaanTerbaru),
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
        onPressed: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) =>
                PemeriksaanFormScreen(anggotaId: widget.anggota.id!),
          ),
        ).then((_) => _updateRiwayatPemeriksaan()),
        tooltip: 'Tambah Pemeriksaan',
        child: const Icon(Icons.add_chart),
      ),
    );
  }
}
