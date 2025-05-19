import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lottie/lottie.dart';

import 'package:flutter_application_1/providers/auth_provider.dart'; // AppDrawer için gerekli
import 'package:flutter_application_1/providers/pet_provider.dart';
import 'package:flutter_application_1/screens/add_pet_screen.dart';
import 'package:flutter_application_1/screens/pets_list_screen.dart';
import 'package:flutter_application_1/screens/vaccination_screen.dart'; // AppDrawer için gerekli
import 'package:flutter_application_1/screens/medication_screen.dart'; // AppDrawer için gerekli
import 'package:flutter_application_1/screens/find_vet_screen.dart';   // AppDrawer için gerekli
import 'package:flutter_application_1/models/pet.dart'; // _buildPetList'teki Pet tipi için gerekli
import 'package:flutter_application_1/screens/login_screen.dart';     // AppDrawer ve yönlendirme için gerekli
import 'package:flutter_application_1/screens/signup_screen.dart';   // AppDrawer için gerekli (login/signup butonları)
import 'package:flutter_application_1/screens/pet_details_screen.dart'; // _buildPetList onTap için gerekli
import 'package:flutter_application_1/screens/chatbot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    // UI Test Modunda, AuthProvider zaten 'authenticated' başlayacağı için
    // PetProvider constructor'ında sahte veri yüklüyorsa, burada ek bir şey yapmaya gerek yok.
    // Eğer PetProvider'ın fetchPets simülasyonunu test etmek istiyorsanız:
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _loadInitialDataIfNeeded();
    // });
    debugPrint("HomeScreen initState: UI Test Modu.");
  }

  // void _loadInitialDataIfNeeded() { // Bu metot UI test modunda aktif olmayabilir
  //   final authProvider = Provider.of<AuthProvider>(context, listen: false);
  //   if (authProvider.isLoggedIn) {
  //     final petProvider = Provider.of<PetProvider>(context, listen: false);
  //     if (petProvider.pets.isEmpty && !petProvider.isLoadingPets) {
  //       debugPrint("HomeScreen: _loadInitialData - fetchPets (simülasyon) çağrılıyor.");
  //       petProvider.fetchPets();
  //     }
  //   }
  // }

  Future<void> _refreshData() async {
    // UI Test Modunda API isteği atmıyoruz.
    debugPrint("HomeScreen: _refreshData - Yenileme simülasyonu.");
    await Future.delayed(const Duration(milliseconds: 500));
    if (mounted) { // mounted kontrolü eklendi
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Sayfa yenilendi (simülasyon)."))
      );
    }
  }

  void _openChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatbotScreen()),
    );
    debugPrint("HomeScreen: Chatbot ekranı açılıyor...");
  }

  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
    // AuthProvider'ı build metodu içinde doğrudan kullanmıyoruz, AppDrawer kullanıyor.
    // const bool isLoggedIn = true; // Bu satır AppDrawer'da yönetiliyor.

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      drawer: const AppDrawer(), // AppDrawer isLoggedIn'i AuthProvider'dan alacak
      appBar: AppBar(
        title: const Text('PawCare'),
        backgroundColor: Colors.teal,
        elevation: 0,
        // actions: const [], // AppDrawer'daki isLoggedIn'e göre ayarlanacak
      ),
      body: RefreshIndicator(
        onRefresh: _refreshData,
        color: Colors.teal,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Hoş Geldin! 👋 (UI Test Modu)',
                  style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Evcil dostların seni bekliyor.',
                  style: TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),
                Center(
                  child: Lottie.asset(
                    'assets/lottie/dog_animation.json', // KENDİ LOTTIE DOSYA YOLUNUZ
                    width: 250,
                    height: 250,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      debugPrint("Ana Ekran Lottie Hatası: $error");
                      return Container(
                        width: 250, height: 250, color: Colors.grey[200],
                        child: const Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, color: Colors.red, size: 40),
                              SizedBox(height: 8),
                              Text("Animasyon yüklenemedi", textAlign: TextAlign.center, style: TextStyle(color: Colors.red)),
                              Text("Dosya yolunu kontrol edin", textAlign: TextAlign.center, style: TextStyle(fontSize: 12)),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),
                _buildLoggedInContent(context, petProvider), // Bu metot her zaman çağrılacak (isLoggedIn drawer'da)
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ),
      floatingActionButton: Stack( // Birden fazla FAB için Stack
        children: <Widget>[
          Positioned(
            left: 32.0,
            bottom: 16.0,
            child: FloatingActionButton(
              heroTag: 'chatbotFab',
              onPressed: _openChatbot,
              backgroundColor: Colors.orangeAccent,
              tooltip: 'Pati ile Sohbet Et',
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Lottie.asset(
                  'assets/lottie/chat_icon.json', // KENDİ CHATBOT LOTTIE DOSYA YOLUNUZ
                  width: 40, height: 40,
                  errorBuilder: (ctx, err, st) => const Icon(Icons.chat_bubble_outline, color: Colors.white),
                ),
              ),
            ),
          ),
          Positioned(
            right: 16.0,
            bottom: 16.0,
            child: FloatingActionButton(
              heroTag: 'addPetFab',
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const AddPetScreen()));
              },
              backgroundColor: Colors.teal,
              tooltip: 'Yeni Evcil Hayvan Ekle',
              child: const Icon(Icons.add, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoggedInContent(BuildContext context, PetProvider petProvider) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text(
              'Evcil Hayvanların 🐾',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
            ),
            TextButton(
              onPressed: () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => const PetsListScreen()));
              },
              style: TextButton.styleFrom(foregroundColor: Colors.teal.shade700),
              child: const Text('Tümünü Gör'),
            )
          ],
        ),
        const SizedBox(height: 12),
        _buildPetList(petProvider),
      ],
    );
  }

  // _buildLoggedOutContent metodu artık doğrudan build içinde kullanılmıyor,
  // isLoggedIn AppDrawer'da yönetiliyor ve MyApp ana ekranı belirliyor.
  // Eğer yine de burada tutmak isterseniz:
  // Widget _buildLoggedOutContent(BuildContext context) { ... }

  Widget _buildPetList(PetProvider petProvider) {
    if (petProvider.pets.isEmpty) { // isLoadingPets ve petsErrorMessage kontrolleri eklenebilir
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
         decoration: BoxDecoration(
            color: Colors.teal.withAlpha((255 * 0.05).round()),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.teal.withAlpha((255 * 0.2).round()))
         ),
        child: const Center(child: Text(
              'Henüz evcil hayvan eklenmedi.\n(UI Test Modu)',
               textAlign: TextAlign.center,
               style: TextStyle(color: Colors.teal, fontSize: 15, height: 1.5),
               )),
      );
    }

    final petsToShow = petProvider.pets.take(3).toList();
    // HATA DÜZELTİLDİ: ListView.builder'a itemCount ve itemBuilder eklendi
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: petsToShow.length, // BU SATIR GEREKLİ
      itemBuilder: (context, index) { // BU SATIR GEREKLİ
        final Pet pet = petsToShow[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          elevation: 1.5,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            leading: CircleAvatar(
              backgroundColor: Colors.teal.shade100,
              child: const Icon(Icons.pets, color: Colors.teal),
            ),
            title: Text(pet.name, style: const TextStyle(fontWeight: FontWeight.w500, fontSize: 16)),
            subtitle: Text('${pet.species} - ${pet.breed}', style: const TextStyle(color: Colors.black54)),
            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400),
            onTap: (){
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PetDetailsScreen(petId: pet.id),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

// AppDrawer Kodu
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // Gerçek giriş durumunu AuthProvider'dan al
    final authProvider = context.watch<AuthProvider>();
    final bool isLoggedIn = authProvider.isLoggedIn; // UI Test modunda bu true olacak

    return Drawer(
      child: Column(
        children: [
          // HATA DÜZELTİLDİ: DrawerHeader'a child eklendi ve const yapıldı
          const DrawerHeader(
            decoration: BoxDecoration(color: Colors.teal),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                   children: [
                     Icon(Icons.pets, color: Colors.white, size: 35),
                     SizedBox(width: 12),
                     Text('PawCare', style: TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                   ],
                 ),
                 SizedBox(height: 8),
                 Text('Evcil dostlarınız için her şey', style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.8))),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Ana Sayfa'),
                  tileColor: ModalRoute.of(context)?.settings.name == '/' || context.widget is HomeScreen
                      ? Colors.teal.withAlpha((255 * 0.1).round()) : null,
                  onTap: () {
                     if (ModalRoute.of(context)?.settings.name == '/' || context.widget is HomeScreen) {
                       Navigator.pop(context);
                    } else {
                       Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const HomeScreen()), (route) => false);
                    }
                  },
                ),
                if (isLoggedIn) ...[
                   ListTile(leading: const Icon(Icons.pets_outlined), title: const Text('Evcil Hayvanlarım'), onTap: () {Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context)=> const PetsListScreen()));}),
                   ListTile(leading: const Icon(Icons.medical_services_outlined), title: const Text('Aşı Takvimi'), onTap: () {Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context)=> const VaccinationScreen()));}),
                   ListTile(leading: const Icon(Icons.medication_outlined), title: const Text('İlaçlar'), onTap: () {Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context)=> const MedicationScreen()));}),
                   ListTile(leading: const Icon(Icons.location_on_outlined), title: const Text('Veteriner Bul'), onTap: () {Navigator.pop(context); Navigator.push(context, MaterialPageRoute(builder: (context)=> const FindVetScreen()));}),
                ],
                const Divider(indent: 16, endIndent: 16),
                ListTile(
                  leading: const Icon(Icons.settings_outlined),
                  title: const Text('Ayarlar'),
                  onTap: () {
                      Navigator.pop(context);
                     ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Ayarlar ekranı henüz hazır değil."))
                     );
                  },
                ),
              ],
            ),
          ),
          const Divider(indent: 16, endIndent: 16, height: 1),
          if (!isLoggedIn)
             _buildLoginSignupButtons(context)
          else
             _buildLogoutButton(context),
          const SafeArea(bottom: true, child: SizedBox(height: 0)),
        ],
      ),
    );
  }

  // Bu metotlar Widget döndürüyor, 'body_might_complete_normally' hatası olmamalı
  Widget _buildLoginSignupButtons(BuildContext context){
     return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Expanded( // Giriş Yap butonu
              child: TextButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen())); }, child: const Text('Giriş Yap')),
            ),
            const SizedBox(width: 8),
            Expanded( // Kayıt Ol butonu
              child: ElevatedButton(onPressed: () { Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen())); }, child: const Text('Kayıt Ol')),
            ),
          ],
        )
      );
  }

   Widget _buildLogoutButton(BuildContext context){
      return Padding(
         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
         child: TextButton.icon(
           icon: const Icon(Icons.logout),
           label: const Text('Çıkış Yap'),
           onPressed: () {
             // AuthProvider'dan logout metodunu çağır
             context.read<AuthProvider>().logout();
             debugPrint("Çıkış Yap tıklandı ve AuthProvider.logout() çağrıldı.");
             // İsteğe bağlı: Kullanıcıyı giriş ekranına yönlendirebilirsiniz.
             // Navigator.of(context).pushAndRemoveUntil(
             //   MaterialPageRoute(builder: (context) => const LoginScreen()),
             //   (route) => false,
             // );
           },
         )
       );
   }
}