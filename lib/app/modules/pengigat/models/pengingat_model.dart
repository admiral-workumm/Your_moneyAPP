class PengingatModel {
  final int id;
  final int hours;
  final int minutes;
  final String periode; // Harian, Mingguan, Bulanan, Tahunan
  final bool isActive;

  PengingatModel({
    required this.id,
    required this.hours,
    required this.minutes,
    required this.periode,
    this.isActive = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'hours': hours,
      'minutes': minutes,
      'periode': periode,
      'isActive': isActive,
    };
  }

  factory PengingatModel.fromJson(Map<String, dynamic> json) {
    return PengingatModel(
      id: json['id'] ?? 0,
      hours: json['hours'] ?? 0,
      minutes: json['minutes'] ?? 0,
      periode: json['periode'] ?? 'Harian',
      isActive: json['isActive'] ?? true,
    );
  }

  String get timeString =>
      '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}';

  PengingatModel copyWith({
    int? id,
    int? hours,
    int? minutes,
    String? periode,
    bool? isActive,
  }) {
    return PengingatModel(
      id: id ?? this.id,
      hours: hours ?? this.hours,
      minutes: minutes ?? this.minutes,
      periode: periode ?? this.periode,
      isActive: isActive ?? this.isActive,
    );
  }
}
