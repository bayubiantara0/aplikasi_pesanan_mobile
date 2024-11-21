import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:google_fonts/google_fonts.dart';
import 'package:wkwk/header.dart'; // Import CustomHeader
import 'Form_rating.dart'; // Import FormRatingPage
import 'package:wkwk/config/app_constants.dart';

class RatingPage extends StatefulWidget {
  @override
  _RatingPageState createState() => _RatingPageState();
}

class _RatingPageState extends State<RatingPage> {
  List<dynamic> ratings = [];

  @override
  void initState() {
    super.initState();
    fetchRatings();
  }

  Future<void> fetchRatings() async {
    try {
      final response =
          await http.get(Uri.parse('${AppConstants.baseURL}/API/Rating.php'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['response_status'] == 'OK') {
          setState(() {
            ratings = data['data'];
          });
        } else {
          print(data['response_message']); // Log jika tidak ada data
        }
      } else {
        throw Exception('Failed to load ratings');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  void _navigateToReviewForm(
      int idMenu, int idTransaksi, int idDetailTransaksi) {
    // Debug log
    print(
        'Navigating to FormRatingPage with: idMenu=$idMenu, idTransaksi=$idTransaksi, idDetailTransaksi=$idDetailTransaksi');

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FormRatingPage(
          idMenu: idMenu,
          idTransaksi: idTransaksi,
          idDetailTransaksi: idDetailTransaksi,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomHeader(backgroundColor: Colors.green),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: ratings.length,
                itemBuilder: (BuildContext context, int index) {
                  var menu = ratings[index];
                  return Card(
                    elevation: 2.0,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0)),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Ulasan ${ratings.length - index}', // Menggunakan jumlah ratings dan index
                            style: GoogleFonts.poppins(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text('Menu: ${menu['nama_menu']}',
                              style: TextStyle(fontSize: 16.0)),
                          Text('Tanggal Pesan: ${menu['tanggal_pesan']}',
                              style: TextStyle(color: Colors.grey)),
                          Text(
                              'Tanggal Transaksi: ${menu['tanggal_transaksi']}',
                              style: TextStyle(color: Colors.grey)),
                          SizedBox(height: 8.0),
                          ElevatedButton(
                            onPressed: () {
                              // Ambil id_menu, id_transaksi, dan id_detail_transaksi dan konversi ke integer jika diperlukan
                              int idMenu =
                                  int.tryParse(menu['id_menu'].toString()) ?? 0;
                              int idTransaksi = int.tryParse(
                                      menu['id_transaksi'].toString()) ??
                                  0;
                              int idDetailTransaksi = int.tryParse(
                                      menu['id_detail_transaksi'].toString()) ??
                                  0;

                              // Navigasi ke form rating
                              _navigateToReviewForm(
                                  idMenu, idTransaksi, idDetailTransaksi);
                            },
                            child: Text('Beri Ulasan'),
                          ),
                        ],
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
