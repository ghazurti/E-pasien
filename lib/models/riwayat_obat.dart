class ObatItem {
  final String namaObat;
  final double jml;
  final String aturanPakai;

  ObatItem({
    required this.namaObat,
    required this.jml,
    required this.aturanPakai,
  });

  factory ObatItem.fromJson(Map<String, dynamic> json) => ObatItem(
        namaObat: json['nama_obat']?.toString().trim() ?? '',
        jml: (json['jml'] as num?)?.toDouble() ?? 0,
        aturanPakai: json['aturan_pakai']?.toString().trim() ?? '',
      );
}

class Resep {
  final String noResep;
  final String? tglPeresepan;
  final String nmDokter;
  final List<ObatItem> obat;

  Resep({
    required this.noResep,
    required this.tglPeresepan,
    required this.nmDokter,
    required this.obat,
  });

  factory Resep.fromJson(Map<String, dynamic> json) => Resep(
        noResep: json['no_resep']?.toString() ?? '',
        tglPeresepan: json['tgl_peresepan']?.toString(),
        nmDokter: json['nm_dokter']?.toString() ?? '',
        obat: (json['obat'] as List<dynamic>? ?? [])
            .map((o) => ObatItem.fromJson(o as Map<String, dynamic>))
            .toList(),
      );
}
