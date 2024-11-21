import 'package:flutter/material.dart';

class CustomDetailHeader extends StatelessWidget
    implements PreferredSizeWidget {
  final Color? backgroundColor;

  const CustomDetailHeader({Key? key, this.backgroundColor}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor ??
            Colors.green[
                900], // Sesuaikan dengan warna background yang diinginkan
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(20),
          bottomRight: Radius.circular(20),
        ),
      ),
      padding: EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          IconButton(
            icon: Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          SizedBox(width: 10),
          Text(
            'Detail Menu',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  @override
  Size get preferredSize => Size.fromHeight(56);
}

class MenuDetail extends StatelessWidget {
  final String imageUrl;
  final String title;
  final String price;
  final String description;

  const MenuDetail({
    Key? key,
    required this.imageUrl,
    required this.title,
    required this.price,
    required this.description,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomDetailHeader(
        backgroundColor: Colors
            .green, // Sesuaikan dengan warna background header yang diinginkan
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Image.asset(
                imageUrl,
                fit: BoxFit.cover,
                height: 200,
                errorBuilder: (BuildContext context, Object exception,
                    StackTrace? stackTrace) {
                  return Center(child: Text('Image not found'));
                },
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 24.0,
              ),
            ),
            SizedBox(height: 8.0),
            Text(
              price,
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 20.0,
              ),
            ),
            SizedBox(height: 16.0),
            Text(
              description,
              style: TextStyle(
                fontSize: 16.0,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
