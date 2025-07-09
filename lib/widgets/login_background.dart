import 'package:flutter/material.dart';

class LoginBackground extends StatelessWidget {
  const LoginBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return Opacity(
      opacity:
          0.3, // Atur tingkat transparansi di sini (0.0 = hilang, 1.0 = solid)
      child: Container(
        decoration: const BoxDecoration(
          // Use BoxDecoration directly for the image
          image: DecorationImage(
            image: AssetImage(
              'assets/images/BackgrounLogin.png',
            ), // Updated Path
            fit: BoxFit.scaleDown,
            // Use BoxFit.cover to fill the entire container
          ),
        ),
      ),
    );
  }
}
