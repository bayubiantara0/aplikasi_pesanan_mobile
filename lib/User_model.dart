import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class UserModel {
  String nama;
  String telepon;
  String email;
  String password;

  UserModel({
    required this.nama,
    required this.telepon,
    required this.email,
    required this.password,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      nama: json['nama'] ?? '',
      telepon: json['telepon'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
    );
  }

  static Future<UserModel?> loadUserData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? nama = prefs.getString('nama');
    String? telepon = prefs.getString('telepon');
    String? email = prefs.getString('email');
    String? password = prefs.getString('password');

    if (nama != null && telepon != null && email != null && password != null) {
      return UserModel(
        nama: nama,
        telepon: telepon,
        email: email,
        password: password,
      );
    }
    return null;
  }

  static Future<void> saveUserData(UserModel user) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString('nama', user.nama);
    await prefs.setString('telepon', user.telepon);
    await prefs.setString('email', user.email);
    await prefs.setString('password', user.password);
  }

  static Future<void> logOut() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    // Hapus data login
    prefs.remove('id_driver');
    prefs.remove('id_pelanggan');
  }

  static Future<Map<String, dynamic>?> checkLogin(
      String url, String telepon, String password) async {
    var params = "?telepon=$telepon&password=$password";
    var res = await http.get(Uri.parse(url + params));

    if (res.statusCode == 200) {
      return json.decode(res.body);
    }
    return null;
  }

  static Future<bool> checkDriverLogin(
      String url, String telepon, String password) async {
    var params =
        "?telepon=$telepon&password=$password"; // Sesuaikan dengan endpoint API untuk driver
    var res = await http.get(Uri.parse(url + params));

    if (res.statusCode == 200) {
      var jsonResponse = json.decode(res.body);
      // Simpan data driver jika login berhasil
      if (jsonResponse['status'] == 'success') {
        SharedPreferences prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isDriver', true); // Simpan status driver
        await prefs.setString('nama', jsonResponse['data']['nama']);
        await prefs.setString('telepon', telepon);
        await prefs.setString('email', jsonResponse['data']['email']);
        return true;
      }
    }
    return false;
  }
}
