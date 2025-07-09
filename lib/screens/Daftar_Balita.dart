import 'package:flutter/material.dart';
import 'package:flutter_application_1/API/BalitaService.dart';
import 'package:flutter_application_1/API/kematianService.dart';
import 'package:flutter_application_1/models/posyanduModel.dart';
import 'package:flutter_application_1/models/balitaModel.dart';
import 'package:flutter_application_1/screens/Balita_Form_Screen.dart';
import 'package:flutter_application_1/screens/balita_detail_screen.dart';
import 'package:flutter_application_1/widgets/login_background.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/models/kematian.dart';

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
  late Future<List<BalitaModel>> _balitaList;
  final Balitaservice _balitaService = Balitaservice();
  final KematianService _kematianService = KematianService();
  final TextEditingController _searchController = TextEditingController();
  bool _showHistoryMode = false; // false = aktif (< 6 tahun), true = semua data
  String _searchQuery = '';

  // Tambahan: daftar id balita yang sudah meninggal (patch frontend)
  List<int> _idBalitaMeninggal = [];
  bool _isLoadingKematian = false;

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

    // Filter berdasarkan mode tampilan (aktif atau riwayat)
    if (!_showHistoryMode) {
      filtered =
          filtered
              .where(
                (balita) =>
                    _calculateAge(balita.tanggalLahir) < 6 &&
                    !_idBalitaMeninggal.contains(balita.id),
              )
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

    return Card(
      // Beri warna latar yang berbeda jika balita meninggal
      color:
          isDeceased
              ? Colors.red.withOpacity(0.1)
              : age >= 6
              ? Colors.orange.withOpacity(0.1)
              : Colors.white.withOpacity(0.9),
      child: ListTile(
        // Ganti ikon berdasarkan status
        leading: Icon(
          isDeceased
              ? Icons.person_off_outlined
              : age >= 6
              ? Icons.history
              : Icons.child_care,
          color:
              isDeceased
                  ? Colors.red.shade700
                  : age >= 6
                  ? Colors.orange.shade700
                  : Theme.of(context).primaryColor,
        ),
        title: Text(
          balita.nama,
          style: TextStyle(
            // Beri coretan pada nama jika balita meninggal
            decoration: isDeceased ? TextDecoration.lineThrough : null,
            color: isDeceased ? Colors.red.shade700 : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NIK: ${balita.nik}'),
            Text(
              // Tampilkan tanggal kematian jika ada, jika tidak tampilkan nama ibu
              isDeceased
                  ? 'Meninggal: ${DateFormat('dd MMMM yyyy').format(balita.tanggalKematian!)}'
                  : 'Ibu: ${balita.namaIbu} | Usia: $age tahun',
            ),
          ],
        ),
        onTap: () => _navigateAndRefresh(BalitaDetailScreen(balita: balita)),
        // Sembunyikan tombol hapus jika balita sudah meninggal
        trailing:
            isDeceased
                ? null
                : IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: () => _hapusBalita(balita),
                  tooltip: 'Hapus Balita',
                ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.posyandu.namaPosyandu),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          // Tombol untuk toggle mode tampilan (aktif/riwayat)
          IconButton(
            icon: Icon(
              _showHistoryMode ? Icons.history : Icons.people,
              color: _showHistoryMode ? Colors.orange : Colors.blue,
            ),
            onPressed: () {
              setState(() {
                _showHistoryMode = !_showHistoryMode;
              });
            },
            tooltip:
                _showHistoryMode ? 'Tampilkan Data Aktif' : 'Tampilkan Riwayat',
          ),
        ],
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const LoginBackground(),
          Column(
            children: [
              // Status indicator
              Container(
                margin: const EdgeInsets.only(top: 100, left: 16, right: 16),
                padding: const EdgeInsets.symmetric(
                  vertical: 8,
                  horizontal: 16,
                ),
                decoration: BoxDecoration(
                  color:
                      _showHistoryMode
                          ? Colors.orange.withOpacity(0.1)
                          : Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _showHistoryMode ? Colors.orange : Colors.blue,
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _showHistoryMode ? Icons.history : Icons.people,
                      size: 16,
                      color: _showHistoryMode ? Colors.orange : Colors.blue,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _showHistoryMode
                          ? 'Menampilkan Semua Data (Riwayat)'
                          : 'Menampilkan Data Aktif (< 6 tahun)',
                      style: TextStyle(
                        color: _showHistoryMode ? Colors.orange : Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Search Bar
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
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
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    filled: true,
                    fillColor: Colors.white.withOpacity(0.9),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              // Data List
              Expanded(
                child: FutureBuilder<List<BalitaModel>>(
                  future: _balitaList,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Gagal memuat data: \\${snapshot.error}'),
                      );
                    }
                    if (!snapshot.hasData || snapshot.data!.isEmpty) {
                      return const Center(
                        child: Text('Belum ada data balita.'),
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
                              Icons.search_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchQuery.isNotEmpty
                                  ? 'Tidak ada data yang sesuai dengan pencarian'
                                  : _showHistoryMode
                                  ? 'Belum ada data riwayat'
                                  : 'Belum ada data balita aktif',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.grey[600],
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
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => _navigateAndRefresh(
              BalitaFormScreen(posyanduId: widget.posyandu.id!),
            ),
        tooltip: 'Tambah Balita',
        child: const Icon(Icons.add),
      ),
    );
  }
}
