import 'dart:io';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:geocoding/geocoding.dart';

Future<Position> getCurrentLocation() async {
  bool serviceEnabled;
  LocationPermission permission;

  serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (!serviceEnabled) throw Exception("Konum servisi kapalı!");

  permission = await Geolocator.checkPermission();
  if (permission == LocationPermission.denied) {
    permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.deniedForever) {
      throw Exception("Konum izinleri reddedildi!");
    }
  }
  return await Geolocator.getCurrentPosition();
}

Future<String> getCityFromCoordinates(double lat, double lng) async {
  List<Placemark> placemarks = await placemarkFromCoordinates(lat, lng);
  if (placemarks.isNotEmpty) {
    return placemarks.first.administrativeArea ?? "Bilinmeyen Şehir";
  }
  return "Bilinmeyen Şehir";
}

Future<String> uploadImageWithLocation(
  File image,
  double latitude,
  double longitude,
  String manavIsmi,
) async {
  try {
    String sehir = await getCityFromCoordinates(latitude, longitude);

    // 🌐 Konumları yuvarlıyoruz
    double roundedLat = double.parse(latitude.toStringAsFixed(5));
    double roundedLng = double.parse(longitude.toStringAsFixed(5));

    var request = http.MultipartRequest(
      'POST',
      Uri.parse("http://192.168.1.102:5000/predict"),
    );
    request.fields['latitude'] = roundedLat.toString();
    request.fields['longitude'] = roundedLng.toString();
    request.fields['manavIsmi'] = manavIsmi;
    request.fields['sehir'] = sehir;
    request.files.add(await http.MultipartFile.fromPath('file', image.path));

    var response = await request.send();
    var responseData = await response.stream.bytesToString();

    if (response.statusCode == 200) {
      var jsonResponse = json.decode(responseData);
      String prediction = jsonResponse['prediction'];

      if (prediction == 'Taze') {
        var saveResponse = await http.post(
          Uri.parse("http://192.168.1.102:5001/save"),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "prediction": prediction,
            "manavIsmi": manavIsmi,
            "sehir": sehir,
            "latitude": roundedLat,
            "longitude": roundedLng,
          }),
        );

        print("Firestore'a kayıt sonucu: ${saveResponse.body}");
      }

      return prediction;
    } else {
      return "Tahmin başarısız!";
    }
  } catch (e) {
    return "Hata oluştu: $e";
  }
}
