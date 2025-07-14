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
              onShowRiwayat: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: Text('Riwayat Kunjungan'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView(
                            shrinkWrap: true,
                            children:
                                data.riwayatKunjungan
                                    .map(
                                      (item) => ListTile(
                                        title: Text(
                                          DateFormat(
                                            'dd MMM yyyy',
                                          ).format(item.tanggalKunjungan),
                                        ),
                                        subtitle: Text(
                                          'BB: ${item.beratBadan} kg, TB: ${item.tinggiBadan} cm',
                                        ),
                                      ),
                                    )
                                    .toList(),
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
              },
            ),
            const SizedBox(height: 16),
            // Imunisasi selalu tampil, baik meninggal maupun tidak
            _buildRingkasanPemeriksaanTerakhir(
              jenis: 'Imunisasi',
              riwayat: data.riwayatImunisasi,
              color: Colors.green,
              onShowRiwayat: () {
                showDialog(
                  context: context,
                  builder:
                      (_) => AlertDialog(
                        title: Text('Riwayat Imunisasi'),
                        content: SizedBox(
                          width: double.maxFinite,
                          child: ListView(
                            shrinkWrap: true,
                            children:
                                data.riwayatImunisasi
                                    .map(
                                      (i) => ListTile(
                                        title: Text(
                                          DateFormat(
                                            'dd MMM yyyy',
                                          ).format(i.tanggalImunisasi),
                                        ),
                                        subtitle: Text(
                                          'Jenis: ${i.jenisImunisasi}',
                                        ),
                                      ),
                                    )
                                    .toList(),
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
              },
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

  // --- WIDGET UNTUK MENAMPILKAN TIAP ITEM RIWAYAT DENGAN AKSI EDIT/HAPUS DAN REFRESH ---
  Widget _buildPemeriksaanListTile(PemeriksaanItem item) {
    final isKematian = item.jenis == 'Kematian';
    final tanggalFormatted = DateFormat('dd MMM yyyy').format(item.tanggal);
    final icon =
        isKematian
            ? Icons.person_off_outlined
            : (item.jenis == 'Kunjungan'
                ? Icons.medical_services
                : Icons.vaccines);
    final color =
        isKematian
            ? Colors.red.shade700
            : (item.jenis == 'Kunjungan' ? Colors.blue : Colors.green);

    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(
        '${item.jenis} pada ${tanggalFormatted}',
        style: TextStyle(color: color),
      ),
      subtitle:
          isKematian
              ? Text(
                'Penyebab: ${(item.data as Kematian).penyebab?.isNotEmpty == true ? (item.data as Kematian).penyebab : "Tidak dicatat"}',
              )
              : Text(
                item.jenis == 'Kunjungan'
                    ? 'BB: ${(item.data as KunjunganModel).beratBadan} kg, TB: ${(item.data as KunjunganModel).tinggiBadan} cm'
                    : 'Jenis Imunisasi: ${(item.data as Imunisasi).jenisImunisasi}',
              ),
      trailing:
          isKematian
              ? Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    icon: const Icon(Icons.edit, color: Colors.blue),
                    tooltip: 'Edit',
                    onPressed: () async {
                      await _handleKematianAction(item.data, isEdit: true);
                    },
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.red),
                    tooltip: 'Hapus',
                    onPressed: () async {
                      await _handleKematianAction(item.data, isEdit: false);
                    },
                  ),
                ],
              )
              : null,
      onTap: () {
        // Bisa navigasi ke detail jika diinginkan
      },
    );
  }

  // --- WIDGET HELPER ---

  // <-- WIDGET UTAMA DENGAN LOGIKA BARU -->
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
                          // _deleteBalita sudah handle pop dan refresh
                        },
                        tooltip: 'Hapus Balita',
                      ),
                    ],
                  ),
              ],
            ),
            const Divider(),

            if (isDeceased && dataKematian != null) ...[
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Telah Meninggal Dunia',
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
              const SizedBox(height: 8),
              Text(
                'Tanggal: ${DateFormat('dd MMMM yyyy').format(dataKematian.tanggalKematian)}',
              ),
              Text(
                'Penyebab: ${dataKematian.penyebab?.isNotEmpty == true ? dataKematian.penyebab : "Tidak dicatat"}',
              ),
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
    required VoidCallback onShowRiwayat,
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
            Row(
              children: [
                Expanded(
                  child: Text(
                    '$jenis Terakhir',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.history, color: Colors.grey),
                  tooltip: 'Lihat Riwayat $jenis',
                  onPressed: onShowRiwayat,
                ),
                // Edit dan Delete button dihapus sesuai permintaan
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
}
