// lib/screens/add_vaccination_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart'; // Tarih formatlama için

import 'package:flutter_application_1/models/vaccination.dart';
import 'package:flutter_application_1/providers/pet_provider.dart';
import 'package:flutter_application_1/models/pet.dart'; // Pet tipi için

class AddVaccinationScreen extends StatefulWidget {
  final Pet selectedPet; // Hangi evcil hayvan için aşı ekleneceğini alır

  const AddVaccinationScreen({super.key, required this.selectedPet});

  @override
  State<AddVaccinationScreen> createState() => _AddVaccinationScreenState();
}

class _AddVaccinationScreenState extends State<AddVaccinationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _vaccineNameController = TextEditingController();
  final _notesController = TextEditingController();
  DateTime? _vaccinationDate;
  DateTime? _nextDueDate;
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _vaccinationDate = DateTime.now(); // Başlangıçta bugünün tarihini ata
  }

  @override
  void dispose() {
    _vaccineNameController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isVaccinationDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isVaccinationDate ? _vaccinationDate : _nextDueDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050), // Gelecekteki tarihler için
    );
    if (picked != null) {
      setState(() {
        if (isVaccinationDate) {
          _vaccinationDate = picked;
        } else {
          _nextDueDate = picked;
        }
      });
    }
  }

  Future<void> _saveVaccination() async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      if (_vaccinationDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen aşının yapıldığı tarihi seçin.'), backgroundColor: Colors.redAccent),
        );
        return;
      }

      setState(() { _isSaving = true; });

      final newVaccination = Vaccination(
        // API'niz ID'yi otomatik oluşturuyorsa, burada geçici bir ID verebilir
        // veya API yanıtından gerçek ID'yi alabilirsiniz.
        // Şimdilik Flutter tarafında benzersiz bir ID oluşturalım.
        id: 'vacc_${DateTime.now().millisecondsSinceEpoch}_${widget.selectedPet.id}',
        petId: widget.selectedPet.id,
        vaccineName: _vaccineNameController.text.trim(),
        date: _vaccinationDate!,
        nextDueDate: _nextDueDate,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      final petProvider = Provider.of<PetProvider>(context, listen: false);
      try {
        // PetProvider'daki addVaccination metodu artık API'ye istek atmıyor (UI Test Modu)
        // Sadece yerel listeye ekleyecek veya debugPrint yapacak.
        await petProvider.addVaccination(newVaccination);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${newVaccination.vaccineName} aşısı başarıyla eklendi!')),
          );
          Navigator.pop(context, true); // Başarılı ekleme sonrası geri dön ve listeyi yenile (true parametresi ile)
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Aşı eklenirken hata: ${e.toString()}'), backgroundColor: Colors.redAccent),
          );
        }
      } finally {
        if (mounted) {
          setState(() { _isSaving = false; });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.selectedPet.name} İçin Yeni Aşı'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // Aşı Adı
              TextFormField(
                controller: _vaccineNameController,
                decoration: InputDecoration(
                  labelText: 'Aşı Adı *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  prefixIcon: const Icon(Icons.vaccines_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Lütfen aşı adını girin.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Yapıldığı Tarih
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                leading: const Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Icon(Icons.calendar_today_outlined),
                ),
                title: Text(
                  _vaccinationDate == null
                      ? 'Yapıldığı Tarih *'
                      : 'Yapıldığı Tarih: ${DateFormat('dd.MM.yyyy', 'tr_TR').format(_vaccinationDate!)}',
                ),
                trailing: const Padding(
                  padding: EdgeInsets.only(right: 8.0),
                  child: Icon(Icons.edit_calendar_outlined),
                ),
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 16),

              // Bir Sonraki Aşı Tarihi (Varsa)
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                leading: const Padding(
                  padding: EdgeInsets.only(left: 12.0),
                  child: Icon(Icons.calendar_month_outlined),
                ),
                title: Text(
                  _nextDueDate == null
                      ? 'Bir Sonraki Aşı Tarihi (Varsa)'
                      : 'Sonraki Tarih: ${DateFormat('dd.MM.yyyy', 'tr_TR').format(_nextDueDate!)}',
                ),
                 trailing: Padding(
                   padding: const EdgeInsets.only(right: 8.0),
                   child: _nextDueDate == null
                       ? const Icon(Icons.edit_calendar_outlined)
                       : IconButton(
                           icon: const Icon(Icons.clear, color: Colors.grey),
                           onPressed: () => setState(() => _nextDueDate = null),
                           tooltip: "Tarihi Temizle",
                         ),
                 ),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 16),

              // Notlar (Varsa)
              TextFormField(
                controller: _notesController,
                decoration: InputDecoration(
                  labelText: 'Notlar (Varsa)',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  prefixIcon: const Icon(Icons.notes_outlined),
                ),
                maxLines: 3,
                textInputAction: TextInputAction.done,
              ),
              const SizedBox(height: 30),

              // Kaydet Butonu
              ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_outlined),
                label: _isSaving ? const Text('Kaydediliyor...') : const Text('Aşıyı Kaydet'),
                onPressed: _isSaving ? null : _saveVaccination,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              // İptal Butonu
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700,
                  side: BorderSide(color: Colors.grey.shade300),
                   padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                child: const Text('İptal'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}