class MigraineEntry {
  int? id;
  DateTime date;
  bool hadMigraine;
  String? medication;
  String? trigger;
  String? intensity;
  String? notes;

  MigraineEntry({
    this.id,
    required this.date,
    required this.hadMigraine,
    this.medication,
    this.trigger,
    this.intensity,
    this.notes,
  });

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