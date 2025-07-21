import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/API/BalitaService.dart';
import 'package:flutter_application_1/data/API/authservice.dart';
import 'package:flutter_application_1/data/API/kematianService.dart';
import 'package:flutter_application_1/data/API/PosyanduService.dart';
import 'package:flutter_application_1/data/models/balitaModel.dart';
import 'package:flutter_application_1/presentation/screens/balita_detail_screen.dart';
import 'package:flutter_application_1/presentation/screens/components/balita_card.dart';
import 'package:flutter_application_1/presentation/screens/components/loading_indicator.dart';
import 'package:flutter_application_1/presentation/screens/components/login_background.dart';

class AllBalitaScreen extends StatefulWidget {
  const AllBalitaScreen({Key? key}) : super(key: key);

  @override
  State<AllBalitaScreen> createState() => _AllBalitaScreenState();
}

class _AllBalitaScreenState extends State<AllBalitaScreen> {
  Future<List<BalitaModel>> _balitaList = Future.value([]);
  final Balitaservice _balitaService = Balitaservice();
  final Posyanduservice _posyanduService = Posyanduservice();
  final KematianService _kematianService = KematianService();
  final TextEditingController _searchController = TextEditingController();
  bool _showHistoryMode = false; // false = aktif (< 6 tahun), true = semua data
  String _searchQuery = '';

  // Tambahan: daftar id balita yang sudah meninggal (patch frontend)
  List<int> _idBalitaMeninggal = [];

  // Filter status
  String _statusFilter =
      'semua'; // 'semua', 'aktif', 'tidak_aktif', 'meninggal'

  int? _currentUserId;

  @override
  void initState() {
    super.initState();
    _initUserAndData();
  }

  Future<void> _initUserAndData() async {
    final user = await AuthService.getCurrentUser();
    setState(() {
      _currentUserId = user?.id;
      _balitaList = _getAllBalitaByAllUserPosyandu();
    });
    _refreshAllData();
  }

  // Fungsi baru: ambil semua balita dari seluruh posyandu milik user
  Future<List<BalitaModel>> _getAllBalitaByAllUserPosyandu() async {
    try {
      // Ambil semua posyandu milik user
      final posyanduList = await _posyanduService.GetPosyanduByUser();
      List<BalitaModel> allBalita = [];
      for (var posyandu in posyanduList) {
        final balitaList = await _balitaService.GetBalitaByPosyandu(
          posyandu.id,
        );
        allBalita.addAll(balitaList);
      }
      return allBalita;
    } catch (e) {
      print('Gagal mengambil data balita dari semua posyandu: $e');
      return [];
    }
  }

  // Fungsi untuk memuat ulang data balita dan data kematian
  void _refreshAllData() async {
    await _refreshKematianList();
    _refreshBalitaList();
  }

  // Fungsi untuk memuat ulang data kematian
  Future<void> _refreshKematianList() async {
    if (!mounted) return;

    try {
      final kematianList = await _kematianService.getAllKematian();

      if (mounted) {
        setState(() {
          _idBalitaMeninggal = kematianList.map((k) => k.balitaId).toList();
        });
      }
    } catch (e) {
      if (mounted) {
        // Tidak perlu menampilkan error untuk kematian, karena tidak kritis
        print('Gagal memuat data kematian: $e');
      }
    }
  }

  // Fungsi untuk memuat ulang data balita
  void _refreshBalitaList() {
    if (mounted) {
      setState(() {
        _balitaList = _getAllBalitaByAllUserPosyandu();
      });
    }
  }

  // Filter balita berdasarkan pencarian dan status
  List<BalitaModel> _filterBalita(List<BalitaModel> balitaList) {
    // Return empty list jika input null atau kosong
    if (balitaList.isEmpty) return [];

    // Tidak perlu filter userId, karena semua balita sudah hasil gabungan dari posyandu milik user
    List<BalitaModel> userBalitaList = balitaList;

    List<BalitaModel> filteredList =
        userBalitaList.where((balita) {
          // Filter berdasarkan pencarian
          bool matchSearch =
              _searchQuery.isEmpty ||
              balita.nama.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              balita.nik.toLowerCase().contains(_searchQuery.toLowerCase()) ||
              balita.namaIbu.toLowerCase().contains(
                _searchQuery.toLowerCase(),
              ) ||
              (balita.posyandu?.namaPosyandu.toLowerCase().contains(
                    _searchQuery.toLowerCase(),
                  ) ??
                  false);

          if (!matchSearch) return false;

          // Filter berdasarkan status dengan null safety untuk id
          if (balita.id == null) return false;

          // Safe check untuk _idBalitaMeninggal
          bool isDead =
              _idBalitaMeninggal.isNotEmpty &&
              _idBalitaMeninggal.contains(balita.id);
          DateTime now = DateTime.now();
          DateTime birthDate = balita.tanggalLahir;
          Duration age = now.difference(birthDate);
          bool isActive = age.inDays < (6 * 365); // < 6 tahun

          switch (_statusFilter) {
            case 'aktif':
              return isActive && !isDead;
            case 'tidak_aktif':
              return !isActive && !isDead;
            case 'meninggal':
              return isDead;
            case 'semua':
            default:
              return true; // tampilkan SEMUA balita, termasuk yang meninggal
          }
        }).toList();

    // Urutkan berdasarkan nama
    filteredList.sort((a, b) => a.nama.compareTo(b.nama));
    return filteredList;
  }

  // Widget untuk search bar
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: TextField(
        controller: _searchController,
        decoration: InputDecoration(
          hintText: 'Cari nama balita, NIK, ibu, atau posyandu...',
          prefixIcon: const Icon(Icons.search),
          suffixIcon:
              _searchQuery.isNotEmpty
                  ? IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      setState(() {
                        _searchQuery = '';
                      });
                    },
                  )
                  : null,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          filled: true,
          fillColor: Colors.white,
        ),
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  // Widget untuk menampilkan info filter aktif
  Widget _buildFilterInfo() {
    String filterLabel = _getFilterLabel(_statusFilter);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF03A9F4).withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: const Color(0xFF03A9F4).withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getFilterIcon(_statusFilter),
            color: const Color(0xFF03A9F4),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            'Filter aktif: $filterLabel',
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              color: Color(0xFF03A9F4),
            ),
          ),
          const Spacer(),
          if (_statusFilter != 'semua')
            TextButton(
              onPressed: () {
                setState(() {
                  _statusFilter = 'semua';
                });
              },
              child: const Text(
                'Reset',
                style: TextStyle(color: Color(0xFF03A9F4), fontSize: 12),
              ),
            ),
        ],
      ),
    );
  }

  // Helper method untuk mendapatkan label filter
  String _getFilterLabel(String filter) {
    switch (filter) {
      case 'aktif':
        return 'Balita Aktif';
      case 'tidak_aktif':
        return 'Balita Tidak Aktif';
      case 'meninggal':
        return 'Balita Meninggal';
      case 'semua':
      default:
        return 'Semua Balita';
    }
  }

  // Helper method untuk mendapatkan icon filter
  IconData _getFilterIcon(String filter) {
    switch (filter) {
      case 'aktif':
        return Icons.check_circle;
      case 'tidak_aktif':
        return Icons.pause_circle;
      case 'meninggal':
        return Icons.cancel;
      case 'semua':
      default:
        return Icons.list;
    }
  }

  // Widget untuk sidebar filter
  Widget _buildFilterSidebar() {
    return Drawer(
      width: 300,
      child: Column(
        children: [
          // Header sidebar
          Container(
            width: double.infinity,
            padding: const EdgeInsets.fromLTRB(24, 50, 24, 20),
            decoration: const BoxDecoration(
              color: Color(0xFF03A9F4),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(20),
                bottomRight: Radius.circular(20),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.filter_list,
                      color: Colors.white,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Filter Data Balita',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.close, color: Colors.white),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Pilih status untuk memfilter data balita',
                  style: TextStyle(color: Colors.white70, fontSize: 14),
                ),
              ],
            ),
          ),
          // Filter options
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text(
                  'Status Balita',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 16),
                _buildFilterOption(
                  'semua',
                  'Semua Balita',
                  Icons.list,
                  Colors.grey,
                ),
                _buildFilterOption(
                  'aktif',
                  'Balita Aktif',
                  Icons.check_circle,
                  Colors.green,
                ),
                _buildFilterOption(
                  'tidak_aktif',
                  'Balita Tidak Aktif',
                  Icons.pause_circle,
                  Colors.orange,
                ),
                _buildFilterOption(
                  'meninggal',
                  'Balita Meninggal',
                  Icons.cancel,
                  Colors.red,
                ),
                const SizedBox(height: 24),
                // Mode toggle dalam sidebar
                _buildSidebarModeToggle(),
                const SizedBox(height: 24),
                // Statistik filter
                _buildFilterStats(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk option filter dalam sidebar
  Widget _buildFilterOption(
    String value,
    String label,
    IconData icon,
    Color color,
  ) {
    final bool isSelected = _statusFilter == value;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: isSelected ? color.withOpacity(0.1) : null,
        border: Border.all(
          color: isSelected ? color : Colors.grey.shade300,
          width: isSelected ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon, color: isSelected ? color : Colors.grey),
        title: Text(
          label,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            color: isSelected ? color : Colors.grey[700],
          ),
        ),
        trailing: isSelected ? Icon(Icons.check, color: color) : null,
        onTap: () {
          setState(() {
            _statusFilter = value;
          });
          Navigator.of(context).pop();
        },
      ),
    );
  }

  // Widget untuk mode toggle dalam sidebar
  Widget _buildSidebarModeToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Mode Tampilan',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                _showHistoryMode ? Icons.history : Icons.child_care,
                color: const Color(0xFF03A9F4),
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  _showHistoryMode
                      ? 'Semua Data\n(Termasuk Riwayat)'
                      : 'Data Aktif\n(Balita < 6 Tahun)',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Color(0xFF2C3E50),
                  ),
                ),
              ),
              Switch(
                value: _showHistoryMode,
                onChanged: (value) {
                  setState(() {
                    _showHistoryMode = value;
                  });
                },
                activeColor: const Color(0xFF03A9F4),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Widget untuk statistik filter
  Widget _buildFilterStats() {
    return FutureBuilder<List<BalitaModel>>(
      future: _balitaList,
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data == null) {
          return const SizedBox.shrink();
        }

        List<BalitaModel> allBalita = snapshot.data ?? [];
        int totalBalita = allBalita.length;
        int aktifCount = 0;
        int tidakAktifCount = 0;
        int meninggalCount = _idBalitaMeninggal.length;

        for (var balita in allBalita) {
          // Skip jika id null untuk menghindari error
          if (balita.id == null) continue;

          bool isDead =
              _idBalitaMeninggal.isNotEmpty &&
              _idBalitaMeninggal.contains(balita.id);
          if (!isDead) {
            DateTime now = DateTime.now();
            DateTime birthDate = balita.tanggalLahir;
            Duration age = now.difference(birthDate);
            bool isActive = age.inDays < (6 * 365);

            if (isActive) {
              aktifCount++;
            } else {
              tidakAktifCount++;
            }
          }
        }

        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Statistik Data',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
              const SizedBox(height: 12),
              _buildStatRow('Total Balita', '$totalBalita', Colors.blue),
              _buildStatRow('Aktif', '$aktifCount', Colors.green),
              _buildStatRow('Tidak Aktif', '$tidakAktifCount', Colors.orange),
              _buildStatRow('Meninggal', '$meninggalCount', Colors.red),
            ],
          ),
        );
      },
    );
  }

  // Widget untuk baris statistik
  Widget _buildStatRow(String label, String count, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(label, style: const TextStyle(fontSize: 12)),
          const Spacer(),
          Text(
            count,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  // Widget untuk toggle mode tampilan
  Widget _buildToggleMode() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Icon(
            _showHistoryMode ? Icons.history : Icons.child_care,
            color: const Color(0xFF03A9F4),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _showHistoryMode
                  ? 'Mode: Semua Data (Termasuk Riwayat)'
                  : 'Mode: Data Aktif (Balita < 6 Tahun)',
              style: const TextStyle(
                fontWeight: FontWeight.w500,
                color: Color(0xFF2C3E50),
              ),
            ),
          ),
          Switch(
            value: _showHistoryMode,
            onChanged: (value) {
              setState(() {
                _showHistoryMode = value;
              });
            },
            activeColor: const Color(0xFF03A9F4),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Semua Data Balita',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF03A9F4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          Builder(
            builder:
                (context) => IconButton(
                  icon: const Icon(Icons.filter_list, color: Colors.white),
                  onPressed: () => Scaffold.of(context).openEndDrawer(),
                  tooltip: 'Filter Data',
                ),
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshAllData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      endDrawer: _buildFilterSidebar(),
      body: Stack(
        children: [
          const LoginBackground(),
          Column(
            children: [
              _buildSearchBar(),
              _buildFilterInfo(),
              _buildToggleMode(),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.all(16),
                  child: FutureBuilder<List<BalitaModel>>(
                    future: _balitaList,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: LoadingIndicator());
                      }

                      if (snapshot.hasError) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 64,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Gagal memuat data balita',
                                style: Theme.of(context).textTheme.titleLarge,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${snapshot.error}',
                                style: Theme.of(context).textTheme.bodyMedium,
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton(
                                onPressed: _refreshAllData,
                                child: const Text('Coba Lagi'),
                              ),
                            ],
                          ),
                        );
                      }

                      if (!snapshot.hasData ||
                          snapshot.data == null ||
                          snapshot.data!.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.child_care,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Belum ada data balita',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Data balita akan muncul di sini setelah ditambahkan',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      List<BalitaModel> filteredBalita = _filterBalita(
                        snapshot.data ?? [],
                      );

                      if (filteredBalita.isEmpty) {
                        return Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.search_off,
                                size: 64,
                                color: Colors.grey,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Tidak ada data yang sesuai',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Coba ubah kriteria pencarian atau filter',
                                textAlign: TextAlign.center,
                              ),
                            ],
                          ),
                        );
                      }

                      return Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 8),
                            decoration: BoxDecoration(
                              color: const Color(0xFF03A9F4).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Row(
                              children: [
                                const Icon(
                                  Icons.info_outline,
                                  color: Color(0xFF03A9F4),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Menampilkan ${filteredBalita.length} dari ${snapshot.data?.length ?? 0} total balita',
                                    style: const TextStyle(
                                      color: Color(0xFF03A9F4),
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: ListView.builder(
                              itemCount: filteredBalita.length,
                              itemBuilder: (context, index) {
                                final balita = filteredBalita[index];

                                // Safe check untuk id yang mungkin null
                                final isDead =
                                    balita.id != null &&
                                            _idBalitaMeninggal.isNotEmpty
                                        ? _idBalitaMeninggal.contains(balita.id)
                                        : false;

                                // Hitung umur dalam tahun
                                DateTime now = DateTime.now();
                                DateTime birthDate = balita.tanggalLahir;
                                Duration ageDuration = now.difference(
                                  birthDate,
                                );
                                int ageInYears =
                                    (ageDuration.inDays / 365).floor();

                                return BalitaCard(
                                  balita: balita,
                                  age: ageInYears,
                                  isDeceased: isDead,
                                  onTap: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder:
                                            (context) => BalitaDetailScreen(
                                              balita: balita,
                                            ),
                                      ),
                                    );
                                    if (result == true) {
                                      _refreshAllData();
                                    }
                                  },
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
