import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/pemeriksaan_model.dart';

class GrafikWidget extends StatelessWidget {
  final List<Pemeriksaan> riwayat;
  const GrafikWidget({super.key, required this.riwayat});

  @override
  Widget build(BuildContext context) {
    if (riwayat.length < 2) {
      return const Center(
        child: Text(
          'Data tidak cukup untuk menampilkan grafik (minimal 2 data).',
        ),
      );
    }

    final reversedRiwayat = riwayat.reversed.toList();

    // Mengubah data riwayat menjadi titik-titik pada grafik
    final spots = reversedRiwayat.asMap().entries.map((e) {
      // Sumbu X adalah indeks data (0, 1, 2, ...), Sumbu Y adalah berat badan
      return FlSpot(e.key.toDouble(), e.value.beratBadan);
    }).toList();

    // Menentukan nilai min dan max untuk sumbu Y agar ada sedikit padding
    final minY =
        riwayat.map((p) => p.beratBadan).reduce((a, b) => a < b ? a : b) - 1;
    final maxY =
        riwayat.map((p) => p.beratBadan).reduce((a, b) => a > b ? a : b) + 1;

    return SizedBox(
      height: 300, // Memberi tinggi yang cukup untuk grafik
      child: LineChart(
        LineChartData(
          minY: minY < 0 ? 0 : minY, // Pastikan tidak negatif
          maxY: maxY,
          // 1. Kustomisasi Tooltip saat disentuh
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  final flSpot = barSpot;
                  final index = flSpot.spotIndex;
                  final pemeriksaan = reversedRiwayat[index];

                  return LineTooltipItem(
                    '${DateFormat('dd MMM yyyy').format(pemeriksaan.tanggalPemeriksaan)}\n',
                    const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                    children: [
                      TextSpan(
                        text: '${flSpot.y.toStringAsFixed(1)} kg',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  );
                }).toList();
              },
            ),
          ),
          // 2. Kustomisasi Garis Grid
          gridData: FlGridData(
            show: true,
            drawVerticalLine: true,
            horizontalInterval: 1,
            verticalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return const FlLine(
                color: Colors.black12,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
            getDrawingVerticalLine: (value) {
              return const FlLine(
                color: Colors.black12,
                strokeWidth: 1,
                dashArray: [5, 5],
              );
            },
          ),
          // 3. Kustomisasi Judul Sumbu (Axis Titles)
          titlesData: FlTitlesData(
            show: true,
            rightTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            topTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: false),
            ),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 30,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  final index = value.toInt();
                  if (index >= 0 && index < reversedRiwayat.length) {
                    final tgl = reversedRiwayat[index].tanggalPemeriksaan;
                    return SideTitleWidget(
                      axisSide: meta.axisSide,
                      space: 8.0,
                      child: Text(
                        DateFormat('dd/MM').format(tgl),
                        style: const TextStyle(fontSize: 10),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: const AxisTitles(
              sideTitles: SideTitles(showTitles: true, reservedSize: 40),
            ),
          ),
          // 4. Kustomisasi Border
          borderData: FlBorderData(
            show: true,
            border: Border.all(color: const Color(0xff37434d), width: 1),
          ),
          // 5. Kustomisasi Data Garis dengan Gradien
          lineBarsData: [
            LineChartBarData(
              spots: spots,
              isCurved: true,
              gradient: LinearGradient(
                colors: [Colors.cyan, Colors.blue.shade700],
              ),
              barWidth: 4,
              dotData: const FlDotData(show: true),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: [
                    Colors.cyan.withOpacity(0.3),
                    Colors.blue.shade700.withOpacity(0.0),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
