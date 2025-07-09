import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/Balita_Form_Screen.dart';
import 'package:intl/intl.dart';
import 'dart:math';

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
    // Mengatur locale untuk format tanggal Indonesia
    Intl.defaultLocale = 'id_ID';
    _refreshData();
  }

  // --- LOGIKA DATA ---

  /// Fungsi utama untuk refresh data, sama seperti menekan ikon refresh.
  Future<void> _refreshData() async {
    if (mounted) {
      setState(() {
        _detailData = _fetchData();
      });
    }
    await _detailData;
  }

  /// Mengambil semua data dari API secara bersamaan.
  Future<BalitaDetailData> _fetchData() async {
    final results = await Future.wait([
      _balitaService.GetBalitaData(_currentBalita.id!),
      _kunjunganService.GetKunjunganbalitaByBalita(_currentBalita.id!),
      _imunisasiService.getImunisasiByBalita(_currentBalita.id!),
      _kematianService.getKematian(_currentBalita.id!),
    ]);

    final balitaTerbaru = results[0] as BalitaModel;
    final riwayatKunjungan = results[1] as List<KunjunganModel>;
    final riwayatImunisasi = results[2] as List<Imunisasi>;
    final dataKematian = results[3] as Kematian?;

    // Perbarui state balita jika ada perubahan nama/NIK
    if (mounted &&
        (balitaTerbaru.nama != _currentBalita.nama ||
            balitaTerbaru.nik != _currentBalita.nik)) {
      setState(() {
        _currentBalita = balitaTerbaru;
      });
    }

    // Kembalikan semua data yang sudah diurutkan
    return BalitaDetailData(
      riwayatKunjungan:
          riwayatKunjungan
            ..sort((a, b) => b.tanggalKunjungan.compareTo(a.tanggalKunjungan)),
      riwayatImunisasi:
          riwayatImunisasi
            ..sort((a, b) => b.tanggalImunisasi.compareTo(a.tanggalImunisasi)),
      dataKematian: dataKematian,
    );
  }

  // --- LOGIKA AKSI (EDIT, DELETE, TAMBAH) ---

  /// Menampilkan dialog untuk memilih jenis pemeriksaan baru.
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

    // Buka form dan tunggu hasilnya.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
    // Jika form ditutup dengan sinyal 'true', maka refresh data.
    if (result == true) {
      _refreshData();
    }
  }

  /// Menghapus data balita secara keseluruhan.
  Future<void> _deleteBalita() async {
    final bool? confirm = await _showConfirmationDialog(
      'Hapus Balita',
      'Anda yakin ingin menghapus data balita "${_currentBalita.nama}"? Tindakan ini tidak dapat diurungkan.',
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

  /// Menangani aksi edit atau hapus pada setiap item riwayat.
  Future<void> _handlePemeriksaanAction({
    required PemeriksaanItem item,
    required bool isEdit,
  }) async {
    // --- LOGIKA UNTUK EDIT ---
    if (isEdit) {
      Widget? nextPage;
      if (item.jenis == 'Kunjungan') {
        nextPage = KunjunganFormScreen(
          balita: _currentBalita,
          kunjunganToEdit: item.data as KunjunganModel,
        );
      } else if (item.jenis == 'Imunisasi') {
        nextPage = ImunisasiFormScreen(
          balita: _currentBalita,
          imunisasiToEdit: item.data as Imunisasi,
        );
      } else if (item.jenis == 'Kematian') {
        nextPage = KematianFormScreen(
          balita: _currentBalita,
          kematianToEdit: item.data as Kematian,
        );
      }

      if (nextPage != null && mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => nextPage!),
        );
        // Jika form edit ditutup dengan sinyal 'true', maka refresh data.
        if (result == true) {
          _refreshData();
        }
      }
    }
    // --- LOGIKA UNTUK HAPUS ---
    else {
      final bool? confirm = await _showConfirmationDialog(
        'Hapus Riwayat',
        'Anda yakin ingin menghapus riwayat ${item.jenis} ini?',
      );
      if (confirm == true && mounted) {
        try {
          bool success = false;
          if (item.jenis == 'Kunjungan') {
            success = await _kunjunganService.deleteKunjungan(item.data.id!);
          } else if (item.jenis == 'Imunisasi') {
            success = await _imunisasiService.deleteImunisasi(item.data.id!);
          } else if (item.jenis == 'Kematian') {
            success = await _kematianService.deleteKematian(item.data.id!);
          }

          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Riwayat ${item.jenis} berhasil dihapus.'),
                backgroundColor: Colors.green,
              ),
            );
            // Langsung refresh data setelah berhasil hapus.
            _refreshData();
          } else {
            throw Exception('Gagal menghapus dari service.');
          }
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
  }

  /// Menampilkan dialog konfirmasi sebelum menghapus.
  Future<bool?> _showConfirmationDialog(String title, String content) {
    return showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(title),
            content: Text(content),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Batal'),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: const Text('Hapus', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
    );
  }

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BalitaDetailData>(
      future: _detailData,
      builder: (context, snapshot) {
        Widget body;
        String appBarTitle = 'Detail ${_currentBalita.nama}';
        bool isDeceased = false;
        Widget? fab;

        if (snapshot.connectionState == ConnectionState.waiting) {
          body = const Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          body = Center(child: Text('Gagal memuat data: ${snapshot.error}'));
        } else if (!snapshot.hasData || snapshot.data == null) {
          body = const Center(child: Text('Data tidak ditemukan.'));
        } else {
          final detailData = snapshot.data!;
          isDeceased = detailData.dataKematian != null;
          if (isDeceased) {
            appBarTitle += ' (Meninggal)';
          }
          body = RefreshIndicator(
            onRefresh: _refreshData,
            child: _buildContent(detailData),
          );
          if (!isDeceased) {
            fab = FloatingActionButton(
              onPressed: _lakukanPemeriksaan,
              tooltip: 'Lakukan Pemeriksaan',
              child: const Icon(Icons.checklist_rtl),
            );
          }
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
          body: body,
          floatingActionButton: fab,
        );
      },
    );
  }

  Widget _buildContent(BalitaDetailData data) {
    final isDeceased = data.dataKematian != null;
    // Menggabungkan semua riwayat menjadi satu list untuk ditampilkan berurutan
    final semuaRiwayat = [
      if (isDeceased)
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
    ]..sort((a, b) => b.tanggal.compareTo(a.tanggal));

    return Stack(
      children: [
        const LoginBackground(),
        ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildInfoDasar(isDeceased: isDeceased),
            const SizedBox(height: 16),
            if (!isDeceased) ...[
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
            _buildSemuaRiwayatPemeriksaan(semuaRiwayat),
          ],
        ),
      ],
    );
  }

  // --- WIDGET HELPER ---

  Widget _buildInfoDasar({bool isDeceased = false}) {
    final balita = _currentBalita;
    String jenisKelaminLengkap =
        (balita.jenisKelamin == 'L') ? 'Laki-laki' : 'Perempuan';
    String statusBukuKIA =
        (balita.bukuKIA.toLowerCase() == 'ada') ? 'Ada' : 'Tidak Ada';

    return Card(
      color: isDeceased ? Colors.grey.shade200 : null,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    balita.nama,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                ),
                if (!isDeceased)
                  Row(
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
                          // Pola konsisten: panggil refresh jika form sukses
                          if (result == true && mounted) {
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
            Text('NIK: ${balita.nik}'),
            Text('Nama Ibu: ${balita.namaIbu}'),
            Text(
              'Tgl Lahir: ${DateFormat('dd MMMM yyyy').format(balita.tanggalLahir)}',
            ),
            Text('Jenis Kelamin: $jenisKelaminLengkap'),
            Text('Alamat: ${balita.alamat}'),
            Text('Buku KIA: $statusBukuKIA'),
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
            ? 'Berat: ${(itemTerbaru as KunjunganModel).beratBadan} kg, Tinggi: ${(itemTerbaru as KunjunganModel).tinggiBadan} cm'
            : 'Jenis: ${(itemTerbaru as Imunisasi).jenisImunisasi}';
    return Card(
      color: color.withOpacity(0.1),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    '$jenis Terakhir',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: Icon(Icons.history, color: color),
                  onPressed: () => _showRiwayatDialog(riwayat, jenis),
                  tooltip: 'Lihat Semua Riwayat $jenis',
                ),
              ],
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
                  child: Text('Tidak ada data.'),
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

  void _showRiwayatDialog(List<dynamic> riwayat, String jenis) {
    final List<PemeriksaanItem> items =
        riwayat.map((e) {
          if (jenis == 'Kunjungan') {
            return PemeriksaanItem(
              data: e,
              jenis: jenis,
              tanggal: e.tanggalKunjungan,
            );
          }
          return PemeriksaanItem(
            data: e,
            jenis: jenis,
            tanggal: e.tanggalImunisasi,
          );
        }).toList();

    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Semua Riwayat $jenis'),
            content: SizedBox(
              width: double.maxFinite,
              child:
                  items.isEmpty
                      ? const Center(child: Text('Tidak ada riwayat.'))
                      : ListView.builder(
                        itemCount: items.length,
                        itemBuilder:
                            (context, index) => _buildPemeriksaanListTile(
                              items[index],
                              isInDialog: true,
                            ),
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  Widget _buildPemeriksaanListTile(
    PemeriksaanItem item, {
    bool isInDialog = false,
  }) {
    final bool isKematian = item.jenis == 'Kematian';
    final bool isKunjungan = item.jenis == 'Kunjungan';

    final IconData iconData;
    final Color color;
    String subtitle;
    String title =
        '${item.jenis} - ${DateFormat('dd MMMM yyyy').format(item.tanggal)}';

    if (isKematian) {
      final kematian = item.data as Kematian;
      iconData = Icons.report_off_outlined;
      color = Colors.red.shade800;
      title = 'Meninggal Dunia';
      subtitle = 'Penyebab: ${kematian.penyebab ?? 'Tidak diketahui'}';
    } else if (isKunjungan) {
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
      dense: !isInDialog,
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, size: 20, color: Colors.blue),
            tooltip: 'Edit Data ${item.jenis}',
            onPressed: () => _handlePemeriksaanAction(item: item, isEdit: true),
          ),
          IconButton(
            icon: const Icon(Icons.delete, size: 20, color: Colors.red),
            tooltip: 'Hapus Data ${item.jenis}',
            onPressed:
                () => _handlePemeriksaanAction(item: item, isEdit: false),
          ),
        ],
      ),
    );
  }
}
