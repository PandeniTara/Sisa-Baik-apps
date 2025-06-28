// enum JenisMakanan { makanan, sayur, buah, makananRingan, minuman }

// class Sumbangan {
//   final int? id;
//   final String nama;
//   final String jumlah;
//   final String catatan;
//   final String? imagePath;
//   final JenisMakanan jenisMakanan;
//   final double? latitude;
//   final double? longitude;
//   final int? userId; // relasi ke user.id

//   Sumbangan({
//     this.id,
//     required this.nama,
//     required this.jumlah,
//     required this.catatan,
//     this.imagePath,
//     required this.jenisMakanan,
//     this.latitude,
//     this.longitude,
//     this.userId,
//   });

//   Map<String, dynamic> toMap() {
//     return {
//       'id': id,
//       'nama': nama,
//       'jumlah': jumlah,
//       'catatan': catatan,
//       'imagePath': imagePath,
//       'jenisMakanan': jenisMakanan.name,
//       'latitude': latitude,
//       'longitude': longitude,
//       'userId': userId,
//     };
//   }

//   factory Sumbangan.fromMap(Map<String, dynamic> map) {
//     return Sumbangan(
//       id: map['id'],
//       nama: map['nama'],
//       jumlah: map['jumlah'],
//       catatan: map['catatan'],
//       imagePath: map['imagePath'],
//       jenisMakanan: JenisMakanan.values.firstWhere(
//         (e) => e.name == map['jenisMakanan'],
//         orElse: () => JenisMakanan.makanan,
//       ),
//       latitude: map['latitude'],
//       longitude: map['longitude'],
//       userId: map['userId'],
//     );
//   }
// }
