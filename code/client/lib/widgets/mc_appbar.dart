import 'package:client/widgets/mc_button_icon.dart';
import 'package:flutter/material.dart';

class McAppBar extends StatelessWidget implements PreferredSizeWidget {
  const McAppBar({
    super.key,
    required this.title,
    this.withLeading = true,
    this.actions = const[],
  });

  final Widget title;
  final bool withLeading;
  final List<Widget> actions;

  @override
  Size get preferredSize => Size.fromHeight(56);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SizedBox(
        
        height: preferredSize.height,
        child: AppBar(
          automaticallyImplyLeading: false,
          title: title,
          leadingWidth: 40,
          leading: withLeading ? McButtonIcon(
            iconData : Icons.chevron_left,
            onTap: () => Navigator.of(context).pop()
          ) : null,
          actions: actions,
        ),
      )
    );
  }
}
