import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class EditProfilPage extends StatefulWidget {
  final int idPelanggan;

  EditProfilPage({required this.idPelanggan});

  @override
  _EditProfilPageState createState() => _EditProfilPageState();
}

class _EditProfilPageState extends State<EditProfilPage> {
  TextEditingController _namaController = TextEditingController();
  TextEditingController _teleponController = TextEditingController();
  TextEditingController _emailController = TextEditingController(); // Controller untuk email
  TextEditingController _passwordController = TextEditingController();

  bool _obscurePassword = true; // Untuk mengatur apakah password tersembunyi atau tidak

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final String url = "http://10.0.164.244/API/Pelanggan.php";

    try {
        final response = await http.get(Uri.parse(url));

        if (response.statusCode == 200) {
            Map<String, dynamic> data = json.decode(response.body);

            // Periksa apakah data ada
            if (data['data'].isNotEmpty) {
                var pelangganData = data['data'][0];
                setState(() {
                    _namaController.text = pelangganData['nama'];
                    _teleponController.text = pelangganData['telepon'];
                    _emailController.text = pelangganData['email']; // Pastikan email juga ada di database
                });
            } else {
                print('Data pelanggan tidak ditemukan');
            }
        } else {
            print('Failed to load data: ${response.statusCode}');
        }
    } catch (e) {
        print('Error fetching data: $e');
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
              'Edit Profile',
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _namaController,
              decoration: InputDecoration(labelText: 'Nama'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _teleponController,
              decoration: InputDecoration(labelText: 'Telepon'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _emailController, // Field untuk email
              decoration: InputDecoration(labelText: 'Email'),
            ),
            SizedBox(height: 16.0),
            TextField(
              controller: _passwordController,
              obscureText: _obscurePassword,
              decoration: InputDecoration(
                labelText: 'Password',
                suffixIcon: IconButton(
                  icon: Icon(_obscurePassword ? Icons.visibility : Icons.visibility_off),
                  onPressed: () {
                    setState(() {
                      _obscurePassword = !_obscurePassword;
                    });
                  },
                ),
              ),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: () {
                _simpanPerubahan();
              },
              child: Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  void _simpanPerubahan() {
    final String url = "http://10.0.164.244/API/Pelanggan.php?id_pelanggan=${widget.idPelanggan}";

    http.put(Uri.parse(url), body: {
      'nama': _namaController.text,
      'telepon': _teleponController.text,
      'email': _emailController.text, // Tambahkan email untuk disimpan
      'password': _passwordController.text,
    }).then((response) {
      if (response.statusCode == 200) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Data berhasil disimpan'),
          ),
        );
      } else {
        print('Failed to save data: ${response.statusCode}');
      }
    }).catchError((error) {
      print('Error: $error');
    });
  }
}
