import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_fonts/google_fonts.dart';
import 'package:wkwk/config/app_constants.dart';

class TransaksiPage extends StatefulWidget {
  final double totalHarga;
  final List<dynamic> keranjang;

  TransaksiPage({required this.totalHarga, required this.keranjang});

  @override
  _TransaksiPageState createState() => _TransaksiPageState();
}

class _TransaksiPageState extends State<TransaksiPage> {
  String metodePembayaran = 'DP';
  DateTime selectedDate = DateTime.now().add(Duration(days: 2));
  XFile? _gambarTransfer;
  String? _namaGambar;

  String alamat = '';

  double get finalTotalHarga {
    if (metodePembayaran == 'DP') {
      return widget.totalHarga / 2;
    }
    return widget.totalHarga;
  }

  Future<void> _sendPayment() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idPelanggan = prefs.getString('id_pelanggan');

    if (idPelanggan == null) {
      print('Error: ID Pelanggan tidak tersedia');
      return;
    }

    final String url = "${AppConstants.baseURL}/Transaksi.php";

    double bayar =
        metodePembayaran == 'DP' ? widget.totalHarga / 2 : widget.totalHarga;

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['id_pelanggan'] = idPelanggan
      ..fields['total_harga'] = widget.totalHarga.toString()
      ..fields['metode_pembayaran'] = metodePembayaran
      ..fields['tanggal_pesan'] = selectedDate.toString()
      ..fields['alamat'] = alamat
      ..fields['bayar'] = bayar.toString()
      ..fields['keranjang'] = jsonEncode(widget.keranjang); // Kirim keranjang

    if (_gambarTransfer != null) {
      if (kIsWeb) {
        var bytes = await _gambarTransfer!.readAsBytes();
        var multipartFile = http.MultipartFile.fromBytes(
          'gambar_transfer',
          bytes,
          filename: _namaGambar,
        );
        request.files.add(multipartFile);
      } else {
        request.files.add(await http.MultipartFile.fromPath(
          'gambar_transfer',
          _gambarTransfer!.path,
          filename: _namaGambar,
        ));
      }
    }

    try {
      final response = await request.send();
      final responseData = await response.stream.bytesToString();

      if (response.statusCode == 200) {
        final data = json.decode(responseData);
        if (data['response_status'] == "OK") {
          await _clearCart(idPelanggan);
          Navigator.pushReplacementNamed(context,
              '/riwayatPesan'); // Ganti '/riwayat' dengan nama route yang sesuai
        } else {
          print('Error: ${data['response_message']}');
        }
      } else {
        print('Error: Unable to process payment');
      }
    } catch (e) {
      print('Error: $e');
    }
  }

  Future<void> _clearCart(String idPelanggan) async {
    final String url = "http://10.0.164.244/Proyek%203/API/keranjang.php";
    final response = await http.post(
      Uri.parse(url),
      body: {
        'id_pelanggan': idPelanggan,
        'action': 'clear',
      },
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['response_status'] != "OK") {
        print('Error: ${data['response_message']}');
      }
    } else {
      print('Error: Unable to clear cart');
    }
  }

  void _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _namaGambar = 'bukti1.${pickedFile.path.split('.').last}';
        _gambarTransfer = pickedFile;
      });
    }
  }

  Widget buildImage() {
    if (_gambarTransfer == null) {
      return Container();
    }
    if (kIsWeb) {
      return FutureBuilder(
        future: _gambarTransfer!.readAsBytes(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            if (snapshot.hasData) {
              return Image.memory(
                snapshot.data!,
                height: 100,
                width: 100,
                fit: BoxFit.cover,
              );
            }
          }
          return Center(child: CircularProgressIndicator());
        },
      );
    } else {
      return Image.file(
        File(_gambarTransfer!.path),
        height: 100,
        width: 100,
        fit: BoxFit.cover,
      );
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
            leading: IconButton(
              icon: Icon(Icons.arrow_back),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
            title: Text(
              'Pembayaran',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Total Harga: Rp ${widget.totalHarga.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Pilih Metode Pembayaran :',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ListTile(
                    title: Text('DP', style: GoogleFonts.poppins()),
                    leading: Radio<String>(
                      value: 'DP',
                      groupValue: metodePembayaran,
                      onChanged: (String? value) {
                        setState(() {
                          metodePembayaran = value!;
                        });
                      },
                    ),
                  ),
                ),
                Expanded(
                  child: ListTile(
                    title: Text('Lunas', style: GoogleFonts.poppins()),
                    leading: Radio<String>(
                      value: 'Lunas',
                      groupValue: metodePembayaran,
                      onChanged: (String? value) {
                        setState(() {
                          metodePembayaran = value!;
                        });
                      },
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            Text(
              'Pilih Tanggal Pemesanan :',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            TextButton(
              onPressed: () async {
                final DateTime? pickedDate = await showDatePicker(
                  context: context,
                  initialDate: selectedDate,
                  firstDate: DateTime.now().add(Duration(days: 2)),
                  lastDate: DateTime(2101),
                );
                if (pickedDate != null && pickedDate != selectedDate) {
                  setState(() {
                    selectedDate = pickedDate;
                  });
                }
              },
              child: Text(
                'Tanggal : ${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                style: GoogleFonts.poppins(fontSize: 16),
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Silahkan Transfer Ke Rekening :',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            Text(
              '0000 1111 2222 3333',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Unggah Bukti Transfer :',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            TextButton(
              onPressed: _pickImage,
              child: Text(
                _gambarTransfer == null
                    ? 'Pilih Gambar'
                    : 'Gambar Terpilih: $_namaGambar',
                style: GoogleFonts.poppins(),
              ),
            ),
            buildImage(),
            SizedBox(height: 16),
            Text(
              'Isi Alamat :',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            TextField(
              onChanged: (value) {
                setState(() {
                  alamat = value;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Masukkan alamat pengiriman',
              ),
            ),
            SizedBox(height: 16),
            Text(
              'Detail Menu:',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: widget.keranjang.length,
              itemBuilder: (context, index) {
                var menu = widget.keranjang[index];
                return ListTile(
                  title: Text('${menu['nama_menu']} (Qty: ${menu['quantity']})',
                      style: GoogleFonts.poppins()),
                );
              },
            ),
            SizedBox(height: 16),
            Text(
              'Total Yang Harus Dibayar: Rp ${finalTotalHarga.toStringAsFixed(0)}',
              style: GoogleFonts.poppins(
                  fontSize: 20, fontWeight: FontWeight.bold),
            ),
            Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  _sendPayment();
                },
                child: Text(
                  'Bayar',
                  style: GoogleFonts.poppins(color: Colors.purple),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green, // Memperbaiki error di sini
                  padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
