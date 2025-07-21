import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/API/authservice.dart';
import 'package:flutter_application_1/presentation/screens/Home_Screen.dart';
import 'package:flutter_application_1/presentation/screens/Login/login_screen.dart';

class SideBar extends StatelessWidget {
  const SideBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          // Header Drawer
          FutureBuilder(
            future: AuthService.getCurrentUser(),
            builder: (context, snapshot) {
              return UserAccountsDrawerHeader(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [Colors.blue, Colors.blueAccent],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                accountName: Text(
                  snapshot.hasData ? snapshot.data!.name : 'Loading...',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                accountEmail: Text(
                  snapshot.hasData ? snapshot.data!.email : 'Loading...',
                ),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Icon(
                    Icons.person,
                    size: 40,
                    color: Colors.blue.shade700,
                  ),
                ),
              );
            },
          ),

          // Menu Items
          ListTile(
            leading: const Icon(Icons.home, color: Colors.blue),
            title: const Text('Beranda'),
            onTap: () {
              Navigator.pop(context); // Close drawer
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const HomeScreen()),
              );
            },
          ),

          const Divider(),

          // Posyandu Section
          ExpansionTile(
            leading: const Icon(Icons.local_hospital, color: Colors.red),
            title: const Text('Posyandu'),
            children: [
              ListTile(
                leading: const Icon(
                  Icons.add_circle_outline,
                  color: Colors.green,
                ),
                title: const Text('Tambah Posyandu'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to add posyandu screen
                  // Implementasi sesuai dengan route yang ada
                },
              ),
              ListTile(
                leading: const Icon(Icons.list, color: Colors.orange),
                title: const Text('Daftar Posyandu'),
                onTap: () {
                  Navigator.pop(context);
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const HomeScreen()),
                  );
                },
              ),
            ],
          ),

          // Balita Section
          ExpansionTile(
            leading: const Icon(Icons.child_care, color: Colors.pink),
            title: const Text('Balita'),
            children: [
              ListTile(
                leading: const Icon(Icons.person_add, color: Colors.green),
                title: const Text('Tambah Balita'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to add balita screen
                  // Implementasi sesuai dengan route yang ada
                },
              ),
              ListTile(
                leading: const Icon(Icons.people, color: Colors.blue),
                title: const Text('Balita Aktif'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to active balita screen
                  // Implementasi sesuai dengan route yang ada
                },
              ),
              ListTile(
                leading: const Icon(Icons.people_outline, color: Colors.grey),
                title: const Text('Balita Inaktif'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to inactive balita screen
                  // Implementasi sesuai dengan route yang ada
                },
              ),
            ],
          ),

          // Kunjungan Section
          ExpansionTile(
            leading: const Icon(Icons.medical_services, color: Colors.teal),
            title: const Text('Kunjungan'),
            children: [
              ListTile(
                leading: const Icon(Icons.add_box, color: Colors.green),
                title: const Text('Catat Kunjungan'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to add kunjungan screen
                  // Implementasi sesuai dengan route yang ada
                },
              ),
              ListTile(
                leading: const Icon(Icons.history, color: Colors.indigo),
                title: const Text('Riwayat Kunjungan'),
                onTap: () {
                  Navigator.pop(context);
                  // Navigate to kunjungan history screen
                  // Implementasi sesuai dengan route yang ada
                },
              ),
            ],
          ),

          // Imunisasi Section
          ListTile(
            leading: const Icon(Icons.vaccines, color: Colors.purple),
            title: const Text('Imunisasi'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to imunisasi screen
              // Implementasi sesuai dengan route yang ada
            },
          ),

          // Data Kematian Section
          ListTile(
            leading: const Icon(
              Icons.sentiment_very_dissatisfied,
              color: Colors.red,
            ),
            title: const Text('Data Kematian'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to kematian screen
              // Implementasi sesuai dengan route yang ada
            },
          ),

          const Divider(),

          // Laporan Section
          ListTile(
            leading: const Icon(Icons.assessment, color: Colors.deepOrange),
            title: const Text('Laporan'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to laporan screen
              // Implementasi sesuai dengan route yang ada
            },
          ),

          // Statistik Section
          ListTile(
            leading: const Icon(Icons.bar_chart, color: Colors.cyan),
            title: const Text('Statistik'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to statistik screen
              // Implementasi sesuai dengan route yang ada
            },
          ),

          const Divider(),

          // Pengaturan Section
          ListTile(
            leading: const Icon(Icons.settings, color: Colors.grey),
            title: const Text('Pengaturan'),
            onTap: () {
              Navigator.pop(context);
              // Navigate to settings screen
              // Implementasi sesuai dengan route yang ada
            },
          ),

          // Profil Section
          ListTile(
            leading: const Icon(Icons.person, color: Colors.indigo),
            title: const Text('Profil'),
            onTap: () {
              Navigator.pop(context);
              _showUserProfile(context);
            },
          ),

          // Tentang Section
          ListTile(
            leading: const Icon(Icons.info, color: Colors.blueGrey),
            title: const Text('Tentang'),
            onTap: () {
              Navigator.pop(context);
              _showAboutDialog(context);
            },
          ),

          const Divider(),

          // Logout Section
          ListTile(
            leading: const Icon(Icons.exit_to_app, color: Colors.red),
            title: const Text('Keluar'),
            onTap: () {
              Navigator.pop(context);
              _showLogoutDialog(context);
            },
          ),
        ],
      ),
    );
  }

  // Method untuk menampilkan profil user
  void _showUserProfile(BuildContext context) async {
    final user = await AuthService.getCurrentUser();
    if (user != null) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text('Informasi Profil'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.person, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Nama: ${user.name}')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.email, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text('Email: ${user.email}')),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.badge, color: Colors.blue),
                    const SizedBox(width: 8),
                    Expanded(child: Text('ID: ${user.id}')),
                  ],
                ),
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
  }

  // Method untuk menampilkan dialog about
  void _showAboutDialog(BuildContext context) {
    showAboutDialog(
      context: context,
      applicationName: 'Pencatatan Kesehatan',
      applicationVersion: '1.0.0',
      applicationIcon: const Icon(Icons.local_hospital, size: 48),
      children: [
        const Text(
          'Aplikasi untuk pencatatan data kesehatan balita di posyandu.',
        ),
        const SizedBox(height: 8),
        const Text(
          'Dibuat untuk membantu petugas posyandu dalam mengelola data balita.',
        ),
      ],
    );
  }

  // Method untuk menampilkan dialog logout
  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Keluar'),
          content: const Text('Apakah Anda yakin ingin keluar dari aplikasi?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Batal'),
            ),
            TextButton(
              onPressed: () async {
                Navigator.of(context).pop(); // Close dialog
                await AuthService.logout();
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(builder: (_) => const LoginScreen()),
                  (route) => false,
                );
              },
              style: TextButton.styleFrom(foregroundColor: Colors.red),
              child: const Text('Keluar'),
            ),
          ],
        );
      },
    );
  }
}

// Helper class untuk membuat item menu dengan badge
class MenuItemWithBadge extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;
  final String? badge;
  final Color? iconColor;

  const MenuItemWithBadge({
    Key? key,
    required this.icon,
    required this.title,
    required this.onTap,
    this.badge,
    this.iconColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Row(
        children: [
          Expanded(child: Text(title)),
          if (badge != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(
                badge!,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      onTap: onTap,
    );
  }
}
