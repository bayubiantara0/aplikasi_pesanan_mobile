import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:wkwk/User_model.dart';
import 'package:wkwk/header.dart';
import 'package:url_launcher/url_launcher.dart';

class Akun extends StatelessWidget {
  const Akun({Key? key}) : super(key: key);

  final String companyName = "Politeknik Negeri Indramayu";
  final String phoneNumber = "(0234) 5746464";
  final String address =
      "Jl. Lohbener Lama No.08, Legok, Kec. Lohbener, Kabupaten Indramayu, Jawa Barat 45252";

  Future<void> _logOut(BuildContext context) async {
    await UserModel.logOut();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  void _launchPhone() async {
    final url = 'tel:$phoneNumber';
    if (await canLaunch(url)) {
      await launch(url);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            CustomHeader(backgroundColor: Colors.green),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        children: [
                          ElevatedButton.icon(
                            icon: Icon(Icons.history),
                            onPressed: () {
                              Navigator.pushNamed(context, '/riwayatPesan');
                            },
                            label: Text('Riwayat Pesan'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                          SizedBox(height: 10),
                          ElevatedButton.icon(
                            icon: Icon(Icons.edit),
                            onPressed: () {
                              Navigator.pushNamed(context, '/editProfil');
                            },
                            label: Text('Edit Profile'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Hubungi Kami',
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge
                                ?.copyWith(
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          SizedBox(height: 16),
                          ListTile(
                            leading: Icon(Icons.business, color: Colors.blue),
                            title: Text(companyName),
                            subtitle: Text('Nama Kampus'),
                          ),
                          ListTile(
                            leading: Icon(Icons.phone, color: Colors.green),
                            title: Text(phoneNumber),
                            subtitle: Text('Telepon'),
                            onTap: _launchPhone,
                          ),
                          ListTile(
                            leading: Icon(Icons.location_on, color: Colors.red),
                            title: Text(address),
                            subtitle: Text('Alamat'),
                          ),
                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Card(
                    elevation: 4,
                    child: Column(
                      children: [
                        Container(
                          height: 250,
                          child: InAppWebView(
                            initialUrlRequest: URLRequest(
                              url: Uri.parse(
                                'https://www.google.com/maps/embed?pb=!1m18!1m12!1m3!1d3964.888132250622!2d108.2788767758701!3d-6.408409362676406!2m3!1f0!2f0!3f0!3m2!1i1024!2i768!4f13.1!3m3!1m2!1s0x2e6eb87d1fcaf97d%3A0x4fc15b3c8407ada4!2sPoliteknik%20Negeri%20Indramayu!5e0!3m2!1sid!2sid!4v1732261960329!5m2!1sid!2sid',
                              ),
                            ),
                            onLoadError: (controller, url, code, message) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(content: Text("Error loading map!")),
                              );
                            },
                            initialOptions: InAppWebViewGroupOptions(
                              crossPlatform: InAppWebViewOptions(
                                javaScriptEnabled: true,
                                supportZoom: false,
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.map),
                            onPressed: () async {
                              const url =
                                  'https://www.google.com/maps/search/?api=1&query=-6.408409362676406,108.2788767758701';
                              if (await canLaunch(url)) {
                                await launch(url);
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Could not launch maps"),
                                  ),
                                );
                              }
                            },
                            label: Text('Buka di Google Maps'),
                            style: ElevatedButton.styleFrom(
                              padding: EdgeInsets.symmetric(
                                  vertical: 12, horizontal: 24),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  ElevatedButton.icon(
                    icon: Icon(Icons.logout),
                    onPressed: () => _logOut(context),
                    label: Text('Log Out'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding:
                          EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
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
