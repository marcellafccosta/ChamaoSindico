import 'package:flutter/material.dart';

class McListView extends StatelessWidget {
  const McListView({
    super.key,
    required this.itemCount,
    required this.itemBuilder,
  });

  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;

  @override
  Widget build(BuildContext context) {
    return Material(
      child: ListView.builder(
        itemBuilder: itemBuilder,
        itemCount: itemCount,
      )
    );
  }
}
