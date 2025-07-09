import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Balita_Form_Screen.dart';
import 'package:intl/intl.dart';

// Import services, models, dan file yang relevan
import '../API/ImunisasiService.dart';
import '../API/KunjunganBalitaService.dart';
import '../API/kematianService.dart';
import '../API/BalitaService.dart';
import '../models/KunjunganBalitaModel.dart';
import '../models/kematian.dart';
import '../models/imunisasi.dart';
import '../models/balitaModel.dart';
import './Pemeriksaan/KunjunganFormScreen.dart';
import './Pemeriksaan/KematianFormScreen.dart';
import './Pemeriksaan/imunisasi_form_screen.dart';
import '../widgets/login_background.dart';

// Kelas Enum dan Data Wrapper
enum JenisPemeriksaan { imunisasi, kunjungan, kematian }

class PemeriksaanItem {
  final DateTime tanggal;
  final String jenis;
  final dynamic data;
  PemeriksaanItem({
    required this.tanggal,
    required this.jenis,
    required this.data,
  });
}

class BalitaDetailData {
  final List<KunjunganModel> riwayatKunjungan;
  final List<Imunisasi> riwayatImunisasi;
  final Kematian? dataKematian;
  BalitaDetailData({
    required this.riwayatKunjungan,
    required this.riwayatImunisasi,
    this.dataKematian,
  });
}

// Widget Utama
class BalitaDetailScreen extends StatefulWidget {
  final BalitaModel balita;
  const BalitaDetailScreen({super.key, required this.balita});

  @override
  State<BalitaDetailScreen> createState() => _BalitaDetailScreenState();
}

class _BalitaDetailScreenState extends State<BalitaDetailScreen> {
  // State
  late BalitaModel _currentBalita;
  late Future<BalitaDetailData> _detailData;

  // Services
  final Kunjunganbalitaservice _kunjunganService = Kunjunganbalitaservice();
  final KematianService _kematianService = KematianService();
  final ImunisasiService _imunisasiService = ImunisasiService();
  final Balitaservice _balitaService = Balitaservice();

  @override
  void initState() {
    super.initState();
    _currentBalita = widget.balita;
    Intl.defaultLocale = 'id_ID';
    _detailData = _fetchData();
  }

  // --- LOGIKA DATA ---
  Future<void> _refreshData() async {
    if (mounted) {
      setState(() {
        _detailData = _fetchData();
      });
    }
  }

  Future<BalitaDetailData> _fetchData() async {
    final results = await Future.wait([
      _balitaService.GetBalitaData(_currentBalita.id!),
      _kunjunganService.GetKunjunganbalitaByBalita(_currentBalita.id!),
      _imunisasiService.getImunisasiByBalita(_currentBalita.id!),
      _kematianService.getKematian(_currentBalita.id!),
    ]);

    final balitaTerbaru = results[0] as BalitaModel;
    if (mounted) {
      setState(() {
        _currentBalita = balitaTerbaru;
      });
    }

    return BalitaDetailData(
      riwayatKunjungan:
          (results[1] as List<KunjunganModel>)
            ..sort((a, b) => b.tanggalKunjungan.compareTo(a.tanggalKunjungan)),
      riwayatImunisasi:
          (results[2] as List<Imunisasi>)
            ..sort((a, b) => b.tanggalImunisasi.compareTo(a.tanggalImunisasi)),
      dataKematian: results[3] as Kematian?,
    );
  }

  List<PemeriksaanItem> _gabungkanDanUrutkanRiwayat(BalitaDetailData data) {
    final semuaRiwayat = [
      if (data.dataKematian != null)
        PemeriksaanItem(
          tanggal: data.dataKematian!.tanggalKematian,
          jenis: 'Kematian',
          data: data.dataKematian!,
        ),
      ...data.riwayatKunjungan.map(
        (k) => PemeriksaanItem(
          tanggal: k.tanggalKunjungan,
          jenis: 'Kunjungan',
          data: k,
        ),
      ),
      ...data.riwayatImunisasi.map(
        (i) => PemeriksaanItem(
          tanggal: i.tanggalImunisasi,
          jenis: 'Imunisasi',
          data: i,
        ),
      ),
    ];
    semuaRiwayat.sort((a, b) => b.tanggal.compareTo(a.tanggal));
    return semuaRiwayat;
  }

  // --- LOGIKA AKSI (EDIT, DELETE, TAMBAH) ---
  Future<void> _lakukanPemeriksaan() async {
    final jenis = await showDialog<JenisPemeriksaan>(
      context: context,
      builder:
          (context) => SimpleDialog(
            title: const Text('Pilih Jenis Pemeriksaan'),
            children: [
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
                    () => Navigator.pop(context, JenisPemeriksaan.imunisasi),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Text('Imunisasi'),
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
          ),
    );

    if (jenis == null || !mounted) return;
    final Widget nextPage = switch (jenis) {
      JenisPemeriksaan.kunjungan => KunjunganFormScreen(balita: _currentBalita),
      JenisPemeriksaan.imunisasi => ImunisasiFormScreen(balita: _currentBalita),
      JenisPemeriksaan.kematian => KematianFormScreen(balita: _currentBalita),
    };
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
    if (result == true) _refreshData();
  }

  Future<void> _deleteBalita() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Hapus Balita'),
            content: Text(
              'Anda yakin ingin menghapus data balita "${_currentBalita.nama}"?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
    if (confirm == true && mounted) {
      try {
        await _balitaService.DeleteBalita(_currentBalita.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Data balita berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop(true);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BalitaDetailData>(
      future: _detailData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Memuat...')),
            body: const Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasError) {
          return Scaffold(
            appBar: AppBar(title: Text('Error')),
            body: Center(child: Text('Gagal memuat data: ${snapshot.error}')),
          );
        }
        if (!snapshot.hasData) {
          return Scaffold(
            appBar: AppBar(title: Text('Tidak Ditemukan')),
            body: const Center(child: Text('Data tidak ditemukan.')),
          );
        }

        final detailData = snapshot.data!;
        final bool isDeceased =
            _currentBalita.tanggalKematian != null ||
            detailData.dataKematian != null;
        String appBarTitle = 'Detail ${_currentBalita.nama}';
        if (isDeceased) {
          appBarTitle += ' (Meninggal)';
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(appBarTitle),
            actions: [
              IconButton(
                icon: const Icon(Icons.refresh),
                tooltip: 'Refresh Data',
                onPressed: _refreshData,
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _refreshData,
            child: _buildContent(detailData),
          ),
          floatingActionButton:
              isDeceased
                  ? null
                  : FloatingActionButton(
                    onPressed: _lakukanPemeriksaan,
                    tooltip: 'Lakukan Pemeriksaan',
                    child: const Icon(Icons.checklist_rtl),
                  ),
        );
      },
    );
  }

  Widget _buildContent(BalitaDetailData data) {
    return Stack(
      children: [
        const LoginBackground(),
        ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            // Kirim objek Kematian langsung ke widget info dasar
            _buildInfoDasar(dataKematian: data.dataKematian),
            const SizedBox(height: 16),

            // Hanya tampilkan ringkasan jika balita masih hidup
            if (data.dataKematian == null) ...[
              _buildRingkasanPemeriksaanTerakhir(
                jenis: 'Kunjungan',
                riwayat: data.riwayatKunjungan,
                color: Colors.blue,
              ),
              const SizedBox(height: 16),
              _buildRingkasanPemeriksaanTerakhir(
                jenis: 'Imunisasi',
                riwayat: data.riwayatImunisasi,
                color: Colors.green,
              ),
              const SizedBox(height: 16),
            ],
            _buildSemuaRiwayatPemeriksaan(_gabungkanDanUrutkanRiwayat(data)),
          ],
        ),
      ],
    );
  }

  // --- WIDGET HELPER ---

  // <-- PERUBAHAN UTAMA DI SINI -->
  Widget _buildInfoDasar({required Kematian? dataKematian}) {
    final balita = _currentBalita;
    final bool isDeceased = dataKematian != null;

    return Card(
      color: isDeceased ? Colors.red.withOpacity(0.05) : null,
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Text(
                    balita.nama,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: isDeceased ? Colors.red.shade700 : null,
                    ),
                  ),
                ),
                if (!isDeceased)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        tooltip: 'Edit Balita',
                        onPressed: () async {
                          final result = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (context) => BalitaFormScreen(
                                    posyanduId: _currentBalita.posyanduId,
                                    balita: _currentBalita,
                                  ),
                            ),
                          );
                          if (result != null &&
                              result is BalitaModel &&
                              mounted) {
                            setState(() {
                              _currentBalita = result;
                            });
                            _refreshData();
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: _deleteBalita,
                        tooltip: 'Hapus Balita',
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(),

            // Tampilkan detail kematian secara eksplisit di atas jika ada
            if (isDeceased) ...[
              Text(
                'Telah Meninggal Dunia',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.red.shade700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tanggal: ${DateFormat('dd MMMM yyyy').format(dataKematian!.tanggalKematian)}',
              ),
              Text('Penyebab: ${dataKematian.penyebab ?? "Tidak dicatat"}'),
              const Divider(),
            ],

            Text('NIK: ${balita.nik}'),
            Text('Nama Ibu: ${balita.namaIbu}'),
            Text(
              'Tgl Lahir: ${DateFormat('dd MMMM yyyy').format(balita.tanggalLahir)}',
            ),
            Text(
              'Jenis Kelamin: ${balita.jenisKelamin == "L" ? "Laki-laki" : "Perempuan"}',
            ),
            Text('Alamat: ${balita.alamat}'),
            Text('Buku KIA: ${balita.bukuKIA}'),
          ],
        ),
      ),
    );
  }

  Widget _buildRingkasanPemeriksaanTerakhir({
    required String jenis,
    required List<dynamic> riwayat,
    required Color color,
  }) {
    if (riwayat.isEmpty) {
      return Card(child: ListTile(title: Text("Belum ada riwayat $jenis.")));
    }
    final itemTerbaru = riwayat.first;
    final tanggal =
        jenis == 'Kunjungan'
            ? (itemTerbaru as KunjunganModel).tanggalKunjungan
            : (itemTerbaru as Imunisasi).tanggalImunisasi;
    final detail =
        jenis == 'Kunjungan'
            ? 'Berat: ${itemTerbaru.beratBadan} kg, Tinggi: ${itemTerbaru.tinggiBadan} cm'
            : 'Jenis: ${itemTerbaru.jenisImunisasi}';
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '$jenis Terakhir',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            Text('Tanggal: ${DateFormat('dd MMM yyyy').format(tanggal)}'),
            Text(detail),
          ],
        ),
      ),
    );
  }

  Widget _buildSemuaRiwayatPemeriksaan(List<PemeriksaanItem> riwayat) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Riwayat Gabungan',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Divider(),
            if (riwayat.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.all(8.0),
                  child: Text('Tidak ada data riwayat.'),
                ),
              )
            else
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: riwayat.length,
                itemBuilder:
                    (context, index) =>
                        _buildPemeriksaanListTile(riwayat[index]),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPemeriksaanListTile(PemeriksaanItem item) {
    final bool isKematian = item.jenis == 'Kematian';
    final IconData iconData;
    final Color color;
    String subtitle;
    String title =
        '${item.jenis} - ${DateFormat('dd MMMM yyyy').format(item.tanggal)}';

    if (isKematian) {
      final kematian = item.data as Kematian;
      iconData = Icons.report_off_outlined;
      color = Colors.red.shade800;
      title = 'Data Kematian Dicatat';
      subtitle = 'Penyebab: ${kematian.penyebab ?? 'Tidak diketahui'}';
    } else if (item.jenis == 'Kunjungan') {
      final k = item.data as KunjunganModel;
      iconData = Icons.medical_services_outlined;
      color = Colors.blue;
      subtitle = 'BB: ${k.beratBadan} kg, TB: ${k.tinggiBadan} cm';
    } else {
      // Imunisasi
      final i = item.data as Imunisasi;
      iconData = Icons.vaccines;
      color = Colors.green;
      subtitle = 'Jenis: ${i.jenisImunisasi}';
    }
    return ListTile(
      leading: Icon(iconData, color: color),
      title: Text(
        title,
        style:
            isKematian
                ? TextStyle(fontWeight: FontWeight.bold, color: color)
                : null,
      ),
      subtitle: Text(subtitle),
    );
  }
}
