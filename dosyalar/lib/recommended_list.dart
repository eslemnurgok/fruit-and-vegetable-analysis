import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RecommendedListScreen extends StatefulWidget {
  @override
  _RecommendedListScreenState createState() => _RecommendedListScreenState();
}

class _RecommendedListScreenState extends State<RecommendedListScreen> {
  final List<String> cities = ["Malatya", "Yalova", "İstanbul", "Ankara"];
  String? selectedCity;
  List<Map<String, dynamic>> manavList = [];

  Future<void> _loadManavlarByCity(String city) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection('manavlar')
          .where('sehir', isEqualTo: city)
          .get();

      setState(() {
        manavList = snapshot.docs
            .map((doc) => doc.data() as Map<String, dynamic>)
            .toList();
      });
    } catch (e) {
      print("Şehir bazlı veriler alınırken hata oluştu: $e");
      setState(() {
        manavList = [];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Şehirlere Göre Manav Önerileri")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            DropdownButton<String>(
              value: selectedCity,
              hint: Text("Bir şehir seçin"),
              items: cities.map((city) {
                return DropdownMenuItem<String>(
                  value: city,
                  child: Text(city),
                );
              }).toList(),
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedCity = value;
                    manavList.clear();
                  });
                  _loadManavlarByCity(value);
                }
              },
            ),
            SizedBox(height: 20),
            Expanded(
              child: manavList.isEmpty
                  ? Center(child: Text("Seçilen şehirde manav önerisi yok."))
                  : ListView.builder(
                      itemCount: manavList.length,
                      itemBuilder: (context, index) {
                        final manav = manavList[index];
                        return Card(
                          child: ListTile(
                            leading: Icon(Icons.store, color: Colors.green),
                            title: Text(manav['manavIsmi'] ?? "Manav"),
                            subtitle: Text(
                              "Şehir: ${manav['sehir']}\nKonum: ${manav['latitude']}, ${manav['longitude']}\nÖnerilme Sayısı: ${manav['puan'] ?? 0}",
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
