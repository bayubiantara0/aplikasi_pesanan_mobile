import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'Detail_menu.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wkwk/config/app_constants.dart';

class MenuCard extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String description;
  final String idMenu;
  final String idPelanggan;
  final Function refreshMenuList; // Function to refresh menu list

  const MenuCard({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.description,
    required this.idMenu,
    required this.idPelanggan,
    required this.refreshMenuList, // Required parameter
  }) : super(key: key);

  Future<void> addToCart(BuildContext context) async {
    final String apiUrl = '${AppConstants.baseURL}/keranjang.php';
    final response = await http.post(
      Uri.parse(apiUrl),
      body: {
        'id_menu': idMenu,
        'quantity': '50', // Sesuaikan sesuai kebutuhan Anda
        'id_pelanggan': idPelanggan,
      },
    );

    if (response.statusCode == 200) {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Ditambahkan ke keranjang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          );
        },
      );
      refreshMenuList(); // Segarkan daftar menu setelah ditambahkan ke keranjang

      // Tunggu 0.5 detik sebelum menutup BottomSheet
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pop(context); // Tutup BottomSheet
    } else {
      showModalBottomSheet(
        context: context,
        builder: (context) {
          return Container(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'Gagal menambahkan ke keranjang',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          );
        },
      );

      // Tunggu 0.5 detik sebelum menutup BottomSheet
      await Future.delayed(Duration(milliseconds: 500));
      Navigator.pop(context); // Tutup BottomSheet
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(10.0)),
              child: Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Center(
                    child: Text('Image not found',
                        style: TextStyle(color: Colors.red)),
                  );
                },
                loadingBuilder: (BuildContext context, Widget child,
                    ImageChunkEvent? loadingProgress) {
                  if (loadingProgress == null) {
                    return child;
                  } else {
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                (loadingProgress.expectedTotalBytes ?? 1)
                            : null,
                      ),
                    );
                  }
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: GoogleFonts.poppins(
                    fontWeight: FontWeight.bold,
                    fontSize: 14.0,
                  ),
                ),
                SizedBox(height: 4.0),
                Text(
                  price,
                  style: GoogleFonts.poppins(
                    color: Colors.grey[600],
                    fontSize: 12.0,
                  ),
                ),
                SizedBox(height: 8.0),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: Icon(Icons.info_outline, color: Colors.green),
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => MenuDetail(
                              imageUrl: imageUrl,
                              title: title,
                              price: price,
                              description: description,
                            ),
                          ),
                        );
                      },
                      iconSize: 20.0,
                    ),
                    IconButton(
                      icon: Icon(Icons.shopping_cart, color: Colors.green),
                      onPressed: () {
                        addToCart(context);
                      },
                      iconSize: 20.0,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
