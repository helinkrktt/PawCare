// lib/models/medication.dart
import 'package:hive/hive.dart';

// *** BU SATIR OLMAZSA OLMAZ! DOSYA ADININ DOĞRU OLDUĞUNDAN EMİN OLUN. ***
part 'medication.g.dart';

@HiveType(typeId: 2) // TYPE ID BENZERSİZ OLMALI (Pet ve Vaccination'dan farklı)
class Medication extends HiveObject { // HiveObject'i extend etmek önerilir
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String petId;

  @HiveField(2)
  final String medicationName;

  @HiveField(3)
  final String dosage;

  @HiveField(4)
  final String frequency;

  @HiveField(5)
  final DateTime startDate;

  @HiveField(6)
  final DateTime? endDate;

  @HiveField(7)
  final String? notes;

  Medication({
    required this.id,
    required this.petId,
    required this.medicationName,
    required this.dosage,
    required this.frequency,
    required this.startDate,
    this.endDate,
    this.notes,
  });
}