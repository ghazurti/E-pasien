class AntrianStatus {
  final String? noAntrian;
  final String? kdPoli;
  final String nmPoli;
  final String? kdDokter;
  final String nmDokter;
  final String? jamReg;
  final int antrianDidepan;
  final int totalPasien;
  final int estimasiMenit;

  AntrianStatus({
    required this.noAntrian,
    required this.kdPoli,
    required this.nmPoli,
    required this.kdDokter,
    required this.nmDokter,
    required this.jamReg,
    required this.antrianDidepan,
    required this.totalPasien,
    required this.estimasiMenit,
  });

  factory AntrianStatus.fromJson(Map<String, dynamic> json) => AntrianStatus(
        noAntrian: json['no_antrian']?.toString(),
        kdPoli: json['kd_poli']?.toString(),
        nmPoli: json['nm_poli']?.toString() ?? '',
        kdDokter: json['kd_dokter']?.toString(),
        nmDokter: json['nm_dokter']?.toString() ?? '',
        jamReg: json['jam_reg']?.toString(),
        antrianDidepan: (json['antrian_didepan'] as num?)?.toInt() ?? 0,
        totalPasien: (json['total_pasien'] as num?)?.toInt() ?? 0,
        estimasiMenit: (json['estimasi_menit'] as num?)?.toInt() ?? 0,
      );
}
