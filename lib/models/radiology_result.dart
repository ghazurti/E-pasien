class RadiologyOrder {
  final String noRawat;
  final DateTime tglPeriksa;
  final String jam;
  final String nmDokter;
  final String nmPerawatan;
  final String status;

  RadiologyOrder({
    required this.noRawat,
    required this.tglPeriksa,
    required this.jam,
    required this.nmDokter,
    required this.nmPerawatan,
    required this.status,
  });

  factory RadiologyOrder.fromJson(Map<String, dynamic> json) {
    return RadiologyOrder(
      noRawat: json['no_rawat'],
      tglPeriksa: DateTime.parse(json['tgl_periksa']),
      jam: json['jam'],
      nmDokter: json['nm_dokter'],
      nmPerawatan: json['nm_perawatan'],
      status: json['status'],
    );
  }
}

class RadiologyResult {
  final String noRawat;
  final DateTime tglPeriksa;
  final String jam;
  final String hasil;

  RadiologyResult({
    required this.noRawat,
    required this.tglPeriksa,
    required this.jam,
    required this.hasil,
  });

  factory RadiologyResult.fromJson(Map<String, dynamic> json) {
    return RadiologyResult(
      noRawat: json['no_rawat'],
      tglPeriksa: DateTime.parse(json['tgl_periksa']),
      jam: json['jam'],
      hasil: json['hasil'],
    );
  }
}
