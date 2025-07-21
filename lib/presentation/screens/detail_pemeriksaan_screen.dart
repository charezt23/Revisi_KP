import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/presentation/screens/components/login_background.dart';
import 'package:flutter_application_1/presentation/screens/components/loading_indicator.dart';
import 'package:flutter_application_1/presentation/screens/Pemeriksaan/KematianFormScreen.dart';
import 'package:flutter_application_1/presentation/screens/Pemeriksaan/KunjunganFormScreen.dart';
import 'package:flutter_application_1/presentation/screens/Pemeriksaan/imunisasi_form_screen.dart';

// Import services dan models
import '../../data/API/ImunisasiService.dart';
import '../../data/API/KunjunganBalitaService.dart';
import '../../data/API/kematianService.dart';
import '../../data/models/KunjunganBalitaModel.dart';
import '../../data/models/kematian.dart';
import '../../data/models/imunisasi.dart';
import '../../data/models/balitaModel.dart';

class PemeriksaanDetailItem {
  final DateTime tanggal;
  final String jenis;
  final dynamic data;
  final Color color;
  final IconData icon;

  PemeriksaanDetailItem({
    required this.tanggal,
    required this.jenis,
    required this.data,
    required this.color,
    required this.icon,
  });
}

class DetailPemeriksaanScreen extends StatefulWidget {
  final BalitaModel balita;

  const DetailPemeriksaanScreen({super.key, required this.balita});

  @override
  State<DetailPemeriksaanScreen> createState() =>
      _DetailPemeriksaanScreenState();
}

class _DetailPemeriksaanScreenState extends State<DetailPemeriksaanScreen> {
  // Services
  final Kunjunganbalitaservice _kunjunganService = Kunjunganbalitaservice();
  final KematianService _kematianService = KematianService();
  final ImunisasiService _imunisasiService = ImunisasiService();

  // State
  List<PemeriksaanDetailItem> _allPemeriksaan = [];
  bool _isLoading = true;
  String _selectedFilter = 'Semua';
  final List<String> _filterOptions = [
    'Semua',
    'Kunjungan',
    'Imunisasi',
    'Kematian',
  ];

  @override
  void initState() {
    super.initState();
    Intl.defaultLocale = 'id_ID';
    _loadAllPemeriksaan();
  }

  Future<void> _loadAllPemeriksaan() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final results = await Future.wait([
        _kunjunganService.GetKunjunganbalitaByBalita(widget.balita.id!),
        _imunisasiService.getImunisasiByBalita(widget.balita.id!),
        _kematianService.getKematian(widget.balita.id!),
      ]);

      final List<KunjunganModel> kunjunganList =
          results[0] as List<KunjunganModel>;
      final List<Imunisasi> imunisasiList = results[1] as List<Imunisasi>;
      final Kematian? kematian = results[2] as Kematian?;

      List<PemeriksaanDetailItem> allItems = [];

      // Tambahkan kunjungan
      for (var kunjungan in kunjunganList) {
        allItems.add(
          PemeriksaanDetailItem(
            tanggal: kunjungan.tanggalKunjungan,
            jenis: 'Kunjungan',
            data: kunjungan,
            color: Colors.blue.shade600,
            icon: Icons.medical_services,
          ),
        );
      }

      // Tambahkan imunisasi
      for (var imunisasi in imunisasiList) {
        allItems.add(
          PemeriksaanDetailItem(
            tanggal: imunisasi.tanggalImunisasi,
            jenis: 'Imunisasi',
            data: imunisasi,
            color: Colors.green.shade600,
            icon: Icons.vaccines,
          ),
        );
      }

      // Tambahkan kematian jika ada
      if (kematian != null) {
        allItems.add(
          PemeriksaanDetailItem(
            tanggal: kematian.tanggalKematian,
            jenis: 'Kematian',
            data: kematian,
            color: Colors.red.shade700,
            icon: Icons.person_off_outlined,
          ),
        );
      }

      // Urutkan berdasarkan tanggal (terbaru dulu)
      allItems.sort((a, b) => b.tanggal.compareTo(a.tanggal));

      setState(() {
        _allPemeriksaan = allItems;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Gagal memuat data: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  List<PemeriksaanDetailItem> get _filteredPemeriksaan {
    if (_selectedFilter == 'Semua') {
      return _allPemeriksaan;
    }
    return _allPemeriksaan
        .where((item) => item.jenis == _selectedFilter)
        .toList();
  }

  Future<void> _handleEdit(PemeriksaanDetailItem item) async {
    Widget? targetScreen;

    if (item.jenis == 'Kunjungan') {
      targetScreen = KunjunganFormScreen(
        balita: widget.balita,
        kunjunganToEdit: item.data as KunjunganModel,
      );
    } else if (item.jenis == 'Imunisasi') {
      targetScreen = ImunisasiFormScreen(
        balita: widget.balita,
        imunisasiToEdit: item.data as Imunisasi,
      );
    } else if (item.jenis == 'Kematian') {
      targetScreen = KematianFormScreen(
        balita: widget.balita,
        kematianToEdit: item.data as Kematian,
      );
    }

    if (targetScreen != null) {
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => targetScreen!),
      );
      if (result == true && mounted) {
        _loadAllPemeriksaan();
      }
    }
  }

  Future<void> _handleDelete(PemeriksaanDetailItem item) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder:
          (context) => AlertDialog(
            title: Text('Hapus Data ${item.jenis}'),
            content: Text(
              'Anda yakin ingin menghapus data ${item.jenis.toLowerCase()} pada ${DateFormat('dd MMM yyyy').format(item.tanggal)}?',
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
        bool success = false;

        if (item.jenis == 'Kunjungan') {
          final kunjungan = item.data as KunjunganModel;
          success = await _kunjunganService.deleteKunjungan(kunjungan.id!);
        } else if (item.jenis == 'Imunisasi') {
          final imunisasi = item.data as Imunisasi;
          success = await _imunisasiService.deleteImunisasi(imunisasi.id);
        } else if (item.jenis == 'Kematian') {
          final kematian = item.data as Kematian;
          await _kematianService.deleteKematian(kematian.id);
          success = true;
        }

        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                'Data ${item.jenis.toLowerCase()} berhasil dihapus.',
              ),
              backgroundColor: Colors.green,
            ),
          );
          _loadAllPemeriksaan();
        } else {
          throw Exception('Gagal menghapus data');
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Riwayat Pemeriksaan ${widget.balita.nama}'),
        backgroundColor: Colors.blue.shade600,
        foregroundColor: Colors.white,
        elevation: 2,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Data',
            onPressed: _loadAllPemeriksaan,
          ),
        ],
      ),
      body: Stack(
        children: [
          const LoginBackground(),
          Column(
            children: [
              _buildFilterSection(),
              _buildStatisticsSection(),
              Expanded(
                child:
                    _isLoading
                        ? const Center(child: LoadingIndicator())
                        : _buildPemeriksaanList(),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFilterSection() {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.filter_list, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                'Filter Pemeriksaan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            children:
                _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                    },
                    selectedColor: Colors.blue.shade100,
                    checkmarkColor: Colors.blue.shade600,
                    labelStyle: TextStyle(
                      color:
                          isSelected
                              ? Colors.blue.shade600
                              : Colors.grey.shade700,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.normal,
                    ),
                  );
                }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStatisticsSection() {
    final filteredList = _filteredPemeriksaan;
    final kunjunganCount =
        _allPemeriksaan.where((item) => item.jenis == 'Kunjungan').length;
    final imunisasiCount =
        _allPemeriksaan.where((item) => item.jenis == 'Imunisasi').length;
    final kematianCount =
        _allPemeriksaan.where((item) => item.jenis == 'Kematian').length;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue.shade50, Colors.blue.shade100],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.analytics, color: Colors.blue.shade600),
              const SizedBox(width: 8),
              Text(
                'Statistik Pemeriksaan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blue.shade600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildStatCard(
                  'Total',
                  '${filteredList.length}',
                  Icons.timeline,
                  Colors.purple.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Kunjungan',
                  '$kunjunganCount',
                  Icons.medical_services,
                  Colors.blue.shade600,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildStatCard(
                  'Imunisasi',
                  '$imunisasiCount',
                  Icons.vaccines,
                  Colors.green.shade600,
                ),
              ),
              if (kematianCount > 0) ...[
                const SizedBox(width: 8),
                Expanded(
                  child: _buildStatCard(
                    'Kematian',
                    '$kematianCount',
                    Icons.person_off_outlined,
                    Colors.red.shade600,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(
    String label,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
          ),
        ],
      ),
    );
  }

  Widget _buildPemeriksaanList() {
    final filteredList = _filteredPemeriksaan;

    if (filteredList.isEmpty) {
      return Center(
        child: Container(
          margin: const EdgeInsets.all(32),
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withOpacity(0.1),
                spreadRadius: 1,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.folder_open, size: 64, color: Colors.grey.shade400),
              const SizedBox(height: 16),
              Text(
                'Tidak ada data pemeriksaan',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _selectedFilter == 'Semua'
                    ? 'Belum ada pemeriksaan yang dilakukan'
                    : 'Tidak ada data $_selectedFilter',
                style: TextStyle(fontSize: 14, color: Colors.grey.shade500),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadAllPemeriksaan,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: filteredList.length,
        itemBuilder: (context, index) {
          final item = filteredList[index];
          return _buildPemeriksaanCard(item, index);
        },
      ),
    );
  }

  Widget _buildPemeriksaanCard(PemeriksaanDetailItem item, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Card(
        elevation: 3,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              colors: [
                item.color.withOpacity(0.03),
                item.color.withOpacity(0.08),
              ],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: item.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(item.icon, color: item.color, size: 28),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                decoration: BoxDecoration(
                                  color: item.color.withOpacity(0.2),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Text(
                                  '#${index + 1}',
                                  style: TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.bold,
                                    color: item.color,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                item.jenis,
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: item.color,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.calendar_today,
                                size: 16,
                                color: Colors.grey.shade600,
                              ),
                              const SizedBox(width: 4),
                              Text(
                                DateFormat(
                                  'EEEE, dd MMMM yyyy',
                                  'id_ID',
                                ).format(item.tanggal),
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.grey.shade700,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    PopupMenuButton<String>(
                      onSelected: (value) async {
                        if (value == 'edit') {
                          await _handleEdit(item);
                        } else if (value == 'delete') {
                          await _handleDelete(item);
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
                      icon: Icon(Icons.more_vert, color: Colors.grey.shade600),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: item.color.withOpacity(0.2)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Detail Pemeriksaan',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey.shade700,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ..._buildDetailContent(item),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildDetailContent(PemeriksaanDetailItem item) {
    if (item.jenis == 'Kematian') {
      final kematian = item.data as Kematian;
      return [
        _buildDetailRow(
          'Penyebab Kematian',
          kematian.penyebabKematian.isNotEmpty
              ? kematian.penyebabKematian
              : 'Tidak dicatat',
          Icons.info_outline,
        ),
      ];
    } else if (item.jenis == 'Kunjungan') {
      final kunjungan = item.data as KunjunganModel;
      return [
        _buildDetailRow(
          'Berat Badan',
          '${kunjungan.beratBadan} kg',
          Icons.monitor_weight,
        ),
        _buildDetailRow(
          'Tinggi Badan',
          '${kunjungan.tinggiBadan} cm',
          Icons.height,
        ),
        _buildDetailRow('Status Gizi', kunjungan.statusGizi, Icons.restaurant),
        _buildDetailRow('Rambu Gizi', kunjungan.rambuGizi, Icons.traffic),
      ];
    } else {
      final imunisasi = item.data as Imunisasi;
      return [
        _buildDetailRow(
          'Jenis Imunisasi',
          imunisasi.jenisImunisasi,
          Icons.vaccines,
        ),
      ];
    }
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: Colors.grey.shade600),
          const SizedBox(width: 8),
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: TextStyle(
                fontWeight: FontWeight.w500,
                color: Colors.grey.shade700,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontWeight: FontWeight.w400, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}
