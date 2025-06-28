enum JenisMakanan { makanan, sayur, buah, bahanPokok }

class Donasi {
  final int? id;
  final String nama;
  final String jumlah;
  final String catatan;
  final String? imagePath;
  final JenisMakanan jenisMakanan;
  final double? latitude;
  final double? longitude;
  final int userId;

  Donasi({
    this.id,
    required this.nama,
    required this.jumlah,
    required this.catatan,
    this.imagePath,
    required this.jenisMakanan,
    this.latitude,
    this.longitude,
    required this.userId,
  });

  factory Donasi.fromMap(Map<String, dynamic> map) {
    return Donasi(
      id: map['id'],
      nama: map['nama'],
      jumlah: map['jumlah'],
      catatan: map['catatan'],
      imagePath: map['imagePath'],
      jenisMakanan: JenisMakanan.values.firstWhere(
        (e) => e.name == map['jenisMakanan'],
        orElse: () => JenisMakanan.makanan,
      ),
      latitude: map['latitude'],
      longitude: map['longitude'],
      userId: map['userId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nama': nama,
      'jumlah': jumlah,
      'catatan': catatan,
      'imagePath': imagePath,
      'jenisMakanan': jenisMakanan.name,
      'latitude': latitude,
      'longitude': longitude,
      'userId': userId,
    };
  }
}
