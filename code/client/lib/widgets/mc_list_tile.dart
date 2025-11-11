import 'package:flutter/material.dart';

class McListTile extends StatelessWidget {
  const McListTile({
    super.key,
    this.leading,
    required this.trailing,
    required this.title,
    this.description,
    this.onTap,
  });

  final Widget? leading;
  final Widget trailing;
  final Widget? description;
  final Widget title;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(vertical: 5, horizontal: 16),
        visualDensity: VisualDensity.compact,
        leading: leading == null
            ? null
            : Container(
                alignment: Alignment.center,
                width: 50,
                child: leading,
              ),
        title: title,
        subtitle: description,
        trailing: trailing,
        onTap: onTap,
      ),
    );
  }
}
