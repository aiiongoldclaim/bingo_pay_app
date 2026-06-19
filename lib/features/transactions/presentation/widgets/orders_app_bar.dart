import 'package:flutter/material.dart';

class OrdersAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;

  const OrdersAppBar({super.key, required this.onSearchTap, required this.onFilterTap});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color(0xFF1B2A6B),
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: const Text(
        'Orders',
        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: onSearchTap),
        IconButton(icon: const Icon(Icons.tune, color: Colors.white), onPressed: onFilterTap),
        const SizedBox(width: 4),
      ],
    );
  }
}
