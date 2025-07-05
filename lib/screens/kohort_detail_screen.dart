import 'package:flutter/material.dart';
import 'package:flutter_application_1/databse/dummy_data_service.dart';
import 'package:flutter_application_1/models/anggota_model.dart';
import 'package:flutter_application_1/models/kohort_model.dart';
import 'package:flutter_application_1/screens/Pemeriksaaan/KematianFormScreen.dart';
import 'package:flutter_application_1/screens/Pemeriksaaan/KunjunganFormScreen.dart';
import 'package:flutter_application_1/screens/Pemeriksaaan/imunisasi_form_screen.dart';

import 'package:flutter_application_1/screens/anggota_detail_screen.dart';
import 'package:flutter_application_1/screens/anggota_form_screen.dart';
import 'package:flutter_application_1/widgets/login_background.dart';

// Enum untuk jenis-jenis pemeriksaan agar kode lebih rapi
enum JenisPemeriksaan { imunisasi, kunjungan, kematian }

class KohortDetailScreen extends StatefulWidget {
  final Kohort kohort;
  const KohortDetailScreen({super.key, required this.kohort});

  @override
  State<KohortDetailScreen> createState() => _KohortDetailScreenState();
}

class _KohortDetailScreenState extends State<KohortDetailScreen> {
  late Future<List<Anggota>> _anggotaList;

  @override
  void initState() {
    super.initState();
    _updateAnggotaList();
  }

  void _updateAnggotaList() {
    setState(() {
      _anggotaList = DummyDataService().getAnggotaList(widget.kohort.id!);
    });
  }

  // 1. Fungsi untuk menangani penghapusan anggota
  void _hapusAnggota(Anggota anggota) async {
    // 2. Tampilkan dialog konfirmasi
    final bool? konfirmasi = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Konfirmasi Hapus'),
          content: Text(
            'Apakah Anda yakin ingin menghapus anggota "${anggota.nama}"?',
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
      await DummyDataService().deleteAnggota(anggota.id!);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Anggota "${anggota.nama}" berhasil dihapus.'),
            backgroundColor: Colors.green,
          ),
        );
        // 4. Muat ulang daftar anggota untuk memperbarui UI
        _updateAnggotaList();
      }
    }
  }

  // --- FUNGSI INI DIUBAH ---
  // Fungsi untuk menampilkan pop-up pilihan jenis pemeriksaan
  void _lakukanPemeriksaan(Anggota anggota) async {
    final JenisPemeriksaan? jenisTerpilih = await showDialog<JenisPemeriksaan>(
      context: context,
      builder: (BuildContext context) {
        return SimpleDialog(
          title: const Text('Pilih Jenis Pemeriksaan'),
          children: <Widget>[
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, JenisPemeriksaan.imunisasi);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Imunisasi'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, JenisPemeriksaan.kunjungan);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Kunjungan'),
              ),
            ),
            SimpleDialogOption(
              onPressed: () {
                Navigator.pop(context, JenisPemeriksaan.kematian);
              },
              child: const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text('Kematian'),
              ),
            ),
          ],
        );
      },
    );

    if (jenisTerpilih == null) return; // Keluar jika pengguna tidak memilih

    // Jika pengguna memilih Imunisasi, navigasi ke form baru
    if (jenisTerpilih == JenisPemeriksaan.imunisasi) {
      if (!mounted) return;
      // Navigasi ke ImunisasiFormScreen dan tunggu hasilnya.
      // Setelah kembali, panggil _updateAnggotaList untuk refresh data.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ImunisasiFormScreen(anggota: anggota),
        ),
      ).then((_) => _updateAnggotaList());
      return; // Hentikan eksekusi fungsi setelah navigasi
    }
    if (jenisTerpilih == JenisPemeriksaan.kunjungan) {
      if (!mounted) return;
      // Navigasi ke ImunisasiFormScreen dan tunggu hasilnya.
      // Setelah kembali, panggil _updateAnggotaList untuk refresh data.
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => KunjunganFormScreen(anggota: anggota),
        ),
      ).then((_) => _updateAnggotaList());
      return; // Hentikan eksekusi fungsi setelah navigasi
    }
    if (jenisTerpilih == JenisPemeriksaan.kematian) {
      if (!mounted) return;
      // Navigasi ke ImunisasiFormScreen dan tunggu hasilnya.
      // Setelah kembali, panggil _updateAnggotaList untuk refresh data.
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => KematianFormScreen(anggota: anggota)),
      ).then((_) => _updateAnggotaList());
      return; // Hentikan eksekusi fungsi setelah navigasi
    }

    // Untuk pilihan lain, tetap tampilkan SnackBar sebagai placeholder
    if (mounted) {
      String pesan = '';
      switch (jenisTerpilih) {
        case JenisPemeriksaan.kunjungan:
          pesan = 'Membuka form Kunjungan untuk ${anggota.nama}...';
          // TODO: Navigasi ke halaman form Kunjungan
          break;
        case JenisPemeriksaan.kematian:
          pesan = 'Membuka form Kematian untuk ${anggota.nama}...';
          // TODO: Navigasi ke halaman form Kematian
          break;
        case JenisPemeriksaan.imunisasi:
          // Sudah ditangani di atas, tidak akan pernah sampai sini.
          break;
      }
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(pesan), backgroundColor: Colors.blue),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.kohort.nama),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const LoginBackground(),
          FutureBuilder<List<Anggota>>(
            future: _anggotaList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada anggota. Tekan + untuk menambah.',
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
                  final anggota = snapshot.data![index];
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    child: ListTile(
                      leading: CircleAvatar(child: Text(anggota.nama[0])),
                      title: Text(anggota.nama),
                      subtitle: Text(
                        'Riwayat: ${anggota.riwayatPenyakit.isNotEmpty ? anggota.riwayatPenyakit : '-'}',
                      ),
                      // --- PERUBAHAN UTAMA DI SINI ---
                      // Menggunakan Row untuk menampung dua tombol ikon
                      trailing: Row(
                        mainAxisSize:
                            MainAxisSize
                                .min, // Agar Row tidak memakan semua tempat
                        children: [
                          // Tombol untuk Pemeriksaan
                          IconButton(
                            icon: const Icon(
                              Icons.checklist_rtl,
                              color: Colors.blue,
                            ),
                            tooltip: 'Lakukan Pemeriksaan',
                            onPressed: () => _lakukanPemeriksaan(anggota),
                          ),
                          // Tombol untuk Melihat Detail
                          IconButton(
                            icon: const Icon(Icons.visibility_outlined),
                            tooltip: 'Lihat Detail Anggota',
                            onPressed:
                                () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder:
                                        (_) => AnggotaDetailScreen(
                                          anggota: anggota,
                                        ),
                                  ),
                                ).then((_) => _updateAnggotaList()),
                          ),
                          // Tombol untuk Menghapus
                          IconButton(
                            icon: const Icon(
                              Icons.delete_outline,
                              color: Colors.red,
                            ),
                            onPressed: () => _hapusAnggota(anggota),
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
                builder: (_) => AnggotaFormScreen(kohortId: widget.kohort.id!),
              ),
            ).then((_) => _updateAnggotaList()),
        tooltip: 'Tambah Anggota',
        child: const Icon(Icons.add),
      ),
    );
  }
}
