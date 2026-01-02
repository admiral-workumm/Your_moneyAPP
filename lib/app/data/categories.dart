import 'package:flutter/material.dart';

class CategoryItem {
  final String label;
  final IconData icon;
  const CategoryItem(this.label, this.icon);
}

const List<CategoryItem> kDefaultCategories = [
  CategoryItem('Makan', Icons.restaurant),
  CategoryItem('Hiburan', Icons.sports_esports),
  CategoryItem('Transportasi', Icons.directions_bus),
  CategoryItem('Belanja', Icons.shopping_bag),
  CategoryItem('Komunikasi', Icons.smartphone),
  CategoryItem('Kesehatan', Icons.medical_services),
  CategoryItem('Pendidikan', Icons.school),
  CategoryItem('Home', Icons.home),
  CategoryItem('Keluarga', Icons.groups),
  CategoryItem('Lainnya', Icons.category),
];
