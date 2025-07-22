import 'package:flutter/material.dart';
import 'package:flutter_application_1/presentation/screens/Pemeriksaan/ImunisasiBalitaScreen.dart';
import 'package:flutter_application_1/presentation/screens/Pemeriksaan/KunjunganBalitaScreen.dart';
import 'package:flutter_application_1/presentation/screens/Daftar_Balita.dart';
import 'package:flutter_application_1/presentation/screens/Home_Screen.dart';
import 'package:flutter_application_1/presentation/screens/all_balita_screen.dart';
import 'package:flutter_application_1/data/models/posyanduModel.dart';
import 'package:flutter_application_1/data/API/PosyanduService.dart';
import 'package:flutter_application_1/data/API/authservice.dart';

class MenuPage extends StatefulWidget {
  const MenuPage({Key? key}) : super(key: key);

  @override
  State<MenuPage> createState() => _MenuPageState();
}

class _MenuPageState extends State<MenuPage> with TickerProviderStateMixin {
  final Posyanduservice _posyanduService = Posyanduservice();
  List<PosyanduModel> _posyanduList = [];
  bool _isLoading = true;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _loadData();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);

    try {
      final posyanduList = await _posyanduService.GetPosyanduByUser();
      if (mounted) {
        setState(() {
          _posyanduList = posyanduList;
          _isLoading = false;
        });
        _animationController.forward();
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Gagal memuat data: $e'),
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
        backgroundColor: Colors.transparent,
        elevation: 0,
        automaticallyImplyLeading: false, // Menghilangkan tombol back
        toolbarHeight: 0, // Menyembunyikan AppBar secara visual
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _loadData,
        backgroundColor: const Color(0xFF03A9F4),
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6), Color(0xFF03A9F4)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              _buildHeader(),
              Expanded(
                child: _isLoading ? _buildLoadingState() : _buildMenuGrid(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  Icons.local_hospital,
                  color: Colors.white,
                  size: MediaQuery.of(context).size.width * 0.045,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Pencatatan Kesehatan',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: MediaQuery.of(context).size.width * 0.045,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    FutureBuilder(
                      future: AuthService.getCurrentUser(),
                      builder: (context, snapshot) {
                        return Text(
                          snapshot.hasData
                              ? 'Selamat datang, ${snapshot.data!.name}'
                              : 'Selamat datang',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: MediaQuery.of(context).size.width * 0.03,
                          ),
                          overflow: TextOverflow.ellipsis,
                        );
                      },
                    ),
                  ],
                ),
              ),
              if (_posyanduList.isNotEmpty)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${_posyanduList.length} Posyandu',
                    style: TextStyle(
                      color: Color(0xFF03A9F4),
                      fontSize: MediaQuery.of(context).size.width * 0.025,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
      ),
    );
  }

  Widget _buildMenuGrid() {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Container(
        margin: const EdgeInsets.only(top: 20),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(30),
            topRight: Radius.circular(30),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Menu Utama',
                style: TextStyle(
                  fontSize: MediaQuery.of(context).size.width * 0.06,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2C3E50),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: GridView.count(
                  crossAxisCount: 4,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 0.9,
                  children: [
                    _buildMenuCard(
                      icon: Icons.list_alt,
                      title: 'Daftar Posyandu',
                      subtitle: 'Lihat Semua',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF00D2D3), Color(0xFF54A0FF)],
                      ),
                      onTap: () => _showPosyanduList(),
                    ),
                    _buildMenuCard(
                      icon: Icons.child_care,
                      title: 'Data Balita',
                      subtitle: 'Info Balita',
                      gradient: const LinearGradient(
                        colors: [Color(0xFFFF9FF3), Color(0xFFF368E0)],
                      ),
                      onTap: () => _showBalitaOptions(),
                    ),
                    _buildMenuCard(
                      icon: Icons.sentiment_very_dissatisfied,
                      title: 'Data Kematian',
                      subtitle: 'Catat Kematian',
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5A3C), Color(0xFF6F4C3E)],
                      ),
                      onTap:
                          _posyanduList.isEmpty
                              ? null
                              : () => _showPosyanduSelection('kematian'),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required LinearGradient gradient,
    VoidCallback? onTap,
  }) {
    final isDisabled = onTap == null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Material(
        elevation: isDisabled ? 2 : 8,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              gradient:
                  isDisabled
                      ? const LinearGradient(
                        colors: [Color(0xFFE0E0E0), Color(0xFFBDBDBD)],
                      )
                      : gradient,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Padding(
              padding: const EdgeInsets.all(6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(2),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.9),
                      borderRadius: BorderRadius.circular(5),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 3,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                    child: Icon(
                      icon,
                      size: MediaQuery.of(context).size.width * 0.035,
                      color: Colors.grey[700],
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    title,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: MediaQuery.of(context).size.width * 0.025,
                      fontWeight: FontWeight.w600,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    isDisabled ? 'Tambah Posyandu' : subtitle,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: MediaQuery.of(context).size.width * 0.018,
                    ),
                    textAlign: TextAlign.center,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showBalitaOptions() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFF9FF3).withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.child_care,
                        color: Color(0xFFF368E0),
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Text(
                      'Pilihan Data Balita',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFF03A9F4),
                      child: Icon(Icons.all_inclusive, color: Colors.white),
                    ),
                    title: const Text(
                      'Semua Balita di Posyandu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Lihat semua data balita dari seluruh posyandu',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => const AllBalitaScreen(),
                        ),
                      );
                    },
                  ),
                ),
                Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  child: ListTile(
                    leading: const CircleAvatar(
                      backgroundColor: Color(0xFFF368E0),
                      child: Icon(Icons.location_on, color: Colors.white),
                    ),
                    title: const Text(
                      'Balita per Posyandu',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    subtitle: const Text(
                      'Pilih posyandu untuk melihat data balita',
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      Navigator.pop(context);
                      _showPosyanduSelection('balita');
                    },
                  ),
                ),
              ],
            ),
          ),
    );
  }

  void _showPosyanduList() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const HomeScreen()),
    );
  }

  void _showPosyanduSelection(String type) {
    if (_posyanduList.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Tidak ada posyandu tersedia. Tambahkan posyandu terlebih dahulu.',
          ),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF03A9F4).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.local_hospital,
                        color: Color(0xFF03A9F4),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Pilih Posyandu - ${_getTypeTitle(type)}',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                ...(_posyanduList.map(
                  (posyandu) => Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF03A9F4),
                        child: Icon(Icons.local_hospital, color: Colors.white),
                      ),
                      title: Text(
                        posyandu.namaPosyandu,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      subtitle: Text(posyandu.namaDesa),
                      trailing: const Icon(Icons.arrow_forward_ios),
                      onTap: () {
                        Navigator.pop(context);
                        _navigateToType(type, posyandu);
                      },
                    ),
                  ),
                )),
              ],
            ),
          ),
    );
  }

  String _getTypeTitle(String type) {
    switch (type) {
      case 'balita':
        return 'Data Balita';
      case 'kunjungan':
        return 'Kunjungan';
      case 'imunisasi':
        return 'Imunisasi';
      case 'kematian':
        return 'Data Kematian';
      default:
        return 'Menu';
    }
  }

  void _navigateToType(String type, PosyanduModel posyandu) {
    switch (type) {
      case 'balita':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KohortDetailScreen(posyandu: posyandu),
          ),
        );
        break;
      case 'kunjungan':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KunjunganBalitaScreen(posyandu: posyandu),
          ),
        );
        break;
      case 'imunisasi':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ImunisasiBalitaScreen(posyandu: posyandu),
          ),
        );
        break;
      case 'kematian':
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => KohortDetailScreen(posyandu: posyandu),
          ),
        );
        break;
    }
  }
}
