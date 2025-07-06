import 'package:flutter/material.dart ';
import 'package:flutter_application_1/API/authservice.dart';
import 'package:flutter_application_1/screens/kohort_form_screen.dart';
import 'package:flutter_application_1/screens/kohort_detail_screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:intl/intl.dart';
import '../API/PosyanduService.dart';
import '../models/posyanduModel.dart';
// TODO: Buat atau sesuaikan screen berikut untuk bekerja dengan PosyanduModel
// import 'posyandu_form_screen.dart';
// import 'posyandu_detail_screen.dart';

// ===================================================================
// Widget untuk Background.
// Bisa juga diletakkan di file terpisah (misal: widgets/login_background.dart)
// dan di-import, tapi untuk kemudahan, kita gabungkan di sini.
// ===================================================================
class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    // Pastikan path 'lib/images/BackgrounLogin.png' sudah benar
    // dan sudah terdaftar di pubspec.yaml
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/BackgrounLogin.png'),
          fit: BoxFit.cover,
        ),
      ),
      // Memberikan lapisan warna gelap agar gambar tidak terlalu terang
      // dan teks lebih mudah dibaca.
      child: Container(
        color: const Color.fromARGB(
          255,
          255,
          255,
          255,
        ).withOpacity(0.5), // Sesuaikan opasitas sesuai selera
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

    // TODO: Ganti '1' dengan ID user yang sedang login.
    // Anda mungkin perlu mendapatkan ID ini dari SharedPreferences setelah login.
    await _posyanduService.GetPosyanduByUser();

    // Karena GetPosyanduByUser tidak mengembalikan apa-apa dan hanya mengisi
    // list global, kita perlu memanggil setState setelahnya untuk me-render ulang UI.
    setState(() {
      // Data sekarang ada di variabel global `posyanduList`
      _isLoading = false;
    });
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

  @override
  Widget build(BuildContext context) {
    // Gunakan Stack untuk menumpuk background dengan konten
    return Stack(
      children: [
        // LAPISAN 1: Widget background yang akan berada di paling belakang
        const LoginBackground(),

        // LAPISAN 2: Scaffold yang berisi semua UI (AppBar, Body, Tombol)
        Scaffold(
          // Atur background Scaffold menjadi transparan agar background di Stack terlihat
          backgroundColor: const Color.fromARGB(0, 255, 255, 255),
          appBar: AppBar(
            title: const Text('Manajer Posyandu'),
            // Atur background AppBar juga menjadi transparan
            backgroundColor: const Color.fromARGB(0, 255, 255, 255),
            // Hilangkan bayangan di bawah AppBar agar menyatu dengan background
            elevation: 0,
            actions: [
              // Menu untuk melihat info user dan logout
              PopupMenuButton<String>(
                onSelected: (value) async {
                  if (value == 'profile') {
                    // Tampilkan info user
                    final user = await AuthService.getCurrentUser();
                    if (user != null) {
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
                        color: Colors.black87, // Warna diubah agar terbaca
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
                            trailing: const Icon(
                              Icons.chevron_right,
                              color: Colors.blue,
                            ),
                            onTap: () {
                              // Navigasi ke detail screen yang sudah dimodifikasi
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  // Mengirim data posyandu ke detail screen
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
              ).then((_) => _fetchPosyanduData());
            },
            child: const Icon(Icons.add),
          ),
        ),
      ],
    );
  }
}
