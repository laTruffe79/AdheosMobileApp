
import 'package:flutter/material.dart';

class MyAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final IconData icon;
  final Color color;
  final String routeName;

  const MyAppBar({
    Key? key,
    required this.title,
    required this.icon,
    required this.color,
    required this.routeName,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      forceMaterialTransparency: true,
      leading: IconButton(
        icon: Icon(icon, color: Colors.white),
        onPressed: () {
          Navigator.popUntil(context, ModalRoute.withName(routeName));
        },
      ),
      backgroundColor: color,
      title: Text(title),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}