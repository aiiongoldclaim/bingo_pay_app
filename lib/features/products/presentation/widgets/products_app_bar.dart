import 'package:flutter/material.dart';

class ProductsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback onSearchTap;
  final VoidCallback onFilterTap;
  final bool isGridView;
  final VoidCallback onViewToggle;

  const ProductsAppBar({
    super.key,
    required this.onSearchTap,
    required this.onFilterTap,
    required this.isGridView,
    required this.onViewToggle,
  });

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
        'Products',
        style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
      ),
      actions: [
        IconButton(icon: const Icon(Icons.search, color: Colors.white), onPressed: onSearchTap),
        IconButton(icon: const Icon(Icons.tune, color: Colors.white), onPressed: onFilterTap),
        IconButton(
          icon: Icon(isGridView ? Icons.view_list_outlined : Icons.grid_view_outlined, color: Colors.white),
          tooltip: isGridView ? 'List view' : 'Grid view',
          onPressed: onViewToggle,
        ),
        const SizedBox(width: 4),
      ],
    );
  }
}
