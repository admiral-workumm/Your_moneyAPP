class Transaksi {
  final String id;
  final String jumlah;
  final String keterangan;
  final String jenisDompet;
  final String dompetId; // link to WalletItem.id
  final String tanggal;
  final String kategori;
  final String tipe; // 'pengeluaran' atau 'pemasukan'

  Transaksi({
    required this.id,
    required this.jumlah,
    required this.keterangan,
    required this.jenisDompet,
    required this.dompetId,
    required this.tanggal,
    required this.kategori,
    required this.tipe,
  });

  /// Convert Transaksi ke Map untuk disimpan di GetStorage
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'jumlah': jumlah,
      'keterangan': keterangan,
      'jenisDompet': jenisDompet,
      'dompetId': dompetId,
      'tanggal': tanggal,
      'kategori': kategori,
      'tipe': tipe,
    };
  }

  /// Create Transaksi dari Map
  factory Transaksi.fromMap(Map<String, dynamic> map) {
    return Transaksi(
      id: map['id'] ?? '',
      jumlah: map['jumlah'] ?? '0',
      keterangan: map['keterangan'] ?? '',
      jenisDompet: map['jenisDompet'] ?? '',
      dompetId: map['dompetId'] ?? '',
      tanggal: map['tanggal'] ?? '',
      kategori: map['kategori'] ?? '',
      tipe: map['tipe'] ?? 'pengeluaran',
    );
  }

  /// Copy with untuk update field tertentu
  Transaksi copyWith({
    String? id,
    String? jumlah,
    String? keterangan,
    String? jenisDompet,
    String? dompetId,
    String? tanggal,
    String? kategori,
    String? tipe,
  }) {
    return Transaksi(
      id: id ?? this.id,
      jumlah: jumlah ?? this.jumlah,
      keterangan: keterangan ?? this.keterangan,
      jenisDompet: jenisDompet ?? this.jenisDompet,
      dompetId: dompetId ?? this.dompetId,
      tanggal: tanggal ?? this.tanggal,
      kategori: kategori ?? this.kategori,
      tipe: tipe ?? this.tipe,
    );
  }
}
