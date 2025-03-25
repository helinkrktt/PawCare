// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_application_1/screens/add_pet_screen.dart';
import 'package:flutter_application_1/models/pet.dart';
import 'package:flutter_application_1/services/pet_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<Pet>> _petsFuture; //Evcil hayvanları tut

  @override
  void initState() {
    super.initState();
    _petsFuture = PetService.getPets(); //Evcil hayvanları yükle
  }

  //Evcil hayvanları tekrar yükle
  void _reloadPets() {
    setState(() {
      _petsFuture = PetService.getPets();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('PawCare - Ana Sayfa'),
      ),
      body: FutureBuilder<List<Pet>>(
        future: _petsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Hata: ${snapshot.error}'));
          } else if (snapshot.hasData) {
            final pets = snapshot.data!;
            if (pets.isEmpty) {
              return const Center(child: Text('Henüz evcil hayvan eklenmedi.'));
            }
            return ListView.builder(
              itemCount: pets.length,
              itemBuilder: (context, index) {
                final pet = pets[index];
                return ListTile(
                  title: Text(pet.name),
                  subtitle: Text('${pet.species} - ${pet.breed}'),
                  // Diğer bilgileri de gösterebilirsin
                );
              },
            );
          } else {
            return const Center(child: Text('Veri yok.'));
          }
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // AddPetScreen'e git ve geri döndüğünde evcil hayvan listesini yenile
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddPetScreen()),
          );
          _reloadPets(); //Evcil hayvanları yeniden yükle.

        },
        child: const Icon(Icons.add),
      ),
    );
  }
}