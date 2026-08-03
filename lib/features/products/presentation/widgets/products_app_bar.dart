import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class ProductsAppBar extends StatelessWidget implements PreferredSizeWidget {
  final VoidCallback? onBulkUpload;

  const ProductsAppBar({super.key, this.onBulkUpload});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: false,
      centerTitle: false,
      title: Text(
        'Products',
        style: TextStyle(
          color: context.colors.textPrimary,
          fontSize: 24,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),
      ),
      actions: [
        PopupMenuButton<void>(
          icon: Icon(Icons.more_vert, color: context.colors.textPrimary),
          itemBuilder: (context) => [
            PopupMenuItem<void>(
              onTap: onBulkUpload,
              child: const Row(
                children: [
                  Icon(Icons.upload_file_outlined, size: 20),
                  SizedBox(width: 12),
                  Text('Bulk upload'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }
}
