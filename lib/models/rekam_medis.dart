class RekamMedis {
  final String noRawat;
  final DateTime tglRegistrasi;
  final String nmDokter;
  final String nmPoli;
  final String? suhuTubuh;
  final String? tensi;
  final String? nadi;
  final String? respirasi;
  final String? tinggi;
  final String? berat;
  final String? keluhan;
  final String? pemeriksaan;
  final String? penilaian;
  final String? rtl;
  final String? instruksi;

  RekamMedis({
    required this.noRawat,
    required this.tglRegistrasi,
    required this.nmDokter,
    required this.nmPoli,
    this.suhuTubuh,
    this.tensi,
    this.nadi,
    this.respirasi,
    this.tinggi,
    this.berat,
    this.keluhan,
    this.pemeriksaan,
    this.penilaian,
    this.rtl,
    this.instruksi,
  });

  factory RekamMedis.fromJson(Map<String, dynamic> json) {
    return RekamMedis(
      noRawat: json['no_rawat'],
      tglRegistrasi: DateTime.parse(json['tgl_registrasi']),
      nmDokter: json['nm_dokter'],
      nmPoli: json['nm_poli'],
      suhuTubuh: json['suhu_tubuh'],
      tensi: json['tensi'],
      nadi: json['nadi'],
      respirasi: json['respirasi'],
      tinggi: json['tinggi'],
      berat: json['berat'],
      keluhan: json['keluhan'],
      pemeriksaan: json['pemeriksaan'],
      penilaian: json['penilaian'],
      rtl: json['rtl'],
      instruksi: json['instruksi'],
    );
  }
}
