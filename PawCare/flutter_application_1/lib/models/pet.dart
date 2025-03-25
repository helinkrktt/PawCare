// lib/models/pet.dart
class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final DateTime? birthDate;
  final String? gender;
  final String? photoUrl; // Resmin URL'si (şimdilik null)

  Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    this.birthDate,
    this.gender,
    this.photoUrl,
  });

  // JSON'a dönüştürme (kaydetme için)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'species': species,
      'breed': breed,
      'birthDate': birthDate?.toIso8601String(), // Tarihi string'e çevir
      'gender': gender,
      'photoUrl': photoUrl,
    };
  }

  // JSON'dan nesneye dönüştürme (veritabanından okuma için)
  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'],
      name: json['name'],
      species: json['species'],
      breed: json['breed'],
      birthDate: json['birthDate'] != null ? DateTime.parse(json['birthDate']) : null,
      gender: json['gender'],
      photoUrl: json['photoUrl'],
    );
  }
}