import 'package:flutter/material.dart';
import 'package:flutter_application_1/models/pet.dart'; // Kendi proje adınızı kullanın!
import 'package:flutter_application_1/services/pet_service.dart'; // Kendi proje adınızı kullanın!

class PetProvider extends ChangeNotifier {
  List<Pet> _pets = [];
  bool _isLoading = false; // Veri yüklenirken gösterilecek durum
  String? _errorMessage;

  List<Pet> get pets => _pets;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Evcil hayvanları getirme
  Future<void> fetchPets() async {
    if (_isLoading) return; // Eğer zaten yükleniyorsa tekrar çağırma
    _isLoading = true;
    _errorMessage = null; // Hata mesajını temizle
    notifyListeners(); // UI'ı güncelle

    try {
      _pets = await PetService.getPets();
    } catch (e) {
      _errorMessage = 'Evcil hayvanlar yüklenirken bir hata oluştu: $e';
      debugPrint(_errorMessage); // Daha iyi bir hata yönetimi
    } finally {
      _isLoading = false; // Yükleme bitti
      notifyListeners();
    }
  }

  // Evcil hayvan ekleme
  Future<void> addPet(Pet newPet) async {
    _errorMessage = null;
    try {
      await PetService.addPet(newPet);
      await fetchPets(); // Listeyi güncelle.
    } catch (e) {
      _errorMessage = 'Evcil hayvan eklenirken bir hata oluştu: $e';
      debugPrint(_errorMessage);
    }
    notifyListeners(); // notifyListeners() çağrısı her durumda olmalı
  }

  // Evcil hayvan silme
  Future<void> deletePet(String petId) async {
    _errorMessage = null;
    try {
      await PetService.deletePet(petId);
      await fetchPets(); // Listeyi güncelle
    } catch (e) {
      _errorMessage = "Evcil hayvan silinirken bir hata oluştu: $e";
      debugPrint(_errorMessage);
    }
    notifyListeners();
  }

  // Evcil hayvan güncelleme
  Future<void> updatePet(Pet updatedPet) async {
    _errorMessage = null;
    try {
      await PetService.updatePet(updatedPet);
      await fetchPets();
    } catch (e) {
      _errorMessage = "Evcil hayvan güncellenirken bir hata oluştu: $e";
      debugPrint(_errorMessage);
    }
    notifyListeners();
  }
}
