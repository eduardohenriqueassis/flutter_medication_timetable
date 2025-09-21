class Medication {
  final int? id;
  final int userId;
  final String name;
  final double quantity;
  final String unit;
  final bool isContinuous;
  final String startDate;
  final String? endDate; // Pode ser nulo
  final String frequency;
  final String firstDoseTime;

  Medication({
    this.id,
    required this.userId,
    required this.name,
    required this.quantity,
    required this.unit,
    required this.isContinuous,
    required this.startDate,
    this.endDate,
    required this.frequency,
    required this.firstDoseTime,
  });

  // Converte um Map em um objeto Medication
  factory Medication.fromMap(Map<String, dynamic> map) {
    return Medication(
      id: map['id'],
      userId: map['userId'],
      name: map['name'],
      quantity: map['quantity'],
      unit: map['unit'],
      isContinuous: map['isContinuous'] == 1,
      startDate: map['startDate'],
      endDate: map['endDate'],
      frequency: map['frequency'],
      firstDoseTime: map['firstDoseTime'],
    );
  }

  // Converte um objeto Medication em um Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'quantity': quantity,
      'unit': unit,
      'isContinuous': isContinuous ? 1 : 0,
      'startDate': startDate,
      'endDate': endDate,
      'frequency': frequency,
      'firstDoseTime': firstDoseTime,
    };
  }
}
