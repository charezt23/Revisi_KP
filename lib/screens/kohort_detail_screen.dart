import 'package:flutter/material.dart';
import 'package:flutter_application_1/API/BalitaService.dart'; // Menggunakan service API
import 'package:flutter_application_1/models/posyanduModel.dart'; // Menggunakan model Posyandu
import 'package:flutter_application_1/models/balitaModel.dart';
import 'package:flutter_application_1/screens/anggota_form_screen.dart';
import 'package:flutter_application_1/screens/balita_detail_screen.dart';
import 'package:flutter_application_1/widgets/login_background.dart';

class KohortDetailScreen extends StatefulWidget {
  final PosyanduModel posyandu; // Diubah dari Kohort ke PosyanduModel
  const KohortDetailScreen({Key? key, required this.posyandu})
    : super(key: key);

  @override
  State<KohortDetailScreen> createState() => _KohortDetailScreenState();
}

class _KohortDetailScreenState extends State<KohortDetailScreen> {
  late Future<List<BalitaModel>> _balitaList;
  final Balitaservice _balitaService = Balitaservice(); // Instance service

  @override
  void initState() {
    super.initState();
    _updateBalitaList();
  }

  void _updateBalitaList() {
    setState(() {
      // Mengambil data dari API berdasarkan ID Posyandu
      _balitaList = _balitaService.GetBalitaByPosyandu(widget.posyandu.id!);
    });
  }

  // 1. Fungsi untuk menangani penghapusan anggota
  void _hapusBalita(BalitaModel balita) async {
    // 2. Tampilkan dialog konfirmasi
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

    // 3. Jika dikonfirmasi, jalankan proses hapus
    if (konfirmasi == true) {
      try {
        await _balitaService.DeleteBalita(balita.id!);
        if (!mounted) return;

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data balita "${balita.nama}" berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
        // 4. Muat ulang daftar balita untuk memperbarui UI
        _updateBalitaList();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.posyandu.namaPosyandu,
        ), // Menggunakan nama dari Posyandu
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const LoginBackground(),
          FutureBuilder<List<BalitaModel>>(
            future: _balitaList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Text(
                      'Gagal memuat data: ${snapshot.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                );
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada data balita. Tekan + untuk menambah.',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.only(
                  top: 100,
                  left: 8,
                  right: 8,
                  bottom: 80,
                ),
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final balita = snapshot.data![index];
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(balita.nama[0])),
                      title: Text(balita.nama),
                      subtitle: Text('NIK: ${balita.nik}'),
                      onTap:
                          () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder:
                                  (_) => BalitaDetailScreen(balita: balita),
                            ),
                          ).then((_) => _updateBalitaList()),
                      // --- PERUBAHAN UTAMA DI SINI ---
                      // Menggunakan Row untuk menampung dua tombol ikon
                      trailing: Row(
                        mainAxisSize:
                            MainAxisSize
                                .min, // Agar Row tidak memakan semua tempat
                        children: [
                          // Tombol untuk Menghapus
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _hapusBalita(balita),
                            tooltip: 'Hapus Anggota',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed:
            () => Navigator.push(
              context,
              MaterialPageRoute(
                builder:
                    (_) => BalitaFormScreen(posyanduId: widget.posyandu.id!),
              ),
            ).then((_) => _updateBalitaList()),
        tooltip: 'Tambah Anggota',
        child: const Icon(Icons.add),
      ),
    );
  }
}
