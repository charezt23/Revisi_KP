import 'package:flutter/material.dart';
import 'package:flutter_application_1/API/authservice.dart';
import 'package:flutter_application_1/screens/kohort_form_screen.dart';
import 'package:flutter_application_1/screens/kohort_detail_screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:intl/intl.dart';
import '../API/PosyanduService.dart';
import '../models/posyanduModel.dart';

// ===================================================================
// Widget untuk Background.
// ===================================================================
class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/BackgrounLogin.png'),
          fit: BoxFit.cover,
        ),
      ),
      // Memberikan lapisan warna gelap agar gambar tidak terlalu terang
      child: Container(
        color: const Color.fromARGB(
          255,
          255,
          255,
          255,
        ).withOpacity(0.5), // Sesuaikan opasitas
      ),
    );
  }
}

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
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchPosyanduData();
  }

  Future<void> _fetchPosyanduData() async {
    setState(() {
      _isLoading = true;
    });

    // Mengambil data posyandu berdasarkan user yang login
    await _posyanduService.GetPosyanduByUser();

    // Memanggil setState untuk me-render ulang UI dengan data baru
    if (mounted) {
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
  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Logout'),
          content: const Text('Apakah Anda yakin ingin keluar?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Tutup dialog
                await AuthService.logout(); // Hapus data login

                // Navigasi ke login screen dan hapus semua route sebelumnya
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              child: const Text('Logout'),
            ),
          ],
        );
      },
    );
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

  @override
  Widget build(BuildContext context) {
    // Gunakan Stack untuk menumpuk background dengan konten
    return Stack(
      children: [
        // LAPISAN 1: Widget background
        const LoginBackground(),

        // LAPISAN 2: Scaffold yang berisi UI
        Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Manajer Posyandu'),
            backgroundColor: Colors.transparent,
            elevation: 0,
            actions: [
              // Menu untuk melihat info user dan logout
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'profile') {
                    // Tampilkan info user
                    final user = await AuthService.getCurrentUser();
                    if (user != null && mounted) {
                      _showUserInfo(user);
                    }
                  } else if (value == 'logout') {
                    _showLogoutDialog();
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
                      const PopupMenuItem<String>(
                        value: 'logout',
                        child: Row(
                          children: [
                            Icon(Icons.logout),
                            SizedBox(width: 8),
                            Text('Logout'),
                          ],
                        ),
                      ),
                    ],
              ),
            ],
          ),
          body:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : posyanduList.isEmpty
                  ? const Center(
                    child: Text(
                      'Belum ada data Posyandu. Tekan + untuk membuat.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )
                  : RefreshIndicator(
                    onRefresh: _fetchPosyanduData,
                    child: ListView.builder(
                      itemCount: posyanduList.length,
                      itemBuilder: (context, index) {
                        final posyandu = posyanduList[index];
                        return Card(
                          color: const Color.fromARGB(
                            255,
                            255,
                            255,
                            255,
                          ).withOpacity(0.9),
                          margin: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          child: ListTile(
                            leading: const Icon(
                              Icons.local_hospital,
                              color: Colors.red,
                              size: 40,
                            ),
                            title: Text(
                              posyandu.namaPosyandu,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            subtitle: Text(
                              'Dibuat: ${posyandu.createdAt != null ? DateFormat('dd MMM yyyy').format(posyandu.createdAt!) : 'N/A'}',
                            ),
                            trailing: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete_outline,
                                    color: Colors.red,
                                  ),
                                  onPressed: () => _hapusPosyandu(posyandu),
                                  tooltip: 'Hapus Posyandu',
                                ),
                                const Icon(
                                  Icons.chevron_right,
                                  color: Colors.blue,
                                ),
                              ],
                            ),
                            onTap: () {
                              // Navigasi ke detail screen
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder:
                                      (_) => KohortDetailScreen(
                                        posyandu: posyandu,
                                      ),
                                ),
                              );
                            },
                          ),
                        );
                      },
                    ),
                  ),
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const KohortFormScreen()),
              ).then(
                (_) => _fetchPosyanduData(),
              ); // Muat ulang data setelah kembali
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
