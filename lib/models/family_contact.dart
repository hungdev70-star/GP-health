class FamilyContact {
  FamilyContact({
    required this.id,
    required this.name,
    required this.phone,
    this.isEmergency = false,
  });

  final String id;
  final String name;
  final String phone;
  bool isEmergency;

  Map<String, Object?> toJson() => {
    'id': id,
    'name': name,
    'phone': phone,
    'isEmergency': isEmergency,
  };

  factory FamilyContact.fromJson(Map<String, dynamic> json) => FamilyContact(
    id: json['id'] as String,
    name: json['name'] as String,
    phone: json['phone'] as String,
    isEmergency: (json['isEmergency'] as bool?) ?? false,
  );
}
