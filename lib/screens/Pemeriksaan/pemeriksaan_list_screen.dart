import 'package:flutter/material.dart';
import 'package:flutter_application_1/databse/dummy_data_service.dart';
import 'package:flutter_application_1/models/anggota_model.dart';
import 'package:flutter_application_1/models/pemeriksaan_model.dart';
import 'package:flutter_application_1/screens/catatan_kesehatan_form_screen.dart';
import 'package:flutter_application_1/widgets/login_background.dart';
import 'package:intl/intl.dart';

class PemeriksaanListScreen extends StatefulWidget {
  final Anggota anggota;
  const PemeriksaanListScreen({super.key, required this.anggota});

  @override
  State<PemeriksaanListScreen> createState() => _PemeriksaanListScreenState();
}

class _PemeriksaanListScreenState extends State<PemeriksaanListScreen> {
  late Future<List<Pemeriksaan>> _pemeriksaanList;

  @override
  void initState() {
    super.initState();
    _updatePemeriksaanList();
  }

  void _updatePemeriksaanList() {
    setState(() {
      _pemeriksaanList = DummyDataService().getPemeriksaanList(
        widget.anggota.id!,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Riwayat Pemeriksaan'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          const LoginBackground(),
          FutureBuilder<List<Pemeriksaan>>(
            future: _pemeriksaanList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Text(
                    'Belum ada riwayat pemeriksaan.\nTekan + untuk menambah.',
                    textAlign: TextAlign.center,
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
                  final pemeriksaan = snapshot.data![index];
                  return Card(
                    color: Colors.white.withOpacity(0.9),
                    child: ListTile(
                      leading: Icon(
                        Icons.monitor_heart_outlined,
                        color: Theme.of(context).primaryColor,
                      ),
                      title: Text(
                        DateFormat(
                          'dd MMMM yyyy',
                        ).format(pemeriksaan.tanggalPemeriksaan),
                      ),
                      subtitle: Text(
                        'BB: ${pemeriksaan.beratBadan} kg, TB: ${pemeriksaan.tinggiBadan} cm',
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
                    (_) => PemeriksaanFormScreen(anggotaId: widget.anggota.id!),
              ),
            ).then((_) => _updatePemeriksaanList()),
        tooltip: 'Tambah Pemeriksaan',
        child: const Icon(Icons.add_chart),
      ),
    );
  }
}
