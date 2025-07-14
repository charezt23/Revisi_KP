import 'package:flutter/material.dart';
import 'package:flutter_application_1/data/models/balitaModel.dart';
import 'package:intl/intl.dart';

class BalitaCard extends StatelessWidget {
  final BalitaModel balita;
  final int age;
  final bool isDeceased;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const BalitaCard({
    super.key,
    required this.balita,
    required this.age,
    required this.isDeceased,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      color:
          isDeceased
              ? Colors.red.withOpacity(0.1)
              : age >= 6
              ? Colors.orange.withOpacity(0.1)
              : Colors.white.withOpacity(0.9),
      child: ListTile(
        leading: Icon(
          isDeceased
              ? Icons.person_off_outlined
              : age >= 6
              ? Icons.history
              : Icons.child_care,
          color:
              isDeceased
                  ? Colors.red.shade700
                  : age >= 6
                  ? Colors.orange.shade700
                  : Theme.of(context).primaryColor,
        ),
        title: Text(
          balita.nama,
          style: TextStyle(
            decoration: isDeceased ? TextDecoration.lineThrough : null,
            color: isDeceased ? Colors.red.shade700 : null,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('NIK: ${balita.nik}'),
            Text(
              isDeceased
                  ? 'Meninggal: ${DateFormat('dd MMMM yyyy').format(balita.tanggalKematian!)}'
                  : 'Ibu: ${balita.namaIbu} | Usia: $age tahun',
            ),
          ],
        ),
        onTap: onTap,
        trailing:
            isDeceased
                ? null
                : IconButton(
                  icon: const Icon(Icons.delete_outline, color: Colors.red),
                  onPressed: onDelete,
                  tooltip: 'Hapus Balita',
                ),
      ),
    );
  }
}
