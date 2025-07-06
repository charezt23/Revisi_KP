import 'package:flutter/material.dart';
import 'package:flutter_application_1/databse/dummy_data_service.dart'; // Sesuaikan path jika perlu
import 'package:flutter_application_1/API/authservice.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:intl/intl.dart';

import '../models/kohort_model.dart'; // Sesuaikan path jika perlu
import 'kohort_form_screen.dart'; // Sesuaikan path jika perlu
import 'kohort_detail_screen.dart'; // Sesuaikan path jika perlu

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
  late Future<List<Kohort>> _kohortList;

  @override
  void initState() {
    super.initState();
    _updateKohortList();
  }

  void _updateKohortList() {
    setState(() {
      _kohortList = DummyDataService().getKohortList();
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
            title: const Text('Manajer Kohort'),
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
          body: FutureBuilder<List<Kohort>>(
            future: _kohortList,
            builder: (context, snapshot) {
              // Menampilkan loading indicator saat data sedang diambil
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              // Menampilkan pesan jika tidak ada data atau data kosong
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada kohort. Tekan + untuk membuat.',
                    textAlign: TextAlign.center,
                    // Tambahkan style agar teks terlihat jelas di atas background
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }

              // Menampilkan daftar kohort jika data tersedia
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final kohort = snapshot.data![index];
                  // Card memiliki warna default, sehingga konten di dalamnya akan tetap mudah dibaca
                  return Card(
                    // Beri sedikit transparansi pada Card agar background sedikit terlihat
                    color: Colors.white.withOpacity(0.9),
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: ListTile(
                      leading: const Icon(Icons.groups, size: 40),
                      title: Text(
                        kohort.nama,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(
                        'Dibuat: ${DateFormat('dd MMM yyyy').format(kohort.tanggalDibuat)}',
                      ),
                      trailing: FutureBuilder<int>(
                        future: DummyDataService().getAnggotaCount(kohort.id!),
                        builder: (context, countSnapshot) {
                          if (countSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            );
                          }
                          return Chip(
                            label: Text('${countSnapshot.data ?? 0} Anggota'),
                            backgroundColor:
                                Theme.of(context).colorScheme.primaryContainer,
                          );
                        },
                      ),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => KohortDetailScreen(kohort: kohort),
                            ),
                          ).then((_) => _updateKohortList()),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed:
                () => Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const KohortFormScreen()),
                ).then((_) => _updateKohortList()),
            icon: const Icon(Icons.add),
            label: const Text('Buat Kohort'),
          ),
        ),
      ],
    );
  }
}

// ===================================================================
// Fungsi main di bawah ini hanya untuk keperluan testing.
// Anda bisa menjalankan file ini secara langsung dari IDE Anda
// untuk melihat tampilan HomeScreen tanpa melewati halaman login.
// ===================================================================
