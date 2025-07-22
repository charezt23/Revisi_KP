import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/API/authservice.dart';
import 'package:flutter_application_1/presentation/screens/Pemeriksaan/From_posyandu.dart';
import 'package:flutter_application_1/presentation/screens/Daftar_Balita.dart';
import 'package:flutter_application_1/presentation/screens/login_screen.dart';
import 'package:flutter_application_1/presentation/screens/main_menu_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/presentation/screens/components/login_background.dart';
import 'package:flutter_application_1/presentation/screens/components/loading_indicator.dart';
import '../../data/API/PosyanduService.dart';
import '../../data/models/posyanduModel.dart';

// ===================================================================
// Widget Utama HomeScreen
// ===================================================================
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final Posyanduservice _posyanduService = Posyanduservice();
  List<PosyanduModel> _posyanduList = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosyanduData();
  }

  Future<void> _fetchPosyanduData() async {
    // Hanya set state jika widget masih terpasang (mounted)
    if (mounted) setState(() => _isLoading = true);

    try {
      // Ambil data dan simpan ke state lokal
      final fetchedList = await _posyanduService.GetPosyanduByUser();
      if (mounted) {
        setState(() {
          _posyanduList = fetchedList;
        });
      }
    } catch (e) {
      // Tangani error jika gagal mengambil data
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Method untuk menampilkan info user
  void _showUserInfo(user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Informasi Pengguna'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('ID: ${user.id}'),
              const SizedBox(height: 8),
              Text('Nama: ${user.name}'),
              const SizedBox(height: 8),
              Text('Email: ${user.email}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Tutup'),
            ),
          ],
        );
      },
    );
  }

  // Method untuk menampilkan dialog logout
  Future<void> _showLogoutDialog() async {
    // `showDialog` returns a Future. We can await its result.
    final bool? shouldLogout = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              // Pop the dialog and return `false`
              onPressed: () => Navigator.of(dialogContext).pop(false),
              child: const Text('Batal'),
            ),
            TextButton(
              // Pop the dialog and return `true`
              onPressed: () => Navigator.of(dialogContext).pop(true),
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );

    // This code will only run AFTER the dialog is closed.
    // The `context` here is the original, valid _HomeScreenState context.
    if (shouldLogout == true) {
      await AuthService.logout();
      if (!mounted) return; // Always check `mounted` after an `await`.
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (_) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  // Method untuk menghapus Posyandu
  Future<void> _hapusPosyandu(PosyanduModel posyandu) async {
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus Posyandu "${posyandu.namaPosyandu}"? Semua data balita yang terkait akan ikut terhapus.',
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

    if (konfirmasi == true) {
      try {
        // Panggil service untuk menghapus
        await _posyanduService.DeletePosyandu(posyandu.id!);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Posyandu "${posyandu.namaPosyandu}" berhasil dihapus.',
            ),
            backgroundColor: Colors.green,
          ),
        );
        // Muat ulang daftar untuk memperbarui UI
        await _fetchPosyanduData();
      } catch (e) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal menghapus: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Widget AppBar
  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Daftar Posyandu'),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back, color: Colors.black),
        onPressed: () {
          Navigator.pop(context);
        },
        tooltip: 'Kembali',
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.apps, color: Color(0xFF03A9F4)),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const MainMenuScreen()),
            );
          },
          tooltip: 'Menu Aplikasi',
        ),
        IconButton(
          icon: const Icon(Icons.logout),
          onPressed: _showLogoutDialog,
          tooltip: 'Logout',
        ),
        PopupMenuButton<String>(
          onSelected: (value) async {
            if (value == 'profile') {
              final user = await AuthService.getCurrentUser();
              if (user != null && mounted) _showUserInfo(user);
            }
          },
          itemBuilder:
              (BuildContext context) => [
                const PopupMenuItem<String>(
                  value: 'profile',
                  child: Row(
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 8),
                      Text('Profil'),
                    ],
                  ),
                ),
              ],
        ),
      ],
    );
  }

  // Widget FloatingActionButton
  Widget _buildFAB() {
    return FloatingActionButton(
      onPressed: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => const KohortFormScreen()),
        ).then((_) => _fetchPosyanduData());
      },
      child: const Icon(Icons.add),
    );
  }

  // Widget Card Posyandu
  Widget _buildPosyanduCard(PosyanduModel posyandu) {
    return Card(
      color: const Color.fromARGB(255, 255, 255, 255).withOpacity(0.9),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: const Icon(Icons.local_hospital, color: Colors.red, size: 40),
        title: Text(
          posyandu.namaPosyandu,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dibuat: ${posyandu.createdAt != null ? DateFormat('dd MMM yyyy').format(posyandu.createdAt!) : 'N/A'}',
            ),
            Text('Jumlah Balita: ${posyandu.balitaCount ?? 0}'),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _hapusPosyandu(posyandu),
              tooltip: 'Hapus Posyandu',
            ),
            const Icon(Icons.chevron_right, color: Colors.blue),
          ],
        ),
        onTap: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => KohortDetailScreen(posyandu: posyandu),
            ),
          );
          if (result == true && mounted) {
            _fetchPosyanduData();
          }
        },
      ),
    );
  }

  // Widget List Posyandu
  Widget _buildPosyanduList() {
    return Column(
      children: [
        // Card Menu di bagian atas
        _buildMenuCard(),
        // List posyandu
        Expanded(
          child: RefreshIndicator(
            onRefresh: _fetchPosyanduData,
            child: ListView.builder(
              itemCount: _posyanduList.length,
              itemBuilder: (context, index) {
                final posyandu = _posyanduList[index];
                return _buildPosyanduCard(posyandu);
              },
            ),
          ),
        ),
      ],
    );
  }

  // Widget Card Menu
  Widget _buildMenuCard() {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Card(
        elevation: 8,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: const LinearGradient(
              colors: [Color(0xFF03A9F4), Color(0xFF29B6F6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.apps,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 16),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Menu Aplikasi',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          'Akses semua fitur aplikasi dengan mudah',
                          style: TextStyle(color: Colors.white70, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: IconButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainMenuScreen(),
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.arrow_forward,
                        color: Color(0xFF03A9F4),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Widget Empty State
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.9),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                ),
              ],
            ),
            margin: const EdgeInsets.all(20),
            child: Column(
              children: [
                const Icon(
                  Icons.local_hospital,
                  size: 64,
                  color: Color(0xFF03A9F4),
                ),
                const SizedBox(height: 16),
                const Text(
                  'Belum ada Posyandu',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Tambah posyandu pertama Anda untuk memulai mengelola data balita.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.black54, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const KohortFormScreen(),
                          ),
                        ).then((_) => _fetchPosyanduData());
                      },
                      icon: const Icon(Icons.add),
                      label: const Text('Tambah'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF03A9F4),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const MainMenuScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.apps),
                      label: const Text('Menu'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Widget Loading State
  Widget _buildLoadingState() {
    return const Center(child: LoadingIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const LoginBackground(),
        Scaffold(
          backgroundColor: const Color.fromARGB(200, 255, 255, 255),
          appBar: _buildAppBar(),
          body:
              _isLoading
                  ? _buildLoadingState()
                  : _posyanduList.isEmpty
                  ? _buildEmptyState()
                  : _buildPosyanduList(),
          floatingActionButton: _buildFAB(),
        ),
      ],
    );
  }
}
