// data/models/pengaduan_model.dart

class Pengaduan {
  final int id;
  final String judul;
  final String deskripsi;
  final String status;
  final String? imageUrl;
  final DateTime createdAt;

  Pengaduan({
    required this.id,
    required this.judul,
    required this.deskripsi,
    required this.status,
    this.imageUrl,
    required this.createdAt,
  });

  /// Metode ini DIBUTUHKAN agar provider bisa update status secara lokal
  /// tanpa harus fetch ulang seluruh data dari server.
  Pengaduan copyWith({
    int? id,
    String? judul,
    String? deskripsi,
    String? status,
    String? imageUrl,
    DateTime? createdAt,
  }) {
    return Pengaduan(
      id: id ?? this.id,
      judul: judul ?? this.judul,
      deskripsi: deskripsi ?? this.deskripsi,
      status: status ?? this.status,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  factory Pengaduan.fromJson(Map<String, dynamic> json) {
    return Pengaduan(
      id: json['id'] ?? 0, // Tambahkan nilai default
      judul: json['judul'] ?? '', // Tambahkan nilai default jika null
      deskripsi: json['isi'] ?? '', // Tambahkan nilai default jika null (API returns 'isi' not 'deskripsi')
      status: json['status'] ?? 'menunggu', // Tambahkan nilai default jika null
      imageUrl: json['foto'], // API returns 'foto' not 'image_url'
      createdAt: json['tanggal'] != null 
          ? DateTime.parse(json['tanggal']) 
          : DateTime.now(), // Tambahkan nilai default jika null (API returns 'tanggal' not 'created_at')
    );
  }
}
