import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_application_1/providers/pet_provider.dart'; // PetProvider'ı import et
import 'package:geolocator/geolocator.dart'; // Ayarları açma butonları için

class FindVetScreen extends StatelessWidget {
  const FindVetScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Provider'ı dinle (hem state değişiklikleri hem de metot çağırma için)
    // 'watch' kullanmak, isLoadingLocation veya locationErrorMessage değiştiğinde
    // build metodunun tekrar çalışmasını sağlar.
    final petProvider = context.watch<PetProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Yakındaki Veterinerleri Bul'),
        backgroundColor: Colors.teal, // Diğer ekranlarla uyumlu tema
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(25.0), // Biraz daha fazla padding
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center, // Ortala
            crossAxisAlignment: CrossAxisAlignment.stretch, // Butonun genişlemesi için
            children: [
              Icon(
                Icons.location_on_outlined, // Konum ikonu
                size: 80,
                color: Colors.teal.shade700,
              ),
              const SizedBox(height: 20),
              const Text(
                'Cihazınızın konumunu kullanarak yakınınızdaki veterinerleri haritada arayalım.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 17, color: Colors.black54),
              ),
              const SizedBox(height: 40),

              // Yükleniyor durumu veya Ana Buton
              if (petProvider.isLoadingLocation)
                const Center(child: CircularProgressIndicator(color: Colors.teal))
              else
                ElevatedButton.icon(
                  icon: const Icon(Icons.search), // Arama ikonu
                  label: const Text('Veterinerleri Haritada Ara'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal, // Buton rengi
                    foregroundColor: Colors.white, // Yazı rengi
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Hafif yuvarlak köşeler
                    ),
                    elevation: 3, // Hafif gölge
                  ),
                  onPressed: () {
                    // Butona basıldığında Provider'daki metodu çağır
                    // 'read' veya 'listen: false' kullanmak, butona basıldığında
                    // gereksiz yere build metodunun tekrar çalışmasını engeller.
                    context.read<PetProvider>().launchVeterinarianSearchInMap();
                  },
                ),

              const SizedBox(height: 25),

              // Hata Mesajı Alanı
              // Eğer bir hata mesajı varsa göster
              if (petProvider.locationErrorMessage != null)
                _buildErrorSection(context, petProvider.locationErrorMessage!), // Yardımcı metot kullanıldı

            ],
          ),
        ),
      ),
    );
  }

  // Hata mesajı ve ilgili butonları gösteren yardımcı metot
  Widget _buildErrorSection(BuildContext context, String errorMessage) {
    bool isPermissionError = errorMessage.contains("reddedildi");
    bool isServiceError = errorMessage.contains("kapalı");

    return Column(
      children: [
        Icon(Icons.error_outline, color: Colors.red.shade700, size: 30),
        const SizedBox(height: 8),
        Text(
          errorMessage,
          textAlign: TextAlign.center,
          style: TextStyle(color: Colors.red.shade700, fontSize: 15),
        ),
        const SizedBox(height: 15),

        // İzin veya Servis hatasına özel butonlar
        if (isPermissionError)
          TextButton.icon(
            icon: const Icon(Icons.settings, color: Colors.blueGrey),
            label: const Text("Uygulama Ayarlarını Aç"),
            style: TextButton.styleFrom(foregroundColor: Colors.blueGrey),
            onPressed: () => Geolocator.openAppSettings(),
          )
        else if (isServiceError)
          TextButton.icon(
            icon: const Icon(Icons.location_off_outlined, color: Colors.blueGrey),
            label: const Text("Konum Ayarlarını Aç"),
            style: TextButton.styleFrom(foregroundColor: Colors.blueGrey),
            onPressed: () => Geolocator.openLocationSettings(),
          ),

        // Her durumda "Tekrar Dene" butonu
        OutlinedButton.icon(
          icon: const Icon(Icons.refresh),
          label: const Text("Tekrar Dene"),
           style: OutlinedButton.styleFrom(
             foregroundColor: Colors.teal, // Kenarlık ve yazı rengi
             side: BorderSide(color: Colors.teal.shade200), // Kenarlık rengi
           ),
          onPressed: () {
            // Tekrar denemek için aynı metodu çağır
            context.read<PetProvider>().launchVeterinarianSearchInMap();
          },
        ),
      ],
    );
  }
}