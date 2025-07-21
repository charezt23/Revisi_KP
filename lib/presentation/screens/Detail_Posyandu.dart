import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/posyanduModel.dart';
import 'package:flutter_application_1/presentation/screens/Daftar_Balita.dart';
import 'package:flutter_application_1/presentation/screens/ImunisasiBalitaScreen.dart';
import 'package:flutter_application_1/presentation/screens/components/info_container.dart';
import 'package:flutter_application_1/presentation/screens/components/login_background.dart';

class DetailPosyandu extends StatefulWidget {
  final PosyanduModel posyandu;
  const DetailPosyandu({super.key, required this.posyandu});

  @override
  State<DetailPosyandu> createState() => _DetailPosyanduState();
}

class _DetailPosyanduState extends State<DetailPosyandu> {
  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(color: Colors.white),
        const LoginBackground(),
        Scaffold(
          backgroundColor: Colors.transparent,
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detail Posyandu',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                const Text('Informasi Umum'),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    InfoCOntainer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.child_care, size: 40, color: Colors.blue),
                          SizedBox(height: 8),
                          Text('Detail Balita'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => KohortDetailScreen(
                                  posyandu: widget.posyandu,
                                ),
                          ),
                        );
                      },
                    ),
                    InfoCOntainer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(Icons.vaccines, size: 40, color: Colors.green),
                          SizedBox(height: 8),
                          Text('Jadwal Imunisasi'),
                        ],
                      ),
                      onTap: () {
                        // Navigasi ke halaman jadwal imunisasi
                      },
                    ),
                    InfoCOntainer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.contact_phone,
                            size: 40,
                            color: Colors.orange,
                          ),
                          SizedBox(height: 8),
                          Text('Kontak Posyandu'),
                        ],
                      ),
                      onTap: () {
                        // Navigasi ke halaman kontak posyandu
                      },
                    ),
                    InfoCOntainer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.medical_services,
                            size: 40,
                            color: Colors.red,
                          ),
                          SizedBox(height: 8),
                          Text('Imunisasi'),
                        ],
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) => ImunisasiBalitaScreen(
                                  posyandu: widget.posyandu,
                                ),
                          ),
                        );
                      },
                    ),
                    InfoCOntainer(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: const [
                          Icon(
                            Icons.event_note,
                            size: 40,
                            color: Colors.purple,
                          ),
                          SizedBox(height: 8),
                          Text('Kunjungan'),
                        ],
                      ),
                      onTap: () {
                        // Navigasi ke halaman kunjungan
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
