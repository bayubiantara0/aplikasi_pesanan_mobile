import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wkwk/config/app_constants.dart';
import 'package:wkwk/header.dart';
import 'package:wkwk/Pages/Menu_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<dynamic> menuList = [];
  List<dynamic> filteredMenuList = [];
  String selectedCategory = 'paketan';
  String idPelanggan = '';
  String searchQuery = '';
  bool isAscending = true;
  bool isBestSellerSelected = false;

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
        "${AppConstants.baseURL}/API/getMenu.php?kategori=$selectedCategory";
    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data['data'] is List) {
          setState(() {
            menuList = List.from(data['data']);
            filteredMenuList = menuList;
            if (!isBestSellerSelected) {
              _applySorting();
            }
          });
        } else {
          setState(() {
            menuList = [];
            filteredMenuList = [];
          });
        }
      } else {
        throw Exception('Gagal memuat menu');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        menuList = [];
        filteredMenuList = [];
      });
    }
  }

  Future<void> fetchBestSellerMenu(String category) async {
    final String url =
        "${AppConstants.baseURL}/API/bestSeller.php?kategori=$selectedCategory";
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);

        if (data != null && data['data'] is List) {
          setState(() {
            menuList = List.from(data['data']);
            filteredMenuList = menuList;
            if (!isBestSellerSelected) {
              _applySorting();
            }
          });
        } else {
          setState(() {
            menuList = [];
            filteredMenuList = [];
          });
        }
      } else {
        throw Exception('Gagal memuat menu Best Seller');
      }
    } catch (e) {
      print("Error: $e");
      setState(() {
        menuList = [];
        filteredMenuList = [];
      });
    }
  }

  void _changeCategory(String category) {
    setState(() {
      selectedCategory = category;
      if (isBestSellerSelected) {
        fetchBestSellerMenu(category);
      } else {
        fetchMenuData();
      }
    });
  }

  void _toggleSortMenu() {
    setState(() {
      isAscending = !isAscending;
      _applySorting();
    });
  }

  void _applySorting() {
    setState(() {
      filteredMenuList.sort((a, b) {
        if (isAscending) {
          return double.parse(a['harga_menu'])
              .compareTo(double.parse(b['harga_menu']));
        } else {
          return double.parse(b['harga_menu'])
              .compareTo(double.parse(a['harga_menu']));
        }
      });
    });
  }

  void _filterMenuList(String query) {
    setState(() {
      searchQuery = query;
      filteredMenuList = menuList
          .where((menu) => menu['nama_menu']
              .toString()
              .toLowerCase()
              .contains(query.toLowerCase()))
          .toList();
    });
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
                    onPressed: () {
                      setState(() {
                        isBestSellerSelected = false;
                      });
                      _changeCategory('paketan');
                    },
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
                    onPressed: () {
                      setState(() {
                        isBestSellerSelected = false;
                      });
                      _changeCategory('prasmanan');
                    },
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
              padding: const EdgeInsets.symmetric(horizontal: 8.0),
              child: TextField(
                onChanged: (value) => _filterMenuList(value),
                decoration: InputDecoration(
                  labelText: 'Cari menu...',
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Wrap(
                spacing: 8.0,
                alignment: WrapAlignment.end,
                children: [
                  ChoiceChip(
                    label: Text('Best Seller'),
                    selected: isBestSellerSelected,
                    onSelected: (selected) {
                      setState(() {
                        isBestSellerSelected = selected;
                        if (isBestSellerSelected) {
                          fetchBestSellerMenu(selectedCategory);
                        } else {
                          fetchMenuData();
                        }
                      });
                    },
                  ),
                  ChoiceChip(
                    label: Text('Termurah'),
                    selected: isAscending && !isBestSellerSelected,
                    onSelected: (_) => _toggleSortMenu(),
                  ),
                  ChoiceChip(
                    label: Text('Termahal'),
                    selected: !isAscending && !isBestSellerSelected,
                    onSelected: (_) => _toggleSortMenu(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: filteredMenuList.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                  childAspectRatio: 2 / 3,
                ),
                itemBuilder: (BuildContext context, int index) {
                  var menu = filteredMenuList[index];

                  return MenuCard(
                    imageUrl: menu['foto_menu_path'] ?? '',
                    title: menu['nama_menu'] ?? 'Nama tidak tersedia',
                    price: 'Rp ${menu['harga_menu'] ?? '0'}',
                    description:
                        menu['deskripsi'] ?? 'Deskripsi tidak tersedia',
                    idMenu: menu['id_menu'] ?? '',
                    idPelanggan: idPelanggan,
                    refreshMenuList: fetchMenuData,
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
