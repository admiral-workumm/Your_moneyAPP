import 'package:flutter/material.dart';

class Segment {
  final String name;
  final int percent; // 0-100
  final Color color;
  final int nominal;
  const Segment({
    required this.name,
    required this.percent,
    required this.color,
    this.nominal = 0,
  });
  double get fraction => percent / 100.0;
}
