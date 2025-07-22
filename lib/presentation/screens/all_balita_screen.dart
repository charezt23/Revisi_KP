import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/API/BalitaService.dart';
import 'package:flutter_application_1/data/API/kematianService.dart';
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
  late Future<List<BalitaModel>> _balitaList;
  final Balitaservice _balitaService = Balitaservice();
  final KematianService _kematianService = KematianService();
  final TextEditingController _searchController = TextEditingController();
  bool _showHistoryMode = false; // false = aktif (< 6 tahun), true = semua data
  String _searchQuery = '';

  // Tambahan: daftar id balita yang sudah meninggal (patch frontend)
  List<int> _idBalitaMeninggal = [];

  // Filter status
  String _statusFilter =
      'semua'; // 'semua', 'aktif', 'tidak_aktif', 'meninggal'

  @override
  void initState() {
    super.initState();
    _balitaList = _balitaService.GetAllBalita(); // Mengambil semua balita
    _refreshAllData();
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
        _balitaList = _balitaService.GetAllBalita(); // Mengambil semua balita
      });
    }
  }

  // Filter balita berdasarkan pencarian dan status
  List<BalitaModel> _filterBalita(List<BalitaModel> balitaList) {
    List<BalitaModel> filteredList =
        balitaList.where((balita) {
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

          // Filter berdasarkan status
          bool isDead = _idBalitaMeninggal.contains(balita.id);
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
              return _showHistoryMode || (isActive && !isDead);
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

  // Widget untuk filter status
  Widget _buildStatusFilter() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            _buildFilterChip('semua', 'Semua'),
            const SizedBox(width: 8),
            _buildFilterChip('aktif', 'Aktif'),
            const SizedBox(width: 8),
            _buildFilterChip('tidak_aktif', 'Tidak Aktif'),
            const SizedBox(width: 8),
            _buildFilterChip('meninggal', 'Meninggal'),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterChip(String value, String label) {
    bool isSelected = _statusFilter == value;
    return FilterChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _statusFilter = value;
        });
      },
      selectedColor: const Color(0xFF03A9F4).withOpacity(0.3),
      checkmarkColor: const Color(0xFF03A9F4),
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
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: _refreshAllData,
            tooltip: 'Refresh Data',
          ),
        ],
      ),
      body: Stack(
        children: [
          const LoginBackground(),
          Column(
            children: [
              _buildSearchBar(),
              _buildStatusFilter(),
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

                      if (!snapshot.hasData || snapshot.data!.isEmpty) {
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
                        snapshot.data!,
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
                                    'Menampilkan ${filteredBalita.length} dari ${snapshot.data!.length} total balita',
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
                                final isDead = _idBalitaMeninggal.contains(
                                  balita.id,
                                );

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
