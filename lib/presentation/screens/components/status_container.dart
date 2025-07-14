import 'package:flutter/material.dart';

class StatusContainer extends StatelessWidget {
  final bool showHistoryMode;
  const StatusContainer({super.key, required this.showHistoryMode});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: showHistoryMode
            ? Colors.orange.withOpacity(0.15)
            : Colors.blue.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        showHistoryMode ? 'Riwayat' : 'Aktif',
        style: TextStyle(
          color: showHistoryMode ? Colors.orange : Colors.blue,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
