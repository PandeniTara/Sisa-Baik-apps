class User {
  final int? id;
  final String nama;
  final String username;
  final String password;
  final String? noHp;
  final String? foto;
  final int totalSumbangan;
  final int totalPoin;

  User({
    this.id,
    required this.nama,
    required this.username,
    required this.password,
    this.noHp,
    this.foto,
    this.totalSumbangan = 0,
    this.totalPoin = 0,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'nama': nama,
    'username': username,
    'password': password,
    'noHp': noHp,
    'foto': foto,
    'totalSumbangan': totalSumbangan,
    'totalPoin': totalPoin,
  };

  factory User.fromMap(Map<String, dynamic> map) => User(
    id: map['id'],
    nama: map['nama'],
    username: map['username'],
    password: map['password'],
    noHp: map['noHp'],
    foto: map['foto'],
    totalSumbangan: map['totalSumbangan'],
    totalPoin: map['totalPoin'],
  );

  User copyWith({
    int? id,
    String? nama,
    String? username,
    String? password,
    String? noHp,
    String? foto,
    int? totalSumbangan,
    int? totalPoin,
  }) {
    return User(
      id: id ?? this.id,
      nama: nama ?? this.nama,
      username: username ?? this.username,
      password: password ?? this.password,
      noHp: noHp ?? this.noHp,
      foto: foto ?? this.foto,
      totalSumbangan: totalSumbangan ?? this.totalSumbangan,
      totalPoin: totalPoin ?? this.totalPoin,
    );
  }
}
