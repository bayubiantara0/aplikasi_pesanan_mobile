import 'package:flutter/material.dart';
import 'package:wkwk/config/app_constants.dart';

class DetailPesananPage extends StatelessWidget {
  final Map<String, dynamic> transaksi; // Data transaksi sebagai Map
  final int nomorPesanan; // Menyimpan nomor pesanan

  DetailPesananPage(
      {required this.transaksi,
      required this.nomorPesanan}); // Constructor sesuai

  @override
  Widget build(BuildContext context) {
    // Pastikan total_harga dikonversi ke double
    final double totalHarga =
        double.tryParse(transaksi['total_harga']?.toString() ?? '0') ?? 0;

    // Hitung jumlah bayar (50% jika DP, atau total jika LUNAS)
    final double bayar =
        transaksi['metode_pembayaran'] == 'LUNAS' ? totalHarga : totalHarga / 2;

    // Base URL untuk gambar menu
    final String baseUrl = "${AppConstants.baseURL}/API/getDetailPesanan.php";

    return Scaffold(
      appBar: AppBar(
        title: Text('Detail Pesanan $nomorPesanan'), // Tampilkan nomor pesanan
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Pesanan $nomorPesanan",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold)), // Judul dengan nomor pesanan
            SizedBox(height: 10),
            Text("Status: ${transaksi['status_transaksi']}",
                style: TextStyle(fontSize: 18)),
            Text("Metode Pembayaran: ${transaksi['metode_pembayaran']}",
                style: TextStyle(fontSize: 18)),
            Text("Tanggal Pesanan: ${transaksi['tanggal_pesan']}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Alamat: ${transaksi['alamat']}",
                style: TextStyle(fontSize: 18)),
            SizedBox(height: 10),
            Text("Detail Menu:", style: TextStyle(fontSize: 18)),
            if (transaksi['detail_menu'] != null &&
                (transaksi['detail_menu'] as List).isNotEmpty)
              Column(
                children: transaksi['detail_menu'].map<Widget>((menu) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8.0),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Menampilkan gambar menu
                        if (menu['foto_menu_path'] != null)
                          Image.network(
                            '$baseUrl${menu['foto_menu_path']}',
                            width: 60, // Atur ukuran gambar sesuai kebutuhan
                            height: 60,
                            fit: BoxFit.cover,
                          ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            "- ${menu['nama_menu'] ?? 'Tidak tersedia'}: Rp.${menu['harga_total']} (${menu['quantity']}x)",
                            style: TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              )
            else
              Text("Detail menu tidak tersedia",
                  style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text(
              "Bayar: Rp.${bayar.toStringAsFixed(2)}", // Tampilkan hasil bayar
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold), // Bold untuk "Bayar"
            ),
            SizedBox(height: 10),
            Text(
              "Total Harga: Rp.${totalHarga.toStringAsFixed(2)}", // Tampilkan total harga
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold), // Bold untuk "Total Harga"
            ),
            SizedBox(height: 10),
            Text(
              "Tanggal Transaksi: ${transaksi['tanggal_pesan']}", // Menampilkan tanggal transaksi
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
