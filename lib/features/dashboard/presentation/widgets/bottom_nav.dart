import 'package:flutter/material.dart';

class HomeBottomNav extends StatelessWidget {
  const HomeBottomNav({super.key});

  @override
  Widget build(BuildContext context) {
    return const BottomAppBar(
      child: SizedBox(
        height: 60,
        child: Center(child: Text('Bottom Navigation')),
      ),
    );
  }
}
