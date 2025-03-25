import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/pet.dart'; // Kendi proje adınızı kullanın!
import 'package:flutter_application_1/screens/pet_details_screen.dart'; // Kendi proje adınızı kullanın!

class PetCard extends StatelessWidget {
  final Pet pet;
  final VoidCallback? onDelete; // Silme butonu için callback (isteğe bağlı)

  const PetCard({Key? key, required this.pet, this.onDelete}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: InkWell(
        onTap: () {
          // Evcil hayvan detayları sayfasına git (eğer varsa)
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => PetDetailsScreen(petId: pet.id),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Evcil hayvan fotoğrafı (varsa)
              CircleAvatar(
                backgroundColor: Colors.grey[300], // Arkaplan rengi
                radius: 30,
                child: ClipOval(
                  child: pet.photoUrl?.isNotEmpty == true
                      ? Image.network(
                          pet.photoUrl!,
                          fit: BoxFit.cover,
                          width: 60,
                          height: 60,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.pets, size: 30, color: Colors.grey),
                        )
                      : const Icon(Icons.pets, size: 30, color: Colors.grey),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      pet.name.isNotEmpty ? pet.name : "İsimsiz Evcil Hayvan",
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${pet.species.isNotEmpty ? pet.species : "Tür Belirtilmemiş"} - '
                      '${pet.breed.isNotEmpty ? pet.breed : "Cins Belirtilmemiş"}',
                    ),
                  ],
                ),
              ),
              // Silme butonu (isteğe bağlı)
              if (onDelete != null)
                IconButton(
                  icon: const Icon(Icons.delete),
                  onPressed: onDelete,
                  color: Colors.red[700],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
