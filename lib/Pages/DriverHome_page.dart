import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Pastikan mengimpor http
import 'dart:convert'; // Pastikan mengimpor dart:convert
import 'package:wkwk/config/app_constants.dart';

class DriverHomePage extends StatefulWidget {
  @override
  _DriverHomePageState createState() => _DriverHomePageState();
}

class _DriverHomePageState extends State<DriverHomePage> {
  List<dynamic> orders = []; // Daftar pesanan

  @override
  void initState() {
    super.initState();
    fetchOrders(); // Ambil data pesanan saat halaman dibuka
  }

  Future<void> fetchOrders() async {
    // Ganti dengan URL API yang sesuai
    final String url = "${AppConstants.baseURL}/API/GetOrders.php";

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          orders = data; // Simpan data pesanan
        });
      } else {
        throw Exception('Gagal memuat pesanan');
      }
    } catch (e) {
      print(e);
      // Menangani kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat pesanan, coba lagi.')),
      );
    }
  }

  void _showConfirmationDialog(BuildContext context, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Konfirmasi'),
          content: Text('Apakah Anda yakin sudah mengambil pesanan ini?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(), // Tutup dialog
              child: Text('Batal'),
            ),
            TextButton(
              onPressed: () {
                // Tambahkan logika untuk menandai pesanan sebagai diambil
                // Misalnya, panggil API untuk memperbarui status pesanan
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                      content: Text('Pesanan telah ditandai sebagai diambil!')),
                );
              },
              child: Text('Ya'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              'Pesanan Terkini',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: orders.length, // Jumlah pesanan yang ditampilkan
                itemBuilder: (context, index) {
                  return Card(
                    margin: EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text(
                          'Pesanan #${orders[index]['id']}'), // Ganti dengan ID pesanan
                      subtitle: Text(
                          'Detail pesanan: ${orders[index]['detail']}'), // Ganti dengan detail pesanan yang relevan
                      trailing: IconButton(
                        icon: Icon(Icons.check_circle, color: Colors.green),
                        onPressed: () {
                          _showConfirmationDialog(context, index);
                        },
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
