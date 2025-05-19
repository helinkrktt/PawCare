// lib/screens/add_medication_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import 'package:flutter_application_1/models/medication.dart';
import 'package:flutter_application_1/providers/pet_provider.dart';
import 'package:flutter_application_1/models/pet.dart';

class AddMedicationScreen extends StatefulWidget {
  final Pet selectedPet;

  const AddMedicationScreen({super.key, required this.selectedPet});

  @override
  State<AddMedicationScreen> createState() => _AddMedicationScreenState();
}

class _AddMedicationScreenState extends State<AddMedicationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _medicationNameController = TextEditingController();
  final _dosageController = TextEditingController();
  // Kullanım Sıklığı için ayrı controller'lar veya tek bir string
  final _frequencyCountController = TextEditingController(text: '1'); // Sayı
  String? _selectedFrequencyUnit; // Birim Seçin, Günde, Haftada
  String? _selectedFrequencyPeriod; // kez, saatte bir
  final _notesController = TextEditingController();

  DateTime? _startDate;
  DateTime? _endDate;
  bool _isSaving = false;

  final List<String> _frequencyUnits = ['Birim Seçin...', 'Günde', 'Haftada', 'Ayda', 'Saatte Bir'];
  final List<String> _frequencyPeriods = ['kez'];


  @override
  void initState() {
    super.initState();
    _startDate = DateTime.now(); // Başlangıçta bugünün tarihini ata
    _selectedFrequencyUnit = _frequencyUnits.first;
    _selectedFrequencyPeriod = _frequencyPeriods.first;
  }

  @override
  void dispose() {
    _medicationNameController.dispose();
    _dosageController.dispose();
    _frequencyCountController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context, bool isStartDate) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: (isStartDate ? _startDate : _endDate) ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2050),
      locale: const Locale('tr', 'TR'), // Tarih seçiciyi Türkçe yap
    );
    if (picked != null) {
      setState(() {
        if (isStartDate) {
          _startDate = picked;
        } else {
          _endDate = picked;
        }
      });
    }
  }

  String _buildFrequencyString() {
    if (_selectedFrequencyUnit == 'Birim Seçin...' || _frequencyCountController.text.isEmpty) {
      return ''; // Veya varsayılan bir değer
    }
    if (_selectedFrequencyUnit == 'Saatte Bir') {
      return '${_frequencyCountController.text} saatte bir';
    }
    return '${_selectedFrequencyUnit!} ${_frequencyCountController.text} ${_selectedFrequencyPeriod!}';
  }


  Future<void> _saveMedication() async {
    if (_formKey.currentState!.validate() && !_isSaving) {
      if (_startDate == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Lütfen ilacın başlangıç tarihini seçin.'), backgroundColor: Colors.redAccent),
        );
        return;
      }
      setState(() { _isSaving = true; });

      String frequencyString = _buildFrequencyString();
      if (_dosageController.text.trim().isEmpty) { // Dozaj zorunluysa
           ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Lütfen dozaj bilgisini girin.'), backgroundColor: Colors.redAccent),
          );
          setState(() { _isSaving = false; });
          return;
      }


      final newMedication = Medication(
        id: 'med_${DateTime.now().millisecondsSinceEpoch}_${widget.selectedPet.id}',
        petId: widget.selectedPet.id,
        medicationName: _medicationNameController.text.trim(),
        dosage: _dosageController.text.trim(),
        frequency: frequencyString.isNotEmpty ? frequencyString : "Belirtilmemiş", // Frekans boşsa
        startDate: _startDate!,
        endDate: _endDate,
        notes: _notesController.text.trim().isNotEmpty ? _notesController.text.trim() : null,
      );

      final petProvider = Provider.of<PetProvider>(context, listen: false);
      try {
        await petProvider.addMedication(newMedication); // Sahte listeye ekleyecek
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${newMedication.medicationName} ilacı başarıyla eklendi!')),
          );
          Navigator.pop(context, true);
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('İlaç eklenirken hata: ${e.toString()}'), backgroundColor: Colors.redAccent),
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
        title: Text('${widget.selectedPet.name} İçin Yeni İlaç'),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              // İlaç Adı
              TextFormField(
                controller: _medicationNameController,
                decoration: InputDecoration(
                  labelText: 'İlaç Adı *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  prefixIcon: const Icon(Icons.medication_liquid_outlined),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Lütfen ilaç adını girin.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Dozaj
              TextFormField(
                controller: _dosageController,
                decoration: InputDecoration(
                  labelText: 'Dozaj (örn: 1 tablet, 5ml) *',
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)),
                  prefixIcon: const Icon(Icons.science_outlined),
                ),
                 validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Lütfen dozaj bilgisini girin.';
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Kullanım Sıklığı
              const Text('Kullanım Sıklığı (Opsiyonel)', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
              const SizedBox(height: 8),
              Row(
                children: [
                  Expanded(
                    flex: 2,
                    child: DropdownButtonFormField<String>(
                      decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), hintText: 'Birim'),
                      value: _selectedFrequencyUnit,
                      items: _frequencyUnits.map((String value) {
                        return DropdownMenuItem<String>(value: value, child: Text(value));
                      }).toList(),
                      onChanged: (String? newValue) => setState(() => _selectedFrequencyUnit = newValue),
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (_selectedFrequencyUnit != 'Birim Seçin...' && _selectedFrequencyUnit != null)
                    Expanded(
                      flex: 1,
                      child: TextFormField(
                        controller: _frequencyCountController,
                        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0)), hintText: 'Sayı'),
                        keyboardType: TextInputType.number,
                        validator: (value) {
                          if (_selectedFrequencyUnit != 'Birim Seçin...' && (value == null || value.isEmpty)) {
                            return 'Sayı girin';
                          }
                          if (value != null && int.tryParse(value) == null) {
                            return 'Geçerli sayı';
                          }
                          return null;
                        },
                      ),
                    ),
                  const SizedBox(width: 8),
                  if (_selectedFrequencyUnit != 'Birim Seçin...' && _selectedFrequencyUnit != 'Saatte Bir' && _selectedFrequencyUnit != null)
                    Expanded(
                      flex: 1,
                      child: DropdownButtonFormField<String>(
                        decoration: InputDecoration(border: OutlineInputBorder(borderRadius: BorderRadius.circular(8.0))),
                        value: _selectedFrequencyPeriod,
                        items: _frequencyPeriods.map((String value) {
                          return DropdownMenuItem<String>(value: value, child: Text(value));
                        }).toList(),
                        onChanged: (String? newValue) => setState(() => _selectedFrequencyPeriod = newValue),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 4),
              const Text('Örn: Günde 1 kez / Haftada 2 kez / 24 saatte bir', style: TextStyle(fontSize: 12, color: Colors.grey)),
              const SizedBox(height: 16),


              // Başlangıç Tarihi
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                leading: const Padding(padding: EdgeInsets.only(left: 12.0), child: Icon(Icons.calendar_today_outlined)),
                title: Text(
                  _startDate == null
                      ? 'Başlangıç Tarihi *'
                      : 'Başlangıç: ${DateFormat('dd.MM.yyyy', 'tr_TR').format(_startDate!)}',
                ),
                trailing: const Padding(padding: EdgeInsets.only(right: 8.0), child: Icon(Icons.edit_calendar_outlined)),
                onTap: () => _selectDate(context, true),
              ),
              const SizedBox(height: 16),

              // Bitiş Tarihi (Varsa)
              ListTile(
                contentPadding: EdgeInsets.zero,
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Theme.of(context).dividerColor),
                  borderRadius: BorderRadius.circular(8.0),
                ),
                leading: const Padding(padding: EdgeInsets.only(left: 12.0), child: Icon(Icons.calendar_month_outlined)),
                title: Text(
                  _endDate == null
                      ? 'Bitiş Tarihi (Varsa)'
                      : 'Bitiş: ${DateFormat('dd.MM.yyyy', 'tr_TR').format(_endDate!)}',
                ),
                trailing: Padding(
                   padding: const EdgeInsets.only(right: 8.0),
                   child: _endDate == null
                       ? const Icon(Icons.edit_calendar_outlined)
                       : IconButton(
                           icon: const Icon(Icons.clear, color: Colors.grey),
                           onPressed: () => setState(() => _endDate = null),
                           tooltip: "Tarihi Temizle",
                         ),
                 ),
                onTap: () => _selectDate(context, false),
              ),
              const SizedBox(height: 16),

              // Notlar
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

              // Kaydet ve İptal Butonları
              ElevatedButton.icon(
                icon: const Icon(Icons.save_alt_outlined),
                label: _isSaving ? const Text('Kaydediliyor...') : const Text('İlacı Kaydet'),
                onPressed: _isSaving ? null : _saveMedication,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.teal, foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
              const SizedBox(height: 10),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                style: OutlinedButton.styleFrom(
                  foregroundColor: Colors.grey.shade700, side: BorderSide(color: Colors.grey.shade300),
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