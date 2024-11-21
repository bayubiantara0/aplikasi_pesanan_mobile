import 'package:flutter/material.dart';
import 'package:wkwk/landing.dart';
import 'package:wkwk/login.dart';
import 'package:wkwk/edit_profile.dart';
import 'package:wkwk/Pages/Rating_page.dart';
import 'package:wkwk/Pages/Keranjang.dart';
import 'package:wkwk/launcher.dart';
import 'package:wkwk/Pages/Riwayat.dart';
import 'package:wkwk/DriverLanding.dart'; // Impor DriverLandingPage

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    int idPelanggan = 1; // Nilai idPelanggan yang sesuai

    return MaterialApp(
      title: 'Buya Galung',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      initialRoute: '/launcher', // Halaman awal saat aplikasi dimulai
      routes: <String, WidgetBuilder>{
        '/launcher': (BuildContext context) => LauncherPage(),
        '/login': (BuildContext context) => LoginPage(),
        '/landing': (BuildContext context) => LandingPage(isDriver: false), // Ganti sesuai kebutuhan
        '/driverLanding': (BuildContext context) => DriverLandingPage(), // Rute untuk DriverLandingPage
        '/riwayatPesan': (BuildContext context) => RiwayatTransaksiPage(),
        '/editProfil': (BuildContext context) => EditProfilPage(idPelanggan: idPelanggan),
        '/ratingPage': (BuildContext context) => RatingPage(),
        '/keranjang': (BuildContext context) => KeranjangPage(),
      },
    );
  }
}
