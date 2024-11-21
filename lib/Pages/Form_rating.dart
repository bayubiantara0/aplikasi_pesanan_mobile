import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:wkwk/config/app_constants.dart';

class FormRatingPage extends StatefulWidget {
  final int idMenu;
  final int idTransaksi;
  final int idDetailTransaksi;

  const FormRatingPage({
    Key? key,
    required this.idMenu,
    required this.idTransaksi,
    required this.idDetailTransaksi,
  }) : super(key: key);

  @override
  _FormRatingPageState createState() => _FormRatingPageState();
}

class _FormRatingPageState extends State<FormRatingPage> {
  double _rating = 0;
  String? _namaGambar;
  XFile? _gambarTransfer;
  TextEditingController _komentarController =
      TextEditingController(); // Controller untuk komentar

  late int idMenu;
  late int idTransaksi;
  late int idDetailTransaksi;

  @override
  void initState() {
    super.initState();
    idMenu = widget.idMenu;
    idTransaksi = widget.idTransaksi;
    idDetailTransaksi = widget.idDetailTransaksi;
  }

  Future<void> _pickImage() async {
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

  Future<void> _submitRating() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? idPelanggan = prefs.getString('id_pelanggan');

    if (idPelanggan == null) {
      print('Error: ID Pelanggan tidak tersedia');
      return;
    }

    final String url =
        "${AppConstants.baseURL}/API/FormRating.php"; // Ganti dengan URL API Anda

    var request = http.MultipartRequest('POST', Uri.parse(url))
      ..fields['id_pelanggan'] = idPelanggan
      ..fields['rating'] = _rating.toString()
      ..fields['komentar'] = _komentarController.text // Menambahkan komentar
      ..fields['id_menu'] = idMenu.toString() // Menambahkan id_menu
      ..fields['id_transaksi'] =
          idTransaksi.toString() // Menambahkan id_transaksi
      ..fields['id_detail_transaksi'] =
          idDetailTransaksi.toString(); // Menambahkan id_detail_transaksi

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
          Navigator.pop(context); // Kembali setelah sukses
        } else {
          print('Error: ${data['response_message']}');
        }
      } else {
        print('Error: Unable to submit rating');
      }
    } catch (e) {
      print('Error: $e');
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
              'Form Rating',
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
              'Beri Rating:',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            RatingBar.builder(
              initialRating: _rating,
              minRating: 1,
              maxRating: 5,
              allowHalfRating: true,
              itemBuilder: (context, _) => Icon(
                Icons.star,
                color: Colors.amber,
              ),
              onRatingUpdate: (rating) {
                setState(() {
                  _rating = rating;
                });
              },
            ),
            SizedBox(height: 16),
            Text(
              'Komentar:',
              style: GoogleFonts.poppins(fontSize: 16),
            ),
            TextField(
              controller: _komentarController,
              decoration: InputDecoration(
                border: OutlineInputBorder(),
                hintText: 'Tulis komentar di sini',
              ),
              maxLines: 3,
            ),
            SizedBox(height: 16),
            Text(
              'Unggah Bukti Gambar:',
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
            Center(
              child: ElevatedButton(
                onPressed: _submitRating,
                child: Text(
                  'Kirim Rating',
                  style: GoogleFonts.poppins(color: Colors.white),
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
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
