import 'package:flutter/material.dart';
import 'package:wkwk/User_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wkwk/pages/Register.dart';
import 'package:wkwk/config/app_constants.dart';

Future<void> saveUserId(String userId, bool isDriver) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  if (isDriver) {
    prefs.setString('id_driver', userId);
  } else {
    prefs.setString('id_pelanggan', userId);
  }
}

class LoginPage extends StatefulWidget {
  LoginPage({Key? key, this.title}) : super(key: key);
  final String? title;

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _teleponController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;
  // final String _sUrlPelanggan = "http://10.0.164.244/Proyek%203/API/Pelanggan.php";
  final String _sUrlPelanggan = "${AppConstants.baseURL}/Pelanggan.php";
  // final String _sUrlDriver = "http://10.0.164.244/Proyek%203/API/Driver.php";
  final String _sUrlDriver = "${AppConstants.baseURL}/Driver.php";

  @override
  void dispose() {
    _teleponController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _cekLogin() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Cek login sebagai pelanggan
      var responsePelanggan = await UserModel.checkLogin(
          _sUrlPelanggan, _teleponController.text, _passwordController.text);

      if (responsePelanggan != null &&
          responsePelanggan['response_status'] == "OK") {
        var userData = responsePelanggan['data'][0];

        // Simpan id_pelanggan ke SharedPreferences
        await UserModel.saveUserData(UserModel.fromJson(userData));
        await saveUserId(userData['id_pelanggan'], false);

        // Arahkan ke halaman pelanggan
        Navigator.of(context).pushNamedAndRemoveUntil(
            '/landing', (Route<dynamic> route) => false);
      } else {
        // Jika login pelanggan gagal, cek login sebagai driver
        var responseDriver = await UserModel.checkLogin(
            _sUrlDriver, _teleponController.text, _passwordController.text);

        if (responseDriver != null &&
            responseDriver['response_status'] == "OK") {
          var driverData = responseDriver['data'][0];

          // Simpan id_driver ke SharedPreferences
          await UserModel.saveUserData(UserModel.fromJson(driverData));
          await saveUserId(driverData['id_driver'], true);

          // Arahkan ke halaman driver
          Navigator.of(context).pushNamedAndRemoveUntil(
              '/driverLanding', (Route<dynamic> route) => false);
        } else {
          setState(() {
            _isLoading = false;
          });
          _showAlertDialog(
              context, responsePelanggan?['response_message'] ?? 'Login gagal');
        }
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      _showAlertDialog(context, 'Login gagal: $e');
    }
  }

  void _showAlertDialog(BuildContext context, String err) {
    Widget okButton = TextButton(
      child: Text("OK"),
      onPressed: () => Navigator.pop(context),
    );
    AlertDialog alert = AlertDialog(
      title: Text("Error"),
      content: Text(err),
      actions: [
        okButton,
      ],
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return alert;
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Container(
          height: MediaQuery.of(context).size.height,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Stack(
            children: <Widget>[
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  SizedBox(height: 50), // Untuk spasi di atas
                  Center(
                    child: Image.asset(
                      "assets/images/Logo.png",
                      height: 120.0,
                      width: 700.0,
                    ),
                  ),
                  if (_isLoading) CircularProgressIndicator(),
                  SizedBox(height: 20),
                  _buildTextField("Telepon", _teleponController, false),
                  SizedBox(height: 10),
                  _buildTextField("Password", _passwordController, true),
                  SizedBox(height: 20),
                  _buildLoginButton(),
                  SizedBox(height: 20),
                  _buildRegisterLink(),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, bool obscureText) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          label,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        SizedBox(height: 10),
        TextField(
          controller: controller,
          style: TextStyle(fontSize: 18),
          obscureText: obscureText,
          decoration: InputDecoration(
            border: InputBorder.none,
            fillColor: Color(0xfff3f3f4),
            filled: true,
          ),
        ),
      ],
    );
  }

  Widget _buildLoginButton() {
    return InkWell(
      child: Container(
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(vertical: 15),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.all(Radius.circular(5)),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: Colors.grey.shade200,
              offset: Offset(2, 4),
              blurRadius: 5,
              spreadRadius: 2,
            ),
          ],
          gradient: LinearGradient(
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
            colors: [
              Colors.green[600]!,
              Colors.green[600]!,
            ],
          ),
        ),
        child: Text(
          'Login',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
      onTap: _cekLogin,
    );
  }

  Widget _buildRegisterLink() {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => RegisterPage()),
        );
      },
      child: Text(
        "Tidak Punya Akun? Register",
        style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
      ),
    );
  }
}
