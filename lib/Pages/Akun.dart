import 'package:flutter/material.dart';
import 'package:wkwk/User_model.dart';
import 'package:wkwk/header.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class Akun extends StatelessWidget {
  const Akun({Key? key}) : super(key: key);

  final String companyName = "Politeknik Negeri Indramayu";
  final String phoneNumber = "(0234) 5746464";
  final String address =
      "Jl. Lohbener Lama No.08, Legok, Kec. Lohbener, Kabupaten Indramayu, Jawa Barat 45252";
  final double latitude = -6.40816; // Ganti dengan latitude lokasi Anda
  final double longitude = 106.28144; // Ganti dengan longitude lokasi Anda

  Future<void> _logOut(BuildContext context) async {
    await UserModel.logOut();
    Navigator.of(context)
        .pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  void _launchMaps() async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    if (await canLaunch(url)) {
      await launch(url);
    }
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
                            subtitle: Text('Nama Perusahaan'),
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
                            onTap: _launchMaps,
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
                          height: 200,
                          child: GoogleMap(
                            initialCameraPosition: CameraPosition(
                              target: LatLng(latitude, longitude),
                              zoom: 15,
                            ),
                            markers: {
                              Marker(
                                markerId: MarkerId('company_location'),
                                position: LatLng(latitude, longitude),
                                infoWindow: InfoWindow(
                                  title: companyName,
                                  snippet: address,
                                ),
                              ),
                            },
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: ElevatedButton.icon(
                            icon: Icon(Icons.map),
                            onPressed: _launchMaps,
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
