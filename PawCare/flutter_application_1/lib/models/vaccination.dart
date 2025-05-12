// lib/models/vaccination.dart
import 'package:hive/hive.dart';

// *** BU SATIR OLMAZSA OLMAZ! DOSYA ADININ DOĞRU OLDUĞUNDAN EMİN OLUN. ***
part 'vaccination.g.dart';

@HiveType(typeId: 1) // TYPE ID BENZERSİZ OLMALI (örn: Pet için 0 ise bu 1 olabilir)
class Vaccination extends HiveObject { // HiveObject'i extend etmek önerilir
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String petId;

  @HiveField(2)
  final String vaccineName;

  @HiveField(3)
  final DateTime date;

  @HiveField(4)
  final DateTime? nextDueDate;

  @HiveField(5)
  final String? notes;

  Vaccination({
    required this.id,
    required this.petId,
    required this.vaccineName,
    required this.date,
    this.nextDueDate,
    this.notes,
  });
}