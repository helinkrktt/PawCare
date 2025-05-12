// lib/main.dart
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// Kendi proje yollarını doğru kullan
import 'package:flutter_application_1/providers/pet_provider.dart';
// *** Kendi AuthProvider'ınızı oluşturup import edin ***
// Eğer giriş/kayıt sistemi kullanacaksanız, bu provider gereklidir.
import 'package:flutter_application_1/providers/auth_provider.dart'; // Örnek dosya adı
import 'package:flutter_application_1/screens/home_screen.dart';
import 'package:flutter_application_1/screens/login_screen.dart';
import 'package:flutter_application_1/screens/splash_screen.dart'; // Başlangıç kontrolü için

// *** TÜM HIVE MODELLERİNİ IMPORT ET ***
import 'package:flutter_application_1/models/pet.dart';
import 'package:flutter_application_1/models/vaccination.dart';
import 'package:flutter_application_1/models/medication.dart';
// *** Eğer User modeli varsa onu da import edin ***
// import 'package:flutter_application_1/models/user.dart';


Future<void> main() async {
  // Flutter binding'lerini başlat
  WidgetsFlutterBinding.ensureInitialized();

  // --- Hive Başlatma ---
  await Hive.initFlutter();

  // --- Adapter'ları Kaydet ---
  // Modellerinizin Hive uyumlu olduğundan (@HiveType, .g.dart)
  // ve typeId'lerin benzersiz olduğundan emin olun!
  _registerHiveAdapters();

  // --- Kutuları Aç ---
  await _openHiveBoxes();

  // Uygulamayı başlat ve Provider'ları sağla
  runApp(
    MultiProvider(
      providers: [
        // Kendi AuthProvider'ınızı oluşturup buraya ekleyin
        // Firebase kullanmıyorsanız, bu provider kendi backend'inizle
        // veya yerel depolama ile iletişim kurmalıdır.
        ChangeNotifierProvider(create: (context) => AuthProvider()), // Örnek provider
        ChangeNotifierProvider(create: (context) => PetProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

// Hive Adapter'larını kaydeden yardımcı fonksiyon
void _registerHiveAdapters() {
   // Model dosyalarınızdaki typeId'lerle eşleştiğinden emin olun!
  if (!Hive.isAdapterRegistered(0)) { // PetAdapter varsayımı
    Hive.registerAdapter(PetAdapter());
  }
  if (!Hive.isAdapterRegistered(1)) { // VaccinationAdapter varsayımı
    Hive.registerAdapter(VaccinationAdapter());
  }
  if (!Hive.isAdapterRegistered(2)) { // MedicationAdapter varsayımı
    Hive.registerAdapter(MedicationAdapter());
  }
  // Eğer User modeliniz varsa ve Hive'da saklanacaksa:
  // if (!Hive.isAdapterRegistered(3)) { // UserAdapter varsayımı
  //   Hive.registerAdapter(UserAdapter());
  // }
}

// Gerekli Hive kutularını açan yardımcı fonksiyon
Future<void> _openHiveBoxes() async {
  try {
    await Hive.openBox<Pet>('pets');
    await Hive.openBox<Vaccination>('vaccinations');
    await Hive.openBox<Medication>('medications');
    // Eğer User modeliniz varsa ve Hive'da saklanacaksa:
    // await Hive.openBox<User>('users');
  } catch (e) {
     print("Hive kutuları açılırken hata: $e");
     // Kritik hata yönetimi eklenebilir.
  }
}


class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'PawCare',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.teal),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          elevation: 0,
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
        ),
         listTileTheme: ListTileThemeData(
           selectedTileColor: Colors.teal.withAlpha((255 * 0.1).round()),
         ),
      ),

      // --- Dinamik Başlangıç Ekranı ---
      // Auth durumunu kontrol etmek için AuthProvider'ı dinler
      home: Consumer<AuthProvider>( // Kendi AuthProvider'ınızın adını kullanın
        builder: (context, auth, _) {
          // AuthProvider'ınızdaki duruma göre karar verin
          // Bu durumlar sizin AuthProvider implementasyonunuza bağlı olacaktır
          switch (auth.status) { // AuthProvider'da bir 'status' enum/değişkeni olmalı
             case AuthStatus.authenticating:
             case AuthStatus.uninitialized: // Başlatılıyor veya kontrol ediliyor
               return const SplashScreen(); // Yükleme ekranı göster
            case AuthStatus.authenticated: // Giriş yapılmış
              return const HomeScreen();
             case AuthStatus.unauthenticated: // Giriş yapılmamış
             default: // Diğer veya bilinmeyen durumlar
              return const LoginScreen();
          }
        },
      ),

      debugShowCheckedModeBanner: false,
    );
  }
}

// Örnek AuthProvider (lib/providers/auth_provider.dart dosyasına taşıyın)
// Kendi kimlik doğrulama mantığınıza göre bu sınıfı implemente edin.
enum AuthStatus { uninitialized, authenticating, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  AuthStatus _status = AuthStatus.uninitialized; // Başlangıç durumu
  // Kendi User modeliniz veya kullanıcı bilgisi
  // User? _user;

  AuthStatus get status => _status;
  // User? get user => _user;
  bool get isLoggedIn => _status == AuthStatus.authenticated;

  AuthProvider() {
    // Uygulama başlarken giriş durumunu kontrol et
    _checkInitialAuthStatus();
  }

  Future<void> _checkInitialAuthStatus() async {
    // TODO: Kendi backend'inizden veya yerel depodan durumu kontrol edin
    // Örneğin, Secure Storage'dan token okuyup doğrulayın
    _status = AuthStatus.authenticating; // Kontrol ediliyor
    notifyListeners();

    await Future.delayed(const Duration(seconds: 1)); // Simülasyon

    // Simülasyon: Varsayılan olarak giriş yapılmamış kabul edelim
    bool loggedIn = false; // Burayı gerçek kontrolle değiştirin

    if (loggedIn) {
       _status = AuthStatus.authenticated;
       // _user = ... // Kullanıcı bilgilerini yükle
    } else {
       _status = AuthStatus.unauthenticated;
    }
    notifyListeners();
  }

  Future<void> login(String emailOrUsername, String password) async {
    _status = AuthStatus.authenticating;
    notifyListeners();
    try {
      // TODO: Kendi backend API'nize giriş isteği gönderin
      print("API Login: $emailOrUsername");
      await Future.delayed(const Duration(seconds: 1)); // Simülasyon
      // Başarılıysa:
      // _user = ... // Kullanıcı bilgisini al
      _status = AuthStatus.authenticated;
    } catch (e) {
      print("Login Error: $e");
      _status = AuthStatus.unauthenticated;
      rethrow; // Hatayı UI'a bildirmek için tekrar fırlat
    } finally {
       notifyListeners();
    }
  }

  Future<void> signUp(String email, String password, String username) async {
     _status = AuthStatus.authenticating;
     notifyListeners();
    try {
      // TODO: Kendi backend API'nize kayıt isteği gönderin
      print("API Signup: $username, $email");
      await Future.delayed(const Duration(seconds: 1)); // Simülasyon
      // Başarılıysa (genellikle direkt giriş yapılmaz, login ekranına yönlendirilir):
      _status = AuthStatus.unauthenticated; // Kayıt sonrası genellikle giriş gerekir
    } catch (e) {
      print("Signup Error: $e");
      _status = AuthStatus.unauthenticated;
       rethrow;
    } finally {
       notifyListeners();
    }
  }

  Future<void> logout() async {
     // TODO: Kendi backend API'nize çıkış isteği gönderin (token geçersiz kılma vb.)
     // TODO: Yerel depodan token/kullanıcı bilgisini silin
    _status = AuthStatus.unauthenticated;
    // _user = null;
    notifyListeners();
  }
}


// Örnek SplashScreen (lib/screens/splash_screen.dart içine taşıyın)
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: CircularProgressIndicator(color: Colors.teal),
      ),
    );
  }
}