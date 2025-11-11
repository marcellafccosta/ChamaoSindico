import 'package:flutter/material.dart';

class Mclogo extends StatelessWidget {
  const Mclogo({
    super.key,
    this.size = 300,
    this.center = true,
  });

  final double size;
  final bool center;

  @override
  Widget build(BuildContext context) {
    final image = Padding(
      padding: EdgeInsets.only(bottom: size / 8),
      child: Image.asset(
        'assets/images/logo-cos.png',
        height: size,
        fit: BoxFit.contain,
      ),
    );

    return center ? Center(child: image) : image;
  }
}
