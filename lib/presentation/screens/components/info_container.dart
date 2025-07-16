import 'package:flutter/material.dart';

class InfoCOntainer extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final double borderRadius;
  final double? width; // Tambahkan ini
  final double? height; // Tambahkan ini

  const InfoCOntainer({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    this.color,
    this.borderRadius = 12.0,
    this.width = 200,
    this.height = 100,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width, // Tambahkan ini
      height: height, // Tambahkan ini
      padding: padding,
      margin: margin,
      decoration: BoxDecoration(
        color: color ?? Colors.white,
        borderRadius: BorderRadius.circular(borderRadius),
        boxShadow: [
          BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: child,
    );
  }
}
