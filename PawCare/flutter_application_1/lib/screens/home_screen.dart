import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Provider import
import 'package:flutter_application_1/providers/pet_provider.dart'; // PetProvider import
import 'package:flutter_application_1/screens/add_pet_screen.dart';
// Navigasyon için diğer ekranları import et
import 'package:flutter_application_1/screens/pets_list_screen.dart';
import 'package:flutter_application_1/screens/vaccination_screen.dart';
import 'package:flutter_application_1/screens/medication_screen.dart';
import 'package:flutter_application_1/screens/find_vet_screen.dart';
import 'package:flutter_application_1/models/pet.dart'; // _buildPetList içinde Pet tipi için gerekli olabilir, kalsın.

// *** GİRİŞ/KAYIT EKRANLARI İÇİN IMPORTLAR ***
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/signup_screen.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadInitialData();
    });
  }

  void _loadInitialData() {
      // TODO: [Auth] Gerçek kimlik doğrulama eklendiğinde,
      //       sadece giriş yapılmışsa fetchPets çağrılmalıdır.
      final petProvider = Provider.of<PetProvider>(context, listen: false);
      if (petProvider.pets.isEmpty && !petProvider.isLoadingPets) {
        petProvider.fetchPets();
      }
  }

  Future<void> _refreshData() async {
    // TODO: [Auth] Giriş durumu kontrolü eklenebilir.
    await Provider.of<PetProvider>(context, listen: false).fetchPets();
  }


  @override
  Widget build(BuildContext context) {
    final petProvider = context.watch<PetProvider>();
     // TODO: [Auth] Burayı gerçek Auth Provider'dan okuyun:
     // final bool isLoggedIn = context.watch<AuthProvider>().isLoggedIn;
     const bool isLoggedIn = false; // Geçici - 'dead_code' uyarıları normal

    return Scaffold(
      backgroundColor: const Color(0xFFFDFDFD),
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('PawCare'),
        backgroundColor: Colors.teal,
        elevation: 0,
         actions: [
           if (!isLoggedIn)
             TextButton(
               onPressed: () {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
               },
               child: const Text('Giriş Yap', style: TextStyle(color: Colors.white)),
             ),
         ],
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
                // --- Hoş Geldin Mesajı ---
                // TODO: [Auth] Giriş yapmış kullanıcının adını göster
                 // Hata düzeltildi: const eklendi
                Text(
                  isLoggedIn ? 'Tekrar Hoş Geldin! 👋' : 'Merhaba! 👋',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: Color(0xFF333333)),
                ),
                const SizedBox(height: 8),
                // Hata düzeltildi: const eklendi
                 Text(
                  isLoggedIn ? 'Evcil dostların seni bekliyor.' : 'Evcil dostlarının bakımı burada başlıyor.',
                  style: const TextStyle(fontSize: 16, color: Colors.black54),
                ),
                const SizedBox(height: 20),

                // --- Ana Görsel ---
                ClipRRect(
                  borderRadius: BorderRadius.circular(15),
                  child: Image.network(
                    'https://cdn.pixabay.com/photo/2017/09/25/13/12/dog-2785074_960_720.jpg',
                     height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 200,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(15),
                      ),
                      child: const Icon(Icons.error_outline, size: 50, color: Colors.grey),
                    ),
                     loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return Container(
                        height: 200,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.teal.shade200),
                            value: loadingProgress.expectedTotalBytes != null
                                ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                : null,
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 24),

                // --- İçerik Alanı (Giriş Durumuna Göre) ---
                if (isLoggedIn)
                  // Giriş yapılmışsa evcil hayvanları göster ('dead_code' uyarısı normal)
                  _buildLoggedInContent(context, petProvider)
                else
                  // Giriş yapılmamışsa giriş/kayıt butonlarını göster (canlı kod)
                  _buildLoggedOutContent(context),

                const SizedBox(height: 80), // FAB için boşluk
              ],
            ),
          ),
        ),
      ),
      // FloatingActionButton (Sadece giriş yapılmışsa görünür, 'dead_code' uyarısı normal)
      floatingActionButton: isLoggedIn
          ? FloatingActionButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddPetScreen()),
                );
              },
              backgroundColor: Colors.teal,
              tooltip: 'Yeni Evcil Hayvan Ekle',
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  // Giriş Yapılmış Kullanıcı İçeriğini Oluşturan Widget
  Widget _buildLoggedInContent(BuildContext context, PetProvider petProvider) {
    // Bu blok 'dead_code' uyarısı alacaktır (isLoggedIn = false)
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
            if (petProvider.pets.isNotEmpty)
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

  // Giriş Yapmamış Kullanıcı İçeriğini Oluşturan Widget
  Widget _buildLoggedOutContent(BuildContext context) {
    // Bu blok canlı koddur (isLoggedIn = false)
    return Center(
      child: Column(
        children: [
          const SizedBox(height: 20),
           Text( // const kaldırıldı (style const değil)
            "Tüm özelliklere erişmek için giriş yapın veya kayıt olun.",
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 16, color: Colors.grey.shade700),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text("Giriş Yap"),
          ),
          const SizedBox(height: 10),
          OutlinedButton(
            onPressed: (){
              Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.teal),
              foregroundColor: Colors.teal,
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
            ),
            child: const Text("Kayıt Ol"),
          ),
        ],
      ),
    );
  }


  // Evcil Hayvan Listesini (ilk 3) Oluşturan Yardımcı Widget
  Widget _buildPetList(PetProvider petProvider) {
    if (petProvider.isLoadingPets && petProvider.pets.isEmpty) {
      return const Center(child: Padding(
        padding: EdgeInsets.symmetric(vertical: 30.0),
        child: CircularProgressIndicator(color: Colors.teal),
      ));
    }
    if (petProvider.petsErrorMessage != null && petProvider.pets.isEmpty) {
      return Center(child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 30.0),
        child: Text('Hata: ${petProvider.petsErrorMessage}', style: const TextStyle(color: Colors.red)),
      ));
    }
    if (petProvider.pets.isEmpty) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30.0, horizontal: 15.0),
         decoration: BoxDecoration(
            color: Colors.teal.withAlpha((255 * 0.05).round()),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.teal.withAlpha((255 * 0.2).round()))
         ),
        child: const Center(child: Text(
              'Henüz evcil hayvan eklemediniz.\nSağ alttaki (+) butonuna dokunarak başlayın!',
               textAlign: TextAlign.center,
               style: TextStyle(color: Colors.teal, fontSize: 15, height: 1.5),
               )),
      );
    }

    final petsToShow = petProvider.pets.take(3).toList();
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: petsToShow.length,
      itemBuilder: (context, index) {
        final pet = petsToShow[index];
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
            trailing: Icon(Icons.chevron_right, color: Colors.grey.shade400), // const kaldırıldı
            onTap: (){
              // TODO: [Navigation] Evcil Hayvan Detay Sayfasına Git
              // Navigator.push(context, MaterialPageRoute(builder: (context) => PetDetailScreen(petId: pet.id)));
               // print("Pet Tapped: ${pet.name}"); // Debug için bırakıldı (avoid_print uyarısı normal)
            },
          ),
        );
      },
    );
  }
}

// ---------------------------------------------------------
// AppDrawer Widget Tanımı
// ---------------------------------------------------------
class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    // TODO: [Auth] Burayı gerçek Auth Provider'dan okuyun
    const bool isLoggedIn = false; // Geçici

    return Drawer(
      child: Column(
        children: [
          const DrawerHeader( /* ... İçerik aynı ... */
            decoration: BoxDecoration(color: Colors.teal),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                 Row(
                   children: [
                     Icon(Icons.pets, color: Colors.white, size: 35),
                     SizedBox(width: 12),
                     Text(
                      'PawCare',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold
                      ),
                    ),
                   ],
                 ),
                 SizedBox(height: 8),
                 Text(
                   'Evcil dostlarınız için her şey',
                   style: TextStyle(color: Color.fromRGBO(255, 255, 255, 0.8)),
                 ),
              ],
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile( /* Ana Sayfa */
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Ana Sayfa'),
                  tileColor: ModalRoute.of(context)?.settings.name == '/' || context.widget is HomeScreen
                      ? Colors.teal.withAlpha((255 * 0.1).round()) : null,
                  onTap: () { /* ... onTap aynı ... */
                     if (ModalRoute.of(context)?.settings.name == '/' || context.widget is HomeScreen) {
                       Navigator.pop(context);
                    } else {
                       Navigator.pushAndRemoveUntil(
                         context,
                         MaterialPageRoute(builder: (context) => const HomeScreen()),
                         (route) => false,
                       );
                    }
                  },
                ),
                // --- Giriş Yapmış Kullanıcı Menüsü ---
                // 'dead_code' uyarısı normal
                if (isLoggedIn) ...[
                   ListTile( /* Evcil Hayvanlarım */
                    leading: const Icon(Icons.pets_outlined),
                    title: const Text('Evcil Hayvanlarım'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const PetsListScreen()));
                    },
                  ),
                  ListTile( /* Aşı Takvimi */
                    leading: const Icon(Icons.medical_services_outlined),
                    title: const Text('Aşı Takvimi'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const VaccinationScreen()));
                    },
                  ),
                  ListTile( /* İlaçlar */
                    leading: const Icon(Icons.medication_outlined),
                    title: const Text('İlaçlar'),
                    onTap: () {
                       Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const MedicationScreen()));
                    },
                  ),
                  ListTile( /* Veteriner Bul */
                    leading: const Icon(Icons.location_on_outlined),
                    title: const Text('Veteriner Bul'),
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const FindVetScreen()));
                    },
                  ),
                ],
                // --- Herkes İçin Menü ---
                const Divider(indent: 16, endIndent: 16),
                ListTile( /* Ayarlar */
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
          ), // Expanded sonu
          const Divider(indent: 16, endIndent: 16, height: 1),
          // Giriş/Kayıt veya Çıkış Butonları
          if (!isLoggedIn)
             _buildLoginSignupButtons(context) // Canlı kod
          else
             _buildLogoutButton(context), // 'dead_code' uyarısı normal

          const SafeArea(bottom: true, child: SizedBox(height: 0)),
        ],
      ),
    );
  }

  // Giriş/Kayıt Butonlarını oluşturan yardımcı widget
  Widget _buildLoginSignupButtons(BuildContext context){
     return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
        child: Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                icon: const Icon(Icons.login, size: 18),
                label: const Text('Giriş Yap'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const LoginScreen()));
                },
                style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.teal,
                    side: BorderSide(color: Colors.teal.shade200), // const kaldırıldı
                    padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.person_add_alt_1, size: 18),
                label: const Text('Kayıt Ol'),
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.push(context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
                },
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12)),
              ),
            ),
          ],
        ),
      );
  }

   // Çıkış Yap Butonunu oluşturan yardımcı widget
   Widget _buildLogoutButton(BuildContext context){
     // Bu blok 'dead_code' uyarısı alacaktır
      return Padding(
         padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 15.0),
         child: TextButton.icon(
           icon: const Icon(Icons.logout, color: Colors.red),
           label: const Text('Çıkış Yap', style: TextStyle(color: Colors.red)),
           onPressed: () {
             // TODO: [Auth] Gerçek Çıkış Yapma İşlemini Burada Yap
             Navigator.pop(context);
             ScaffoldMessenger.of(context).showSnackBar(
                 const SnackBar(content: Text("Çıkış yapıldı (Simülasyon).")));
             // TODO: [Navigation] Kullanıcıyı giriş ekranına yönlendir
           },
           style: TextButton.styleFrom(alignment: Alignment.centerLeft),
         ),
       );
   }
}