import 'package:flutter/material.dart';
import 'package:wkwk/User_model.dart';
import 'package:wkwk/header.dart'; // Import CustomHeader

class Akun extends StatelessWidget {
  const Akun({Key? key}) : super(key: key);

  Future<void> _logOut(BuildContext context) async {
    await UserModel.logOut();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomHeader(
                backgroundColor: Colors.green), // Atur warna header di sini
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  ElevatedButton(
                    onPressed: () {
                      // Navigasi ke halaman Riwayat Pesan
                      Navigator.pushNamed(context, '/riwayatPesan');
                    },
                    child: Text('Riwayat Pesan'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      // Navigasi ke halaman Edit Profil
                      Navigator.pushNamed(context, '/editProfil');
                    },
                    child: Text('Edit Profile'),
                  ),
                  SizedBox(height: 10),
                  ElevatedButton(
                    onPressed: () {
                      _logOut(context);
                    },
                    child: Text('Log Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red, // Warna tombol log out
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
