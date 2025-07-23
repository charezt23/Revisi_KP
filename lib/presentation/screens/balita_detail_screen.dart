import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/screens/Balita_Form_Screen.dart';
import 'package:flutter_application_1/presentation/screens/Pemeriksaan/KematianFormScreen.dart';
import 'package:flutter_application_1/presentation/screens/Pemeriksaan/KunjunganFormScreen.dart';
import 'package:flutter_application_1/presentation/screens/Pemeriksaan/imunisasi_form_screen.dart';
import 'package:flutter_application_1/presentation/screens/detail_pemeriksaan_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/presentation/screens/components/login_background.dart';
import 'package:flutter_application_1/presentation/screens/components/loading_indicator.dart';
import '../../data/API/ImunisasiService.dart';
import '../../data/API/KunjunganBalitaService.dart';
import '../../data/API/kematianService.dart';
import '../../data/API/BalitaService.dart';
import '../../data/models/KunjunganBalitaModel.dart';
import '../../data/models/kematian.dart';
import '../../data/models/imunisasi.dart';
import '../../data/models/balitaModel.dart';

// --- METODE UNTUK MENGAMBIL JENIS IMUNISASI YANG BELUM DILAKUKAN ---
List<String> getJenisImunisasiBelum(
  BalitaDetailData data,
  List<String> semuaJenis,
) {
  final sudah = data.riwayatImunisasi.map((i) => i.jenisImunisasi).toSet();
  return semuaJenis.where((jenis) => !sudah.contains(jenis)).toList();
}

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
    _refreshData();
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

  // --- LOGIKA AKSI ---

  Future<void> _lakukanPemeriksaan() async {
    // Ambil data detail terbaru
    final detailData = await _detailData;
    // Daftar semua jenis imunisasi yang tersedia
    final semuaJenisImunisasi = <String>[
      'DPT',
      'Campak',
    ]; // Ganti sesuai kebutuhan
    final jenisImunisasiBelum = getJenisImunisasiBelum(
      detailData,
      semuaJenisImunisasi,
    );

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
              if (jenisImunisasiBelum.isNotEmpty)
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
    Widget nextPage;
    switch (jenis) {
      case JenisPemeriksaan.kunjungan:
        nextPage = KunjunganFormScreen(balita: _currentBalita);
        break;
      case JenisPemeriksaan.imunisasi:
        nextPage = ImunisasiFormScreen(
          balita: _currentBalita,
          jenisImunisasiTersedia: jenisImunisasiBelum,
        );
        break;
      case JenisPemeriksaan.kematian:
        nextPage = KematianFormScreen(balita: _currentBalita);
        break;
    }
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => nextPage),
    );
    if (result == true && mounted) await _refreshData();
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

  // <-- FUNGSI BARU UNTUK MENGELOLA DATA KEMATIAN -->
  Future<void> _handleKematianAction(
    Kematian kematian, {
    required bool isEdit,
  }) async {
    if (isEdit) {
      // Navigasi ke form edit kematian
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => KematianFormScreen(
                balita: _currentBalita,
                kematianToEdit: kematian,
              ),
        ),
      );
      if (result == true && mounted) await _refreshData();
    } else {
      // Proses hapus data kematian
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Hapus Data Kematian'),
              content: const Text(
                'Anda yakin ingin menghapus data kematian ini? Status balita akan kembali menjadi hidup.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );
      if (confirm == true && mounted) {
        try {
          await _kematianService.deleteKematian(kematian.id);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Data kematian berhasil dihapus.'),
              backgroundColor: Colors.green,
            ),
          );
          await _refreshData();
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
  }

  // <-- FUNGSI UNTUK MENGELOLA DATA KUNJUNGAN -->
  Future<void> _handleKunjunganAction(
    KunjunganModel kunjungan, {
    required bool isEdit,
  }) async {
    if (isEdit) {
      // Navigasi ke form edit kunjungan
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => KunjunganFormScreen(
                balita: _currentBalita,
                kunjunganToEdit: kunjungan,
              ),
        ),
      );
      if (result == true && mounted) await _refreshData();
    } else {
      // Proses hapus data kunjungan
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Hapus Data Kunjungan'),
              content: Text(
                'Anda yakin ingin menghapus data kunjungan pada ${DateFormat('dd MMM yyyy').format(kunjungan.tanggalKunjungan)}?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );
      if (confirm == true && mounted) {
        try {
          final success = await _kunjunganService.deleteKunjungan(
            kunjungan.id!,
          );
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data kunjungan berhasil dihapus.'),
                backgroundColor: Colors.green,
              ),
            );
            await _refreshData();
          } else {
            throw Exception('Gagal menghapus data kunjungan');
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

  // <-- FUNGSI UNTUK MENGELOLA DATA IMUNISASI -->
  Future<void> _handleImunisasiAction(
    Imunisasi imunisasi, {
    required bool isEdit,
  }) async {
    if (isEdit) {
      // Navigasi ke form edit imunisasi
      final result = await Navigator.push(
        context,
        MaterialPageRoute(
          builder:
              (_) => ImunisasiFormScreen(
                balita: _currentBalita,
                imunisasiToEdit: imunisasi,
              ),
        ),
      );
      if (result == true && mounted) await _refreshData();
    } else {
      // Proses hapus data imunisasi
      final confirm = await showDialog<bool>(
        context: context,
        builder:
            (context) => AlertDialog(
              title: const Text('Hapus Data Imunisasi'),
              content: Text(
                'Anda yakin ingin menghapus data imunisasi ${imunisasi.jenisImunisasi} pada ${DateFormat('dd MMM yyyy').format(imunisasi.tanggalImunisasi)}?',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Batal'),
                ),
                TextButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text(
                    'Hapus',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
              ],
            ),
      );
      if (confirm == true && mounted) {
        try {
          final success = await _imunisasiService.deleteImunisasi(imunisasi.id);
          if (success) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Data imunisasi berhasil dihapus.'),
                backgroundColor: Colors.green,
              ),
            );
            await _refreshData();
          } else {
            throw Exception('Gagal menghapus data imunisasi');
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

  // --- UI BUILDER ---
  @override
  Widget build(BuildContext context) {
    return FutureBuilder<BalitaDetailData>(
      future: _detailData,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            appBar: AppBar(title: Text('Memuat...')),
            body: const Center(child: LoadingIndicator()),
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
                icon: const Icon(Icons.timeline),
                tooltip: 'Detail Pemeriksaan',
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (context) =>
                              DetailPemeriksaanScreen(balita: _currentBalita),
                    ),
                  );
                },
              ),
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
                  : FloatingActionButton.extended(
                    onPressed: _lakukanPemeriksaan,
                    tooltip: 'Lakukan Pemeriksaan',
                    icon: const Icon(Icons.add_box),
                    label: const Text('Pemeriksaan'),
                    backgroundColor: Colors.blue.shade600,
                    foregroundColor: Colors.white,
                  ),
        );
      },
    );
  }

  Widget _buildContent(BalitaDetailData data) {
    final bool isDeceased = data.dataKematian != null;
    return Stack(
      children: [
        const LoginBackground(),
        ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            _buildInfoDasar(dataKematian: data.dataKematian),
            const SizedBox(height: 16),
            _buildRingkasanPemeriksaanTerakhir(
              jenis: 'Kunjungan',
              riwayat: data.riwayatKunjungan,
              color: Colors.blue,
              onShowRiwayat:
                  () => _showRiwayatDialog('Kunjungan', data.riwayatKunjungan),
            ),
            const SizedBox(height: 16),
            // Imunisasi selalu tampil, baik meninggal maupun tidak
            _buildRingkasanPemeriksaanTerakhir(
              jenis: 'Imunisasi',
              riwayat: data.riwayatImunisasi,
              color: Colors.green,
              onShowRiwayat:
                  () => _showRiwayatDialog('Imunisasi', data.riwayatImunisasi),
            ),
            const SizedBox(height: 16),
            _buildSemuaRiwayatPemeriksaan(
              _gabungkanDanUrutkanRiwayat(data),
              isDeceased: isDeceased,
            ),
          ],
        ),
      ],
    );
  }

  // Edit fungsi yang sudah ada, tambahkan parameter opsional isDeceased
  Widget _buildSemuaRiwayatPemeriksaan(
    List<PemeriksaanItem> riwayat, {
    bool isDeceased = false,
  }) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [
              Colors.grey.withOpacity(0.02),
              Colors.grey.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: Colors.purple.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      Icons.timeline,
                      color: Colors.purple.shade600,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Riwayat Gabungan (${riwayat.length})',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.purple.shade600,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (riwayat.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (context) => DetailPemeriksaanScreen(
                                  balita: _currentBalita,
                                ),
                          ),
                        );
                      },
                      icon: const Icon(Icons.open_in_new, size: 16),
                      label: const Text('Detail'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purple.shade600,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 8,
                        ),
                        minimumSize: const Size(0, 32),
                        textStyle: const TextStyle(fontSize: 12),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 16),
              if (riwayat.isEmpty)
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.grey.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.withOpacity(0.2)),
                  ),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.folder_open,
                          size: 48,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Tidak ada data riwayat.',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
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
      ),
    );
  }

  // --- WIDGET UNTUK MENAMPILKAN TIAP ITEM RIWAYAT DENGAN AKSI EDIT/HAPUS DAN REFRESH ---
  Widget _buildPemeriksaanListTile(PemeriksaanItem item) {
    final isKematian = item.jenis == 'Kematian';
    final isKunjungan = item.jenis == 'Kunjungan';
    final tanggalFormatted = DateFormat('dd MMM yyyy').format(item.tanggal);

    final icon =
        isKematian
            ? Icons.person_off_outlined
            : (isKunjungan ? Icons.medical_services : Icons.vaccines);

    final color =
        isKematian
            ? Colors.red.shade700
            : (isKunjungan ? Colors.blue.shade600 : Colors.green.shade600);

    return Container(
      margin: const EdgeInsets.only(bottom: 8.0),
      child: Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: ListTile(
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 8,
          ),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 24),
          ),
          title: Text(
            '${item.jenis} pada ${tanggalFormatted}',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
          subtitle: Padding(
            padding: const EdgeInsets.only(top: 4),
            child: Text(
              _getItemSubtitle(item),
              style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
            ),
          ),
          trailing: _buildActionButtons(item),
          onTap: () => _showDetailDialog(item),
        ),
      ),
    );
  }

  String _getItemSubtitle(PemeriksaanItem item) {
    if (item.jenis == 'Kematian') {
      final kematian = item.data as Kematian;
      return 'Penyebab: ${kematian.penyebabKematian.isNotEmpty ? kematian.penyebabKematian : "Tidak dicatat"}';
    } else if (item.jenis == 'Kunjungan') {
      final kunjungan = item.data as KunjunganModel;
      return 'BB: ${kunjungan.beratBadan} kg, TB: ${kunjungan.tinggiBadan} cm\nStatus Gizi: ${kunjungan.statusGizi}';
    } else {
      final imunisasi = item.data as Imunisasi;
      return 'Jenis Imunisasi: ${imunisasi.jenisImunisasi}';
    }
  }

  Widget? _buildActionButtons(PemeriksaanItem item) {
    if (item.jenis == 'Kematian') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
            tooltip: 'Edit',
            onPressed: () => _handleKematianAction(item.data, isEdit: true),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            tooltip: 'Hapus',
            onPressed: () => _handleKematianAction(item.data, isEdit: false),
          ),
        ],
      );
    } else if (item.jenis == 'Kunjungan') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
            tooltip: 'Edit Kunjungan',
            onPressed: () => _handleKunjunganAction(item.data, isEdit: true),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            tooltip: 'Hapus Kunjungan',
            onPressed: () => _handleKunjunganAction(item.data, isEdit: false),
          ),
        ],
      );
    } else if (item.jenis == 'Imunisasi') {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          IconButton(
            icon: const Icon(Icons.edit, color: Colors.blue, size: 20),
            tooltip: 'Edit Imunisasi',
            onPressed: () => _handleImunisasiAction(item.data, isEdit: true),
          ),
          IconButton(
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
            tooltip: 'Hapus Imunisasi',
            onPressed: () => _handleImunisasiAction(item.data, isEdit: false),
          ),
        ],
      );
    }
    return null;
  }

  void _showDetailDialog(PemeriksaanItem item) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Detail ${item.jenis}',
              style: TextStyle(
                color:
                    item.jenis == 'Kematian'
                        ? Colors.red.shade700
                        : (item.jenis == 'Kunjungan'
                            ? Colors.blue.shade600
                            : Colors.green.shade600),
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Tanggal: ${DateFormat('dd MMMM yyyy').format(item.tanggal)}',
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 8),
                  ..._getDetailContent(item),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  List<Widget> _getDetailContent(PemeriksaanItem item) {
    if (item.jenis == 'Kematian') {
      final kematian = item.data as Kematian;
      return [
        Text(
          'Penyebab Kematian: ${kematian.penyebabKematian.isNotEmpty ? kematian.penyebabKematian : "Tidak dicatat"}',
        ),
      ];
    } else if (item.jenis == 'Kunjungan') {
      final kunjungan = item.data as KunjunganModel;
      return [
        Text('Berat Badan: ${kunjungan.beratBadan} kg'),
        Text('Tinggi Badan: ${kunjungan.tinggiBadan} cm'),
        Text('Status Gizi: ${kunjungan.statusGizi}'),
        Text('Rambu Gizi: ${kunjungan.rambuGizi}'),
      ];
    } else {
      final imunisasi = item.data as Imunisasi;
      return [Text('Jenis Imunisasi: ${imunisasi.jenisImunisasi}')];
    }
  }

  // Fungsi untuk menampilkan dialog riwayat dengan fitur edit/delete
  void _showRiwayatDialog(String jenis, List<dynamic> riwayat) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text(
              'Riwayat $jenis',
              style: TextStyle(
                color:
                    jenis == 'Kunjungan'
                        ? Colors.blue.shade600
                        : Colors.green.shade600,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SizedBox(
              width: double.maxFinite,
              height: 400,
              child:
                  riwayat.isEmpty
                      ? Center(
                        child: Text(
                          'Tidak ada riwayat $jenis',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      )
                      : ListView.builder(
                        itemCount: riwayat.length,
                        itemBuilder: (context, index) {
                          final item = riwayat[index];
                          if (jenis == 'Kunjungan') {
                            final kunjungan = item as KunjunganModel;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.blue.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.medical_services,
                                    color: Colors.blue.shade600,
                                  ),
                                ),
                                title: Text(
                                  DateFormat(
                                    'dd MMM yyyy',
                                  ).format(kunjungan.tanggalKunjungan),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'BB: ${kunjungan.beratBadan} kg, TB: ${kunjungan.tinggiBadan} cm\nStatus Gizi: ${kunjungan.statusGizi}',
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    Navigator.pop(context);
                                    if (value == 'edit') {
                                      await _handleKunjunganAction(
                                        kunjungan,
                                        isEdit: true,
                                      );
                                    } else if (value == 'delete') {
                                      await _handleKunjunganAction(
                                        kunjungan,
                                        isEdit: false,
                                      );
                                    }
                                  },
                                  itemBuilder:
                                      (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Hapus'),
                                            ],
                                          ),
                                        ),
                                      ],
                                ),
                              ),
                            );
                          } else {
                            final imunisasi = item as Imunisasi;
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.green.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Icon(
                                    Icons.vaccines,
                                    color: Colors.green.shade600,
                                  ),
                                ),
                                title: Text(
                                  DateFormat(
                                    'dd MMM yyyy',
                                  ).format(imunisasi.tanggalImunisasi),
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Text(
                                  'Jenis: ${imunisasi.jenisImunisasi}',
                                ),
                                trailing: PopupMenuButton<String>(
                                  onSelected: (value) async {
                                    Navigator.pop(context);
                                    if (value == 'edit') {
                                      await _handleImunisasiAction(
                                        imunisasi,
                                        isEdit: true,
                                      );
                                    } else if (value == 'delete') {
                                      await _handleImunisasiAction(
                                        imunisasi,
                                        isEdit: false,
                                      );
                                    }
                                  },
                                  itemBuilder:
                                      (context) => [
                                        const PopupMenuItem(
                                          value: 'edit',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.edit,
                                                color: Colors.blue,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Edit'),
                                            ],
                                          ),
                                        ),
                                        const PopupMenuItem(
                                          value: 'delete',
                                          child: Row(
                                            children: [
                                              Icon(
                                                Icons.delete,
                                                color: Colors.red,
                                                size: 20,
                                              ),
                                              SizedBox(width: 8),
                                              Text('Hapus'),
                                            ],
                                          ),
                                        ),
                                      ],
                                ),
                              ),
                            );
                          }
                        },
                      ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Tutup'),
              ),
            ],
          ),
    );
  }

  // --- WIDGET HELPER ---

  // <-- WIDGET UTAMA DENGAN LOGIKA BARU -->
  Widget _buildInfoDasar({required Kematian? dataKematian}) {
    final balita = _currentBalita;
    final bool isDeceased = dataKematian != null;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            colors:
                isDeceased
                    ? [
                      Colors.red.withOpacity(0.05),
                      Colors.red.withOpacity(0.1),
                    ]
                    : [
                      Colors.blue.withOpacity(0.03),
                      Colors.blue.withOpacity(0.08),
                    ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color:
                                    isDeceased
                                        ? Colors.red.withOpacity(0.1)
                                        : Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                Icons.child_care,
                                color:
                                    isDeceased
                                        ? Colors.red.shade700
                                        : Colors.blue.shade600,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                balita.nama,
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineSmall?.copyWith(
                                  color:
                                      isDeceased
                                          ? Colors.red.shade700
                                          : Colors.blue.shade800,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (isDeceased)
                          Container(
                            margin: const EdgeInsets.only(top: 8),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.red.shade100,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: Colors.red.shade300),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.person_off,
                                  size: 16,
                                  color: Colors.red.shade700,
                                ),
                                const SizedBox(width: 4),
                                Text(
                                  'Telah Meninggal Dunia',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.red.shade700,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    ),
                  ),
                  if (!isDeceased)
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.2),
                            spreadRadius: 1,
                            blurRadius: 3,
                            offset: const Offset(0, 1),
                          ),
                        ],
                      ),
                      child: Row(
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
                                await _refreshData();
                              } else if (result == true && mounted) {
                                await _refreshData();
                              }
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete, color: Colors.red),
                            onPressed: () async {
                              await _deleteBalita();
                            },
                            tooltip: 'Hapus Balita',
                          ),
                        ],
                      ),
                    ),
                ],
              ),

              const SizedBox(height: 16),
              const Divider(),
              const SizedBox(height: 16),

              if (isDeceased) ...[
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.05),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.red.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Informasi Kematian',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.red.shade700,
                              fontSize: 16,
                            ),
                          ),
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              IconButton(
                                icon: const Icon(
                                  Icons.edit,
                                  color: Colors.blue,
                                  size: 20,
                                ),
                                tooltip: 'Edit Data Kematian',
                                onPressed:
                                    () => _handleKematianAction(
                                      dataKematian,
                                      isEdit: true,
                                    ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                  size: 20,
                                ),
                                tooltip: 'Hapus Data Kematian',
                                onPressed:
                                    () => _handleKematianAction(
                                      dataKematian,
                                      isEdit: false,
                                    ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Row(
                        children: [
                          Icon(
                            Icons.calendar_today,
                            size: 16,
                            color: Colors.red.shade600,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            'Tanggal: ${DateFormat('dd MMMM yyyy').format(dataKematian.tanggalKematian)}',
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.info_outline,
                            size: 16,
                            color: Colors.red.shade600,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Penyebab: ${dataKematian.penyebabKematian.isNotEmpty ? dataKematian.penyebabKematian : "Tidak dicatat"}',
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(),
                const SizedBox(height: 16),
              ],

              // Informasi dasar balita
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Informasi Dasar',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey.shade700,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 12),
                    _buildInfoRow(Icons.badge, 'NIK', balita.nik),
                    _buildInfoRow(Icons.person, 'Nama Ibu', balita.namaIbu),
                    _buildInfoRow(
                      Icons.cake,
                      'Tgl Lahir',
                      DateFormat('dd MMMM yyyy').format(balita.tanggalLahir),
                    ),
                    _buildInfoRow(
                      Icons.wc,
                      'Jenis Kelamin',
                      balita.jenisKelamin == "L" ? "Laki-laki" : "Perempuan",
                    ),
                    _buildInfoRow(Icons.home, 'Alamat', balita.alamat),
                    _buildInfoRow(Icons.book, 'Buku KIA', balita.bukuKIA),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRingkasanPemeriksaanTerakhir({
    required String jenis,
    required List<dynamic> riwayat,
    required Color color,
    required VoidCallback onShowRiwayat,
  }) {
    if (riwayat.isEmpty) {
      return Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              colors: [color.withOpacity(0.05), color.withOpacity(0.1)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: ListTile(
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                jenis == 'Kunjungan' ? Icons.medical_services : Icons.vaccines,
                color: color,
              ),
            ),
            title: Text(
              "Belum ada riwayat $jenis",
              style: TextStyle(color: color, fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              "Belum ada data pemeriksaan",
              style: TextStyle(color: Colors.grey.shade600),
            ),
          ),
        ),
      );
    }

    final itemTerbaru = riwayat.first;
    final tanggal =
        jenis == 'Kunjungan'
            ? (itemTerbaru as KunjunganModel).tanggalKunjungan
            : (itemTerbaru as Imunisasi).tanggalImunisasi;
    final detail =
        jenis == 'Kunjungan'
            ? 'BB: ${itemTerbaru.beratBadan} kg, TB: ${itemTerbaru.tinggiBadan} cm\nStatus Gizi: ${itemTerbaru.statusGizi}'
            : 'Jenis: ${itemTerbaru.jenisImunisasi}';

    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          gradient: LinearGradient(
            colors: [color.withOpacity(0.05), color.withOpacity(0.1)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: color.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(
                      jenis == 'Kunjungan'
                          ? Icons.medical_services
                          : Icons.vaccines,
                      color: color,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      '$jenis Terakhir',
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: color,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit, color: color, size: 20),
                        tooltip: 'Edit $jenis Terakhir',
                        onPressed: () {
                          if (jenis == 'Kunjungan') {
                            _handleKunjunganAction(itemTerbaru, isEdit: true);
                          } else {
                            _handleImunisasiAction(itemTerbaru, isEdit: true);
                          }
                        },
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.history,
                          color: Colors.grey,
                          size: 20,
                        ),
                        tooltip: 'Lihat Riwayat $jenis',
                        onPressed: onShowRiwayat,
                      ),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: color.withOpacity(0.2)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.calendar_today, size: 16, color: color),
                        const SizedBox(width: 6),
                        Text(
                          'Tanggal: ${DateFormat('dd MMM yyyy').format(tanggal)}',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: Colors.grey.shade800,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      detail,
                      style: TextStyle(
                        color: Colors.grey.shade700,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
