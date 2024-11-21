import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Detail_transaksi.dart'; // Import file Detail_pesanan.dart
import 'package:wkwk/config/app_constants.dart';

class RiwayatTransaksiPage extends StatefulWidget {
  @override
  _RiwayatTransaksiPageState createState() => _RiwayatTransaksiPageState();
}

class _RiwayatTransaksiPageState extends State<RiwayatTransaksiPage> {
  List<Map<String, dynamic>> _transaksiList = [];

  @override
  void initState() {
    super.initState();
    _fetchTransaksi();
  }

  Future<void> _fetchTransaksi() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idPelanggan = prefs.getString('id_pelanggan');

    if (idPelanggan == null) {
      print('Error: ID Pelanggan tidak tersedia');
      return;
    }

    final String url = "${AppConstants.baseURL}/Riwayat.php";
    final response =
        await http.post(Uri.parse(url), body: {'id_pelanggan': idPelanggan});

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      setState(() {
        _transaksiList = data.cast<Map<String, dynamic>>();
        // Mengurutkan transaksi berdasarkan tanggal pesanan (terbaru di atas)
        _transaksiList.sort((a, b) => DateTime.parse(b['tanggal_pesan'])
            .compareTo(DateTime.parse(a['tanggal_pesan'])));
      });
    } else {
      print('Error: Unable to fetch transaction history');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0), // Set height to 55.0
        child: Container(
          decoration: BoxDecoration(
            color: Colors.green,
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: AppBar(
            title: Text(
              'Riwayat Transaksi',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor: Colors.transparent, // Transparent background
            elevation: 0, // No shadow
          ),
        ),
      ),
      body: _transaksiList.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: _transaksiList.length,
              itemBuilder: (context, index) {
                final transaksi = _transaksiList[index];

                return Card(
                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  elevation: 4,
                  child: Padding(
                    padding: EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Menampilkan nomor urut pesanan
                        Text(
                          'Pesanan ${_transaksiList.length - index}', // Nomor urut dibalik
                          style: GoogleFonts.poppins(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Status: ${transaksi['status_transaksi']}',
                          style: GoogleFonts.poppins(),
                        ),
                        Text(
                          'Metode Pembayaran: ${transaksi['metode_pembayaran']}',
                          style: GoogleFonts.poppins(),
                        ),
                        Text(
                          'Tanggal Pesanan: ${transaksi['tanggal_pesan']}',
                          style: GoogleFonts.poppins(),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Total Harga: Rp ${transaksi['total_harga']}',
                          style: GoogleFonts.poppins(),
                        ),
                        SizedBox(height: 10),
                        ElevatedButton(
                          onPressed: () {
                            // Navigasi ke Detail Pesanan
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => DetailPesananPage(
                                  transaksi:
                                      transaksi, // Mengirim data transaksi
                                  nomorPesanan: _transaksiList.length -
                                      index, // Menghitung nomor urut
                                ),
                              ),
                            );
                          },
                          child: Text('Detail Pesanan'),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
