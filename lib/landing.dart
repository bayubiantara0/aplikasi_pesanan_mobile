import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:wkwk/Pages/Home_page.dart'; // Halaman untuk pengguna
import 'package:wkwk/Pages/DriverHome_page.dart'; // Halaman khusus untuk driver
import 'package:wkwk/Pages/Akun.dart';
import 'package:wkwk/Pages/Rating_page.dart'; // Import RatingPage

class LandingPage extends StatefulWidget {
  final bool isDriver; // Menambahkan parameter untuk memeriksa apakah driver

  LandingPage({required this.isDriver}); // Konstruktor dengan parameter

  @override
  _LandingPageState createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  int _bottomNavCurrentIndex = 1; // Set index awal ke 1 untuk menampilkan HomePage

  late final List<Widget> _container;

  @override
  void initState() {
    super.initState();
    // Menyesuaikan daftar kontainer berdasarkan apakah pengguna adalah driver
    _container = widget.isDriver
        ? [DriverHomePage(), Akun()] // Halaman untuk driver
        : [RatingPage(), HomePage(), Akun()]; // Menambahkan RatingPage untuk pengguna biasa
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _container[_bottomNavCurrentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _bottomNavCurrentIndex,
        backgroundColor: Colors.transparent,
        color: Colors.green,
        buttonBackgroundColor: Colors.purple[900],
        height: 50,
        onTap: (index) {
          setState(() {
            _bottomNavCurrentIndex = index;
          });
        },
        items: <Widget>[
          Icon(Icons.star, color: Colors.white, size: 30), // Ikon Rating
          Icon(widget.isDriver ? Icons.delivery_dining : Icons.restaurant_menu, color: Colors.white, size: 30), // Ikon Menu
          Icon(Icons.person, color: Colors.white, size: 30), // Ikon Akun
        ],
      ),
    );
  }
}
