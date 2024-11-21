import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'Transaksi.dart';
import 'package:wkwk/config/app_constants.dart';

class KeranjangPage extends StatefulWidget {
  @override
  _KeranjangPageState createState() => _KeranjangPageState();
}

class _KeranjangPageState extends State<KeranjangPage> {
  List<dynamic> cartItems = [];
  String idPelanggan = '';
  double totalPrice = 0.0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadIdPelangganDanAmbilData();
  }

  Future<void> _loadIdPelangganDanAmbilData() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        idPelanggan = prefs.getString('id_pelanggan') ?? '';
      });
      if (idPelanggan.isNotEmpty) {
        await ambilDataKeranjang();
      } else {
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading SharedPreferences: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> ambilDataKeranjang() async {
    final String url = "${AppConstants.baseURL}/API/keranjang.php";
    final response = await http.post(
      Uri.parse(url),
      body: {'id_pelanggan': idPelanggan},
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['response_status'] == "OK") {
        setState(() {
          cartItems = data['data'];
          totalPrice = cartItems.fold(
            0.0,
            (sum, item) => sum + (double.parse(item['total_harga'] ?? '0')),
          );
          isLoading = false;
        });
      } else {
        setState(() {
          cartItems = [];
          isLoading = false;
        });
        print('Gagal mengambil data keranjang: ${data['response_message']}');
      }
    } else {
      setState(() {
        cartItems = [];
        isLoading = false;
      });
      print(
          'Gagal mengambil data keranjang. Status code: ${response.statusCode}');
    }
  }

  Future<void> perbaruiItemKeranjang(String idMenu, int jumlahBaru) async {
    final String url = "${AppConstants.baseURL}/API/keranjang.php";
    final response = await http.post(
      Uri.parse(url),
      body: {
        'id_pelanggan': idPelanggan,
        'id_menu': idMenu,
        'quantity': jumlahBaru.toString(),
        'action': 'update',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['response_status'] == "OK") {
        await ambilDataKeranjang(); // Memanggil kembali fungsi untuk memperbarui data setelah perubahan berhasil
      } else {
        print('Gagal memperbarui item: ${data['response_message']}');
      }
    } else {
      print('Gagal memperbarui item. Status code: ${response.statusCode}');
    }
  }

  Future<void> hapusItemKeranjang(String idMenu) async {
    final String url = "${AppConstants.baseURL}/API/keranjang.php";
    final response = await http.post(
      Uri.parse(url),
      body: {
        'id_pelanggan': idPelanggan,
        'id_menu': idMenu,
        'action': 'delete',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['response_status'] == "OK") {
        await ambilDataKeranjang(); // Memanggil kembali fungsi untuk memperbarui data setelah perubahan berhasil
      } else {
        print('Gagal menghapus item: ${data['response_message']}');
      }
    } else {
      print('Gagal menghapus item. Status code: ${response.statusCode}');
    }
  }

  void _showModalBottomSheet(String message,
      {Color backgroundColor = Colors.white}) {
    showModalBottomSheet(
      context: context,
      backgroundColor: backgroundColor, // Set background color
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(16.0),
          child: Text(
            message,
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            textAlign: TextAlign.center,
          ),
        );
      },
    );

    // Tunggu 0.5 detik sebelum menutup BottomSheet
    Future.delayed(Duration(milliseconds: 500), () {
      Navigator.pop(context); // Tutup BottomSheet
    });
  }

  void _tambahJumlah(String idMenu, int jumlahSaatIni) {
    perbaruiItemKeranjang(
        idMenu, jumlahSaatIni + 5); // Menambah jumlah item di keranjang
  }

  void _kurangiJumlah(String idMenu, int jumlahSaatIni) {
    // Cek apakah jumlah saat ini setelah pengurangan masih >= 50
    if (jumlahSaatIni - 5 >= 50) {
      perbaruiItemKeranjang(
          idMenu, jumlahSaatIni - 5); // Mengurangi jumlah item di keranjang
    } else {
      _showModalBottomSheet("Jumlah harus lebih dari 50",
          backgroundColor:
              Colors.red); // Mengubah warna latar belakang menjadi merah
    }
  }

  void _ubahJumlah(String idMenu, String value) {
    int jumlahBaru = int.tryParse(value) ?? 0;
    // Cek apakah jumlah baru >= 50
    if (jumlahBaru >= 50) {
      perbaruiItemKeranjang(idMenu, jumlahBaru);
    } else {
      _showModalBottomSheet("Jumlah harus lebih dari 50",
          backgroundColor:
              Colors.red); // Mengubah warna latar belakang menjadi merah
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55.0), // Sesuaikan tinggi jika perlu
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
              'Keranjang',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            backgroundColor:
                Colors.transparent, // Membuat warna AppBar transparan
            elevation: 0, // Menghilangkan bayangan
          ),
        ),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : cartItems.isEmpty
              ? Center(
                  child: Text(
                    'Keranjang kosong',
                    style: GoogleFonts.poppins(),
                  ),
                )
              : Column(
                  children: [
                    Expanded(
                      child: ListView.builder(
                        itemCount: cartItems.length,
                        itemBuilder: (BuildContext context, int index) {
                          var item = cartItems[index];
                          var idMenu = item['id_menu'].toString();
                          var jumlah = int.parse(item['quantity'].toString());
                          var totalHarga =
                              double.parse(item['total_harga'].toString());

                          return Card(
                            margin: EdgeInsets.all(8.0),
                            child: ListTile(
                              title: Text(
                                item['nama_menu'].toString(),
                                style: GoogleFonts.poppins(),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Harga: Rp ${item['harga_menu']}',
                                    style: GoogleFonts.poppins(),
                                  ),
                                  Row(
                                    children: [
                                      IconButton(
                                        icon: Icon(Icons.remove),
                                        onPressed: () {
                                          _kurangiJumlah(idMenu, jumlah);
                                        },
                                      ),
                                      Container(
                                        width: 50, // Lebar kolom input
                                        child: TextField(
                                          keyboardType: TextInputType.number,
                                          textAlign: TextAlign.center,
                                          decoration: InputDecoration(
                                            border: OutlineInputBorder(),
                                            contentPadding:
                                                EdgeInsets.symmetric(
                                                    vertical: 0),
                                          ),
                                          onSubmitted: (value) =>
                                              _ubahJumlah(idMenu, value),
                                          controller: TextEditingController(
                                            text: jumlah.toString(),
                                          ),
                                        ),
                                      ),
                                      IconButton(
                                        icon: Icon(Icons.add),
                                        onPressed: () {
                                          _tambahJumlah(idMenu, jumlah);
                                        },
                                      ),
                                    ],
                                  ),
                                  Text(
                                    'Total: Rp $totalHarga',
                                    style: GoogleFonts.poppins(),
                                  ),
                                ],
                              ),
                              trailing: IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () {
                                  hapusItemKeranjang(idMenu);
                                },
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                    Container(
                      color: Colors.green,
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total Harga: Rp $totalPrice',
                            style: GoogleFonts.poppins(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => TransaksiPage(
                                    totalHarga: totalPrice,
                                    keranjang: cartItems,
                                  ),
                                ),
                              );
                            },
                            child: Text('Bayar'),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
    );
  }
}
