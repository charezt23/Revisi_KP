import 'package:flutter/material.dart';
import 'package:flutter_application_1/API/authservice.dart';
import 'package:flutter_application_1/screens/From_posyandu.dart';
import 'package:flutter_application_1/screens/Daftar_Balita.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:intl/intl.dart';
import 'package:flutter_application_1/widgets/login_background.dart';
import '../API/PosyanduService.dart';
import '../models/posyanduModel.dart';

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
          // Gunakan ?? [] untuk memastikan list tidak pernah null
          _posyanduList = fetchedList ?? [];
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
      title: const Text('Manajer Posyandu'),
      backgroundColor: const Color.fromARGB(255, 255, 255, 255),
      elevation: 0,
      actions: [
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
    return RefreshIndicator(
      onRefresh: _fetchPosyanduData,
      child: ListView.builder(
        itemCount: _posyanduList.length,
        itemBuilder: (context, index) {
          final posyandu = _posyanduList[index];
          return _buildPosyanduCard(posyandu);
        },
      ),
    );
  }

  // Widget Empty State
  Widget _buildEmptyState() {
    return const Center(
      child: Text(
        'Belum ada data Posyandu. Tekan + untuk membuat.',
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black87,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // Widget Loading State
  Widget _buildLoadingState() {
    return const Center(child: CircularProgressIndicator());
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        const LoginBackground(),
        Scaffold(
          backgroundColor: const Color.fromARGB(255, 255, 255, 255),
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
