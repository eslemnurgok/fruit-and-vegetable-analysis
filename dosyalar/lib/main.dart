// 📁 main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'image_upload.dart';
import 'map_screen.dart';
import 'recommended_list.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  final String googleMapsApiKey =
      "AIzaSyDFGs6kB5848Xy86Zr2HI_GamCVi256UPs"; // 🔑 Senin API anahtarın

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: "Meyve/Sebze Sınıflandırıcı",
      theme: ThemeData(primarySwatch: Colors.green),
      home: HomeScreen(apiKey: googleMapsApiKey),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final String apiKey;

  const HomeScreen({required this.apiKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meyve/Sebze Sınıflandırıcı")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ImageUploadScreen()),
              ),
              child: Text("📷 Fotoğraf Yükle ve Sınıflandır"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => MapScreen(apiKey: apiKey)),
              ),
              child: Text("🗺️ Haritada Manavları Gör"),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => RecommendedListScreen()),
              ),
              child: Text("📍 Şehir Bazlı Öneriler"),
            ),
          ],
        ),
      ),
    );
  }
}
