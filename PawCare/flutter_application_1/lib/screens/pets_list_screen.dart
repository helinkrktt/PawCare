// lib/screens/pets_list_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider import
import 'package:flutter_application_1/providers/pet_provider.dart'; // PetProvider import
import 'package:flutter_application_1/screens/add_pet_screen.dart'; // AddPetScreen import
import 'package:flutter_application_1/models/pet.dart'; // Pet modeli (ListTile içinde kullanmak için)

class PetsListScreen extends StatelessWidget {
  // Lint düzeltmesi: use_super_parameters
  const PetsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Provider'ı dinle (watch ile build metodunu tetikler)
    final petProvider = context.watch<PetProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Evcil Hayvanlarım'),
        backgroundColor: Colors.teal,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Yeni Evcil Hayvan Ekle',
            onPressed: () {
              // AddPetScreen'e git
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPetScreen()),
              );
            },
          ),
        ],
      ),
      // Provider'daki değişiklikleri yansıtmak için RefreshIndicator eklemek iyi olur
      body: RefreshIndicator(
        onRefresh: () => petProvider.fetchPets(), // Aşağı çekince listeyi yenile
        color: Colors.teal,
        child: _buildPetListBody(petProvider, context), // İçeriği ayrı metoda taşıdık
      ),
    );
  }

  // Liste içeriğini oluşturan ve durumları yöneten metot
  Widget _buildPetListBody(PetProvider petProvider, BuildContext context) {
    // 1. Yükleniyor Durumu
    if (petProvider.isLoadingPets) {
      // Eğer liste zaten doluysa ve arkada yenileme yapılıyorsa sadece listeyi göster,
      // sadece ilk yüklemede veya liste boşken gösterge göster.
      if (petProvider.pets.isEmpty) {
         return const Center(child: CircularProgressIndicator(color: Colors.teal));
      }
      // else: Liste varken yenileniyorsa alttaki listeyi göstermeye devam et.
      // RefreshIndicator zaten üstte bir gösterge sağlıyor.
    }

    // 2. Hata Durumu
    if (petProvider.petsErrorMessage != null) {
       // Hata varsa ve liste boşsa hata mesajını göster
       if (petProvider.pets.isEmpty) {
          return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text('Hata: ${petProvider.petsErrorMessage}', style: const TextStyle(color: Colors.red)),
              )
          );
       }
       // else: Hata oluştu ama eski veri varsa onu göstermeye devam edebilir
       // veya SnackBar ile hata bildirilebilir. Şimdilik listeyi göstermeye devam edelim.
       // WidgetsBinding.instance.addPostFrameCallback((_) {
       //    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Hata: ${petProvider.petsErrorMessage}')));
       // });
    }

    // 3. Liste Boş Durumu
    if (petProvider.pets.isEmpty) {
      // Yükleme bitti, hata yok ama liste boş
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.pets, size: 60, color: Colors.grey.shade400),
              const SizedBox(height: 15),
              const Text('Hiç evcil hayvanınız yok.', style: TextStyle(fontSize: 16, color: Colors.black54)),
              const SizedBox(height: 15),
              ElevatedButton.icon(
                 icon: const Icon(Icons.add, size: 20),
                 label: const Text('İlk Evcil Hayvanınızı Ekleyin'),
                 style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12)
                ),
                 onPressed: (){
                     Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPetScreen()));
                 },
              )
            ],
          ),
        ),
      );
    }

    // 4. Liste Dolu Durumu: Tüm evcil hayvanları listele
    return ListView.builder(
      // Her zaman kaydırılabilir yap (RefreshIndicator için önemli)
      physics: const AlwaysScrollableScrollPhysics(),
      itemCount: petProvider.pets.length,
      itemBuilder: (context, index) {
        final pet = petProvider.pets[index];
        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: const Icon(Icons.pets, color: Colors.teal),
              // TODO: Evcil hayvan resmi varsa göster
              // backgroundImage: pet.photoUrl != null && pet.photoUrl!.isNotEmpty
              //   ? NetworkImage(pet.photoUrl!) // veya FileImage(File(pet.photoUrl!))
              //   : null,
              // child: (pet.photoUrl == null || pet.photoUrl!.isEmpty)
              //   ? const Icon(Icons.pets, color: Colors.teal)
              //   : null,
            ),
            title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            subtitle: Text('${pet.species} - ${pet.breed}', style: const TextStyle(color: Colors.black54)),
            trailing: IconButton(
              icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
              tooltip: 'Sil',
              onPressed: () async {
                // Silme onayı dialog'u göster
                bool? confirmDelete = await showDialog<bool>(
                    context: context,
                    builder: (ctx) => AlertDialog(
                          title: const Text('Emin misiniz?'),
                          content: Text('${pet.name} adlı evcil hayvanı ve ilgili tüm verilerini (aşı, ilaç vb.) silmek istediğinize emin misiniz? Bu işlem geri alınamaz.'),
                          actions: [
                            TextButton(
                                onPressed: () => Navigator.of(ctx).pop(false), // İptal
                                child: const Text('İptal')),
                            TextButton(
                                onPressed: () => Navigator.of(ctx).pop(true), // Sil
                                style: TextButton.styleFrom(foregroundColor: Colors.red),
                                child: const Text('Sil')),
                          ],
                        ));

                // Eğer kullanıcı onayladıysa silme işlemini yap
                if (confirmDelete == true) {
                  // Provider üzerinden silme metodunu çağır ('read' kullanmak daha doğru)
                  context.read<PetProvider>().deletePet(pet.id);
                   // Başarı mesajı gösterilebilir (isteğe bağlı)
                   // ScaffoldMessenger.of(context).showSnackBar(
                   //   SnackBar(content: Text('${pet.name} silindi.'), duration: Duration(seconds: 2))
                   // );
                }
              },
            ),
            onTap: (){
               // TODO: Detay veya Düzenleme ekranına git
               // Navigator.push(context, MaterialPageRoute(builder: (context) => EditPetScreen(pet: pet)));
               print("Listeden seçildi: ${pet.name}");
             },
          ),
        );
      },
    );
  }
}