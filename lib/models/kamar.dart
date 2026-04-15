class Kamar {
  final String nmBangsal;
  final String kelas;
  final int total;
  final int kosong;
  final int isi;

  Kamar({
    required this.nmBangsal,
    required this.kelas,
    required this.total,
    required this.kosong,
    required this.isi,
  });

  factory Kamar.fromJson(Map<String, dynamic> json) {
    return Kamar(
      nmBangsal: json['nm_bangsal'] ?? '',
      kelas: json['kelas'] ?? '',
      total: json['total'] ?? 0,
      kosong: json['kosong'] ?? 0,
      isi: json['isi'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'nm_bangsal': nmBangsal,
      'kelas': kelas,
      'total': total,
      'kosong': kosong,
      'isi': isi,
    };
  }
}
