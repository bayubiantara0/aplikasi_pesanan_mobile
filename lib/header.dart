import 'package:flutter/material.dart';

class CustomHeader extends StatelessWidget {
  final Color? backgroundColor;

  const CustomHeader({Key? key, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.only(
        bottomLeft: Radius.circular(20),
        bottomRight: Radius.circular(20),
      ),
      child: Container(
        margin: EdgeInsets.only(top: 50),
        width: double.infinity,
        height: 56, // Mengubah tinggi header
        padding: EdgeInsets.symmetric(horizontal: 20),
        color: backgroundColor ??
            Colors.green[900], // Mengubah warna latar belakang
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Buya Galung', // Mengganti ikon dengan teks 'Buya Galung'
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            IconButton(
              onPressed: () {
                Navigator.pushNamed(
                    context, '/keranjang'); // Navigasi ke halaman keranjang
              },
              icon: Icon(
                Icons.shopping_cart_outlined,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
