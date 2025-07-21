import 'package:flutter/material.dart';

class InfoCOntainer extends StatelessWidget {
  final Widget child;
  final Icon? icon;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? color;
  final double borderRadius;
  final double? width; // Tambahkan ini
  final double? height;
  final VoidCallback? onTap; // Tambahkan ini

  const InfoCOntainer({
    super.key,
    required this.child,
    this.icon,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
    this.color,
    this.borderRadius = 12.0,
    this.width = 200,
    this.height = 100,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: width,
        height: height,
        padding: padding,
        margin: margin,
        decoration: BoxDecoration(
          color: color ?? Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
          boxShadow: [
            BoxShadow(
              color: Colors.black12,
              blurRadius: 4,
              offset: Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (icon != null) icon!,
            if (icon != null) const SizedBox(height: 8),
            child,
          ],
        ),
      ),
    );
  }
}
