class SuratKontrol {
  final String noSurat;
  final String noSep;
  final DateTime tglSurat;
  final DateTime tglRencana;
  final String kdDokterBpjs;
  final String nmDokterBpjs;
  final String kdPoliBpjs;
  final String nmPoliBpjs;

  SuratKontrol({
    required this.noSurat,
    required this.noSep,
    required this.tglSurat,
    required this.tglRencana,
    required this.kdDokterBpjs,
    required this.nmDokterBpjs,
    required this.kdPoliBpjs,
    required this.nmPoliBpjs,
  });

  factory SuratKontrol.fromJson(Map<String, dynamic> json) {
    return SuratKontrol(
      noSurat: json['no_surat'],
      noSep: json['no_sep'],
      tglSurat: DateTime.parse(json['tgl_surat']),
      tglRencana: DateTime.parse(json['tgl_rencana']),
      kdDokterBpjs: json['kd_dokter_bpjs'],
      nmDokterBpjs: json['nm_dokter_bpjs'],
      kdPoliBpjs: json['kd_poli_bpjs'],
      nmPoliBpjs: json['nm_poli_bpjs'],
    );
  }
}
