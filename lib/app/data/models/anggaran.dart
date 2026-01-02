import 'package:uuid/uuid.dart';

class Anggaran {
  final String id;
  final String name;
  final int limit; // nominal batas anggaran (rupiah)
  final String category;
  final String period; // 'Harian' | 'Mingguan' | 'Bulanan'
  final DateTime startDate;
  final DateTime endDate;

  Anggaran({
    required this.id,
    required this.name,
    required this.limit,
    required this.category,
    required this.period,
    required this.startDate,
    required this.endDate,
  });

  factory Anggaran.newBudget({
    required String name,
    required int limit,
    required String category,
    required String period,
    required DateTime startDate,
    required DateTime endDate,
  }) {
    return Anggaran(
      id: const Uuid().v4(),
      name: name,
      limit: limit,
      category: category,
      period: period,
      startDate: startDate,
      endDate: endDate,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'limit': limit,
      'category': category,
      'period': period,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
    };
  }

  factory Anggaran.fromMap(Map<String, dynamic> map) {
    return Anggaran(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      limit: (map['limit'] is int)
          ? (map['limit'] as int)
          : int.tryParse('${map['limit']}') ?? 0,
      category: map['category'] ?? '',
      period: map['period'] ?? 'Bulanan',
      startDate: DateTime.parse(map['startDate'] as String),
      endDate: DateTime.parse(map['endDate'] as String),
    );
  }
}
