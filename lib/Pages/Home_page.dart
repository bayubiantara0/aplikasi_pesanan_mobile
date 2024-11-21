import 'package:flutter/material.dart';
import 'package:http/http.dart' as http; // Pastikan mengimpor http
import 'dart:convert'; // Pastikan mengimpor dart:convert
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wkwk/header.dart';
import 'Menu_card.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wkwk/config/app_constants.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> menuList = [];
  String selectedCategory = 'paketan';
  String idPelanggan = '';

  @override
  void initState() {
    super.initState();
    _loadIdPelanggan();
  }

  Future<void> _loadIdPelanggan() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      idPelanggan = prefs.getString('id_pelanggan') ?? '';
    });
    fetchMenuData();
  }

  Future<void> fetchMenuData() async {
    final String url =
        "${AppConstants.baseURL}/API/menus?kategori=$selectedCategory";
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data != null) {
          setState(() {
            menuList = List.from(data).map((menu) {
              return {
                'foto_menu_url': menu['foto_menu_url'].toString(),
                'nama_menu': menu['nama_menu'].toString(),
                'harga_menu': menu['harga_menu'].toString(),
                'deskripsi': menu['deskripsi'].toString(),
                'id_menu': menu['id_menu'].toString(),
              };
            }).toList();
          });
        } else {
          setState(() {
            menuList = [];
          });
        }
      } else {
        throw Exception('Gagal memuat menu');
      }
    } catch (e) {
      print(e);
      // Menangani kesalahan
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Gagal memuat menu, coba lagi.')),
      );
      setState(() {
        menuList = [];
      });
    }
  }

  void _changeCategory(String category) {
    setState(() {
      selectedCategory = category;
      fetchMenuData();
    });
  }

  void _refreshMenuList() {
    fetchMenuData(); // Refresh menu data
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CustomHeader(
              backgroundColor: Colors.green,
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  ElevatedButton(
                    onPressed: () => _changeCategory('paketan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == 'paketan'
                          ? Colors.purple
                          : Colors.grey,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Paketan',
                      style: GoogleFonts.poppins(
                        color: selectedCategory == 'paketan'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () => _changeCategory('prasmanan'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: selectedCategory == 'prasmanan'
                          ? Colors.purple
                          : Colors.grey,
                      padding:
                          EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: Text(
                      'Prasmanan',
                      style: GoogleFonts.poppins(
                        color: selectedCategory == 'prasmanan'
                            ? Colors.white
                            : Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: menuList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 2 / 3,
                ),
                itemBuilder: (BuildContext context, int index) {
                  var menu = menuList[index];
                  return MenuCard(
                    imageUrl: menu['foto_menu_url'],
                    title: menu['nama_menu'],
                    price: 'Rp ${menu['harga_menu']}',
                    description: menu['deskripsi'],
                    idMenu: menu['id_menu'],
                    idPelanggan: idPelanggan,
                    refreshMenuList: _refreshMenuList, // Pass refresh function
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
