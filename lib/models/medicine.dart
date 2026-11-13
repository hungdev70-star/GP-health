class Medicine {
  Medicine({
    required this.id,
    required this.name,
    required this.time,
    required this.note,
    this.taken = false,
  });

  final String id;
  final String name;
  final String time;
  final String note;
  bool taken;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'time': time,
    'note': note,
    'taken': taken,
  };

  factory Medicine.fromJson(Map<String, dynamic> json) => Medicine(
    id: json['id'] as String,
    name: json['name'] as String,
    time: json['time'] as String,
    note: (json['note'] as String?) ?? '',
    taken: (json['taken'] as bool?) ?? false,
  );
}
