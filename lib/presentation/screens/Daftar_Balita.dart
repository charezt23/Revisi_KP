import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/API/BalitaService.dart';
import 'package:flutter_application_1/data/API/kematianService.dart';
import 'package:flutter_application_1/data/models/kematian.dart';
import 'package:flutter_application_1/data/models/posyanduModel.dart';
import 'package:flutter_application_1/data/models/balitaModel.dart';
import 'package:flutter_application_1/presentation/screens/Balita_Form_Screen.dart';
import 'package:flutter_application_1/presentation/screens/balita_detail_screen.dart';
import 'package:flutter_application_1/presentation/screens/components/balita_card.dart';
import 'package:flutter_application_1/presentation/screens/components/loading_indicator.dart';
// import 'package:flutter_application_1/presentation/screens/components/status_container.dart';

// Tambahkan RouteObserver global
final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

class KohortDetailScreen extends StatefulWidget {
  final PosyanduModel posyandu;
  const KohortDetailScreen({Key? key, required this.posyandu})
    : super(key: key);

  @override
  State<KohortDetailScreen> createState() => _KohortDetailScreenState();
}

class _KohortDetailScreenState extends State<KohortDetailScreen>
    with RouteAware {
  // Widget untuk sidebar filter (mirip AllBalitaScreen, warna dan icon disesuaikan)
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
              color: Color(0xFF00897B), // teal
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
                      Icons.tune, // beda icon
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
                  Colors.teal,
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
                  Colors.purple,
                ),
                const SizedBox(height: 24),
                // Statistik bayi
                FutureBuilder<List<BalitaModel>>(
                  future: _balitaList,
                  builder: (context, snapshot) {
                    if (!snapshot.hasData || snapshot.data == null) {
                      return const SizedBox.shrink();
                    }
                    final allBalita = snapshot.data!;
                    int aktif = 0;
                    int tidakAktif = 0;
                    int meninggal = _idBalitaMeninggal.length;
                    for (var balita in allBalita) {
                      if (balita.id == null) continue;
                      bool isDead = _idBalitaMeninggal.contains(balita.id);
                      if (!isDead) {
                        int age = _calculateAge(balita.tanggalLahir);
                        if (age < 6) {
                          aktif++;
                        } else {
                          tidakAktif++;
                        }
                      }
                    }
                    return Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.teal.withOpacity(0.07),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Statistik Balita',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.teal,
                              fontSize: 15,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.teal,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Aktif',
                                style: TextStyle(fontSize: 13),
                              ),
                              const Spacer(),
                              Text(
                                '$aktif',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.teal,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Tidak Aktif',
                                style: TextStyle(fontSize: 13),
                              ),
                              const Spacer(),
                              Text(
                                '$tidakAktif',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Row(
                            children: [
                              Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  color: Colors.purple,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Meninggal',
                                style: TextStyle(fontSize: 13),
                              ),
                              const Spacer(),
                              Text(
                                '$meninggal',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
      // floatingActionButton dipindah ke Scaffold
    );
  }

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
          Navigator.of(context).pop();
          Future.delayed(const Duration(milliseconds: 150), () {
            if (mounted) {
              setState(() {
                _statusFilter = value;
              });
            }
          });
        },
      ),
    );
  }

  // Widget untuk statistik filter

  // Widget untuk baris statistik

  late Future<List<BalitaModel>> _balitaList;
  final Balitaservice _balitaService = Balitaservice();
  final KematianService _kematianService = KematianService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  // Tambahan: daftar id balita yang sudah meninggal (patch frontend)
  List<int> _idBalitaMeninggal = [];
  // bool _isLoadingKematian = false; // removed unused variable

  // Filter status
  String _statusFilter =
      'semua'; // 'semua', 'aktif', 'tidak_aktif', 'meninggal'

  @override
  void initState() {
    super.initState();
    _balitaList = _balitaService.GetBalitaByPosyandu(widget.posyandu.id!);
    _refreshAllData();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Daftarkan RouteObserver
    routeObserver.subscribe(this, ModalRoute.of(context)! as PageRoute);
  }

  @override
  void dispose() {
    // Lepaskan RouteObserver
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // Dipanggil ketika kembali ke halaman ini
    _refreshAllData();
    super.didPopNext();
  }

  // Fungsi untuk memuat ulang data balita dan data kematian
  void _refreshAllData() async {
    await _refreshKematianList();
    _refreshBalitaList();
  }

  // Fungsi untuk memuat ulang data kematian
  Future<void> _refreshKematianList() async {
    try {
      final List<Kematian> kematianList =
          await _kematianService.getAllKematian();
      setState(() {
        _idBalitaMeninggal = kematianList.map((k) => k.balitaId).toList();
      });
    } catch (e) {
      // Optional: tampilkan error jika gagal load kematian
      debugPrint('Gagal memuat data kematian: $e');
    }
  }

  // Fungsi untuk memuat ulang data dari API
  void _refreshBalitaList() {
    setState(() {
      _balitaList = _balitaService.GetBalitaByPosyandu(widget.posyandu.id!);
    });
  }

  // Fungsi untuk menghitung usia dalam tahun
  int _calculateAge(DateTime birthDate) {
    final today = DateTime.now();
    int age = today.year - birthDate.year;
    if (today.month < birthDate.month ||
        (today.month == birthDate.month && today.day < birthDate.day)) {
      age--;
    }
    return age;
  }

  // Fungsi untuk memfilter balita berdasarkan usia dan pencarian
  List<BalitaModel> _filterBalita(List<BalitaModel> allBalita) {
    List<BalitaModel> filtered = allBalita;

    // Filter berdasarkan status tanpa mode aktif/riwayat
    if (_statusFilter == 'semua') {
      // Semua balita
      // Tidak filter tambahan
    } else if (_statusFilter == 'aktif') {
      filtered =
          filtered
              .where(
                (balita) =>
                    _calculateAge(balita.tanggalLahir) < 6 &&
                    !_idBalitaMeninggal.contains(balita.id),
              )
              .toList();
    } else if (_statusFilter == 'tidak_aktif') {
      filtered =
          filtered
              .where(
                (balita) =>
                    _calculateAge(balita.tanggalLahir) >= 6 &&
                    !_idBalitaMeninggal.contains(balita.id),
              )
              .toList();
    } else if (_statusFilter == 'meninggal') {
      filtered =
          filtered
              .where((balita) => _idBalitaMeninggal.contains(balita.id))
              .toList();
    }

    // Filter berdasarkan pencarian
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered =
          filtered.where((balita) {
            return balita.nama.toLowerCase().contains(query) ||
                balita.nik.toLowerCase().contains(query) ||
                balita.namaIbu.toLowerCase().contains(query) ||
                balita.alamat.toLowerCase().contains(query);
          }).toList();
    }

    return filtered;
  }

  // Fungsi untuk navigasi dan memuat ulang data setelah kembali
  void _navigateAndRefresh(Widget page) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => page),
    );
    if (result != null) {
      _refreshAllData();
    }
  }

  void _hapusBalita(BalitaModel balita) async {
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus data balita "${balita.nama}"?',
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Hapus'),
            ),
          ],
        );
      },
    );

    if (konfirmasi == true && mounted) {
      try {
        await _balitaService.DeleteBalita(balita.id!);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data balita "${balita.nama}" berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
        _refreshAllData();
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Terjadi kesalahan: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Widget helper untuk membangun setiap item dalam daftar balita
  Widget _buildBalitaListItem(BalitaModel balita) {
    // Cek apakah balita sudah tercatat meninggal
    final bool isDeceased = balita.tanggalKematian != null;
    final int age = _calculateAge(balita.tanggalLahir);

    return BalitaCard(
      balita: balita,
      age: age,
      isDeceased: isDeceased,
      onTap: () => _navigateAndRefresh(BalitaDetailScreen(balita: balita)),
      onDelete: isDeceased ? null : () => _hapusBalita(balita),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Expanded(
              child: Text(
                widget.posyandu.namaPosyandu,
                style: const TextStyle(
                  color: Color(0xFF00897B),
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: Colors.white,
        elevation: 2,
        leading: Container(
          margin: const EdgeInsets.only(left: 8),
          decoration: BoxDecoration(
            color: Colors.teal.withOpacity(0.12),
            borderRadius: BorderRadius.circular(10),
          ),
          child: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Color(0xFF00897B),
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        actions: [
          Builder(
            builder:
                (context) => Container(
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: Colors.teal.withOpacity(0.12),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: Color(0xFF00897B)),
                    onPressed: () => Scaffold.of(context).openEndDrawer(),
                    tooltip: 'Filter Data',
                  ),
                ),
          ),
        ],
      ),
      endDrawer: _buildFilterSidebar(),
      extendBodyBehindAppBar: false,
      backgroundColor: const Color(0xFFF6F8FA),
      body: Column(
        children: [
          // Gradient header background
          Container(
            width: double.infinity,
            height: 110,
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00897B), Color(0xFF26A69A)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(24),
                bottomRight: Radius.circular(24),
              ),
            ),
            child: const SizedBox(),
          ),
          // Search Bar
          Transform.translate(
            offset: const Offset(0, -40),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Material(
                elevation: 3,
                borderRadius: BorderRadius.circular(16),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: TextField(
                    controller: _searchController,
                    onChanged: (value) {
                      setState(() {
                        _searchQuery = value;
                      });
                    },
                    decoration: InputDecoration(
                      hintText:
                          'Cari berdasarkan nama balita, NIK, nama ibu, atau alamat...',
                      prefixIcon: const Icon(
                        Icons.search,
                        color: Color(0xFF00897B),
                      ),
                      suffixIcon:
                          _searchQuery.isNotEmpty
                              ? IconButton(
                                icon: const Icon(
                                  Icons.clear,
                                  color: Colors.redAccent,
                                ),
                                onPressed: () {
                                  _searchController.clear();
                                  setState(() {
                                    _searchQuery = '';
                                  });
                                },
                              )
                              : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ),
            ),
          ),
          // Info jumlah data dan filter
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: FutureBuilder<List<BalitaModel>>(
              future: _balitaList,
              builder: (context, snapshot) {
                if (!snapshot.hasData || snapshot.data == null) {
                  return const SizedBox.shrink();
                }
                final allBalita = snapshot.data!;
                final filteredBalita = _filterBalita(allBalita);
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 12,
                  ),
                  margin: const EdgeInsets.only(bottom: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.teal.withOpacity(0.08),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.teal.shade700),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Menampilkan ${filteredBalita.length} dari ${allBalita.length} balita',
                          style: const TextStyle(
                            color: Color(0xFF00897B),
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          // Filter status hanya melalui sidebar, Dropdown di body dihapus
          Expanded(
            child: FutureBuilder<List<BalitaModel>>(
              future: _balitaList,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: LoadingIndicator());
                }
                if (snapshot.hasError) {
                  return Center(
                    child: Text('Gagal memuat data: \\${snapshot.error}'),
                  );
                }
                if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sentiment_dissatisfied,
                          size: 70,
                          color: Colors.teal.shade200,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          'Belum ada data balita',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.teal.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                final allBalita = snapshot.data!;
                final filteredBalita = _filterBalita(allBalita);
                if (filteredBalita.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.sentiment_dissatisfied,
                          size: 70,
                          color: Colors.teal.shade200,
                        ),
                        const SizedBox(height: 18),
                        Text(
                          _searchQuery.isNotEmpty
                              ? 'Tidak ada data yang sesuai dengan pencarian'
                              : 'Belum ada data balita',
                          style: TextStyle(
                            fontSize: 17,
                            color: Colors.teal.shade400,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  );
                }
                return RefreshIndicator(
                  onRefresh: () async => _refreshAllData(),
                  child: ListView.builder(
                    padding: const EdgeInsets.only(
                      left: 8,
                      right: 8,
                      bottom: 80,
                    ),
                    itemCount: filteredBalita.length,
                    itemBuilder: (context, index) {
                      return _buildBalitaListItem(filteredBalita[index]);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => BalitaFormScreen(posyanduId: widget.posyandu.id!),
            ),
          ).then((_) => _refreshAllData());
        },
        tooltip: 'Tambah Balita',
        backgroundColor: const Color(0xFF00897B),
        child: const Icon(Icons.person_add, color: Colors.white),
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }
}
