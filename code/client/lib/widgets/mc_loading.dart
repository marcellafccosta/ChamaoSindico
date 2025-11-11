import 'package:flutter/material.dart';

class McLoading extends StatelessWidget {
  const McLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.deepOrangeAccent),
    );
  }
}