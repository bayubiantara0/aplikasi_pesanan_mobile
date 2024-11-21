import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:wkwk/Pages/DriverHome_page.dart'; // Halaman khusus untuk driver

class DriverLandingPage extends StatefulWidget {
  @override
  _DriverLandingPageState createState() => _DriverLandingPageState();
}

class _DriverLandingPageState extends State<DriverLandingPage> {
  int _bottomNavCurrentIndex = 0;
  final List<Widget> _container = [DriverHomePage()]; // Hanya DriverHomePage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: Size.fromHeight(60.0), // Ukuran AppBar
        child: ClipRRect(
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(30.0), // Sudut melengkung kiri
            bottomRight: Radius.circular(30.0), // Sudut melengkung kanan
          ),
          child: AppBar(
            title: Text('Driver Home'),
            backgroundColor: Colors.orange, // Warna kuning oranye
            actions: [
              IconButton(
                icon: Icon(Icons.logout, color: Colors.purple[900]), // Tombol logout berwarna ungu
                onPressed: () {
                  // Logika untuk logout
                  Navigator.of(context).pushReplacementNamed('/login');
                },
              ),
            ],
          ),
        ),
      ),
      body: _container[_bottomNavCurrentIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _bottomNavCurrentIndex,
        backgroundColor: Colors.transparent,
        color: Colors.orange, // Warna kuning oranye
        buttonBackgroundColor: Colors.purple[900],
        height: 50,
        onTap: (index) {
          setState(() {
            _bottomNavCurrentIndex = index;
          });
        },
        items: <Widget>[
          Icon(Icons.delivery_dining, color: Colors.white, size: 30)
        ],
      ),
    );
  }
}