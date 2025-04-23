import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'map_screen.dart';
import 'recommended_list.dart';
import 'utils.dart';

class ImageUploadScreen extends StatefulWidget {
  @override
  _ImageUploadScreenState createState() => _ImageUploadScreenState();
}

class _ImageUploadScreenState extends State<ImageUploadScreen> {
  File? _selectedImage;
  String _predictionResult = "";
  String _recommendation = "";
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _manavIsmiController = TextEditingController();

  Future<void> _pickImage(ImageSource source) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null || _manavIsmiController.text.isEmpty) return;

    try {
      Position position = await getCurrentLocation();
      String prediction = await uploadImageWithLocation(
        _selectedImage!,
        position.latitude,
        position.longitude,
        _manavIsmiController.text,
      );

      setState(() {
        _predictionResult = prediction;
      });

      if (prediction == "Taze") {
        setState(() {
          _recommendation =
              "Bu manav başarılı bir şekilde önerildi! Haritada ve şehir listesinde görünecek.";
        });
      } else {
        setState(() {
          _recommendation = "Bu ürün taze değil. Manav önerilmedi.";
        });
      }
    } catch (e) {
      print("Hata: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Meyve/Sebze Sınıflandırıcı")),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _selectedImage != null
                ? Image.file(_selectedImage!, height: 200)
                : Text("Fotoğraf seçin"),
            SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: TextField(
                controller: _manavIsmiController,
                decoration: InputDecoration(labelText: "Manav İsmi"),
              ),
            ),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.gallery),
                  child: Text("Galeriden Seç"),
                ),
                SizedBox(width: 10),
                ElevatedButton(
                  onPressed: () => _pickImage(ImageSource.camera),
                  child: Text("Kameradan Çek"),
                ),
              ],
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _uploadImage,
              child: Text("Tahmin Yap"),
            ),
            SizedBox(height: 20),
            Text("Tahmin Sonucu: $_predictionResult"),
            SizedBox(height: 20),
            Text("$_recommendation"),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => MapScreen(
                          apiKey: "AIzaSyDFGs6kB5848Xy86Zr2HI_GamCVi256UPs")),
                );
              },
              child: Text("Haritada Manavları Göster"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => RecommendedListScreen()),
                );
              },
              child: Text("Şehir Bazlı Önerileri Gör"),
            ),
          ],
        ),
      ),
    );
  }
}
