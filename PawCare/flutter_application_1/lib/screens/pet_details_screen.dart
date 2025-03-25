import 'package:flutter/material.dart';

class PetDetailsScreen extends StatelessWidget {
  final String petId;

  const PetDetailsScreen({Key? key, required this.petId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Evcil Hayvan Detayları')),
      body: Center(
        child: Text('Evcil Hayvan ID: $petId'),
      ),
    );
  }
}
