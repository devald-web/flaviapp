class MigraineEntry {
  final int? id;
  final DateTime date;
  final bool hadMigraine;
  final String? medication;
  final String? trigger;
  final String intensity;
  final String? notes;

  MigraineEntry({
    this.id,
    required this.date,
    required this.hadMigraine,
    this.medication,
    this.trigger,
    required this.intensity,
    this.notes,
  });

  MigraineEntry copyWith({
    int? id,
    DateTime? date,
    bool? hadMigraine,
    String? medication,
    String? trigger,
    String? intensity,
    String? notes,
  }) {
    return MigraineEntry(
      id: id ?? this.id,
      date: date ?? this.date,
      hadMigraine: hadMigraine ?? this.hadMigraine,
      medication: medication ?? this.medication,
      trigger: trigger ?? this.trigger,
      intensity: intensity ?? this.intensity,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date.toIso8601String(),
      'hadMigraine': hadMigraine ? 1 : 0,
      'medication': medication,
      'trigger': trigger,
      'intensity': intensity,
      'notes': notes,
    };
  }

  static MigraineEntry fromMap(Map<String, dynamic> map) {
    return MigraineEntry(
      id: map['id'],
      date: DateTime.parse(map['date']),
      hadMigraine: map['hadMigraine'] == 1,
      medication: map['medication'],
      trigger: map['trigger'],
      intensity: map['intensity'],
      notes: map['notes'],
    );
  }
}