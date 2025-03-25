import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/pet.dart';
import 'package:flutter_application_1/services/pet_service.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class AddPetScreen extends StatefulWidget {
  const AddPetScreen({Key? key}) : super(key: key);

  @override
  AddPetScreenState createState() => AddPetScreenState();
}

class AddPetScreenState extends State<AddPetScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _speciesController = TextEditingController();
  final _breedController = TextEditingController();
  DateTime? _selectedDate;
  String? _selectedGender;
  File? _image;
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _speciesController.dispose();
    _breedController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _savePet() async {
    if (_formKey.currentState!.validate()) {
      String newId = DateTime.now().millisecondsSinceEpoch.toString();

      Pet newPet = Pet(
        id: newId,
        name: _nameController.text,
        species: _speciesController.text,
        breed: _breedController.text,
        birthDate: _selectedDate,
        gender: _selectedGender,
        photoUrl: _image?.path, //Resmin yolunu kaydet.
      );

      try {
        await PetService.addPet(newPet); // GERÇEK KAYDETME
        //print("Evcil hayvan başarıyla eklendi (simülasyon): ${newPet.toJson()}"); // Debug için

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Evcil hayvan başarıyla eklendi!')),
          );
          Navigator.pop(context); // Geri dön
        }
      } catch (e) {
        print("Hata oluştu: $e");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Evcil hayvan eklenirken bir hata oluştu: $e')),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Yeni Evcil Hayvan Ekle'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16.0),
          children: [
            GestureDetector(
              onTap: () {
                showModalBottomSheet(
                  context: context,
                  builder: (builder) {
                    return Wrap(
                      children: [
                        ListTile(
                          leading: const Icon(Icons.photo_library),
                          title: const Text("Galeriden Seç"),
                          onTap: () {
                            _pickImage(ImageSource.gallery);
                            Navigator.pop(context);
                          },
                        ),
                        ListTile(
                          leading: const Icon(Icons.camera_alt),
                          title: const Text("Kameradan Çek"),
                          onTap: () {
                            _pickImage(ImageSource.camera);
                            Navigator.pop(context);
                          },
                        ),
                      ],
                    );
                  },
                );
              },
              child: Container(
                height: 200,
                width: 200,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: _image == null
                    ? const Icon(Icons.add_a_photo, size: 50, color: Colors.grey)
                    : Image.file(_image!, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 20),
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Adı'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen evcil hayvanınızın adını girin.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _speciesController,
              decoration: const InputDecoration(labelText: 'Türü'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen evcil hayvanınızın türünü girin.';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _breedController,
              decoration: const InputDecoration(labelText: 'Cinsi'),
            ),
            GestureDetector(
              onTap: () => _selectDate(context),
              child: AbsorbPointer(
                child: TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Doğum Tarihi',
                    suffixIcon: Icon(Icons.calendar_today),
                  ),
                  controller: TextEditingController(
                    text: _selectedDate == null
                        ? ''
                        : "${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}",
                  ),
                  validator: (value) {
                    if (_selectedDate == null) {
                      return 'Lütfen doğum tarihini seçin.';
                    }
                    return null;
                  },
                ),
              ),
            ),
            DropdownButtonFormField<String>(
              value: _selectedGender,
              decoration: const InputDecoration(labelText: 'Cinsiyet'),
              items: ['Erkek', 'Dişi', 'Belirsiz']
                  .map((label) => DropdownMenuItem(value: label, child: Text(label)))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGender = value;
                });
              },
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Lütfen cinsiyet seçin.';
                }
                return null;
              },
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _savePet,
              child: const Text('Kaydet'),
            ),
          ],
        ),
      ),
    );
  }
}