import 'package:flutter/material.dart';

class McButtonIcon extends StatelessWidget {
  const McButtonIcon({
    super.key,
    required this.iconData,
    required this.onTap,
  });

  final IconData iconData;
  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: () => onTap(),
      child: SizedBox(
        width: 40,
        height: 40,
        child: Icon(iconData),
      ),
    );
  }
}
