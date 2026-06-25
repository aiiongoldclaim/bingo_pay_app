import 'package:flutter/material.dart';

class CategoryModel {
  final String title;
  final String items;
  final IconData icon;
  final Color color;

  CategoryModel({
    required this.title,
    required this.items,
    required this.icon,
    required this.color,
  });
}

class CuratedCollectionModel {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color iconBg;

  CuratedCollectionModel({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.iconBg,
  });
}
