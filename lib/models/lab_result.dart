class LabOrder {
  final String noRawat;
  final String tglPeriksa;
  final String jam;
  final String nmDokter;
  final String nmPoli;
  final String status;

  LabOrder({
    required this.noRawat,
    required this.tglPeriksa,
    required this.jam,
    required this.nmDokter,
    required this.nmPoli,
    required this.status,
  });

  factory LabOrder.fromJson(Map<String, dynamic> json) {
    return LabOrder(
      noRawat: json['no_rawat'] ?? '',
      tglPeriksa: json['tgl_periksa'] ?? '',
      jam: json['jam'] ?? '',
      nmDokter: json['nm_dokter'] ?? '',
      nmPoli: json['nm_poli'] ?? '',
      status: json['status'] ?? '',
    );
  }
}

class LabResult {
  final String noRawat;
  final String tglPeriksa;
  final String jam;
  final String nmPerawatan;
  final String nilai;
  final String nilaiRujukan;
  final String satuan;
  final String? keterangan;

  LabResult({
    required this.noRawat,
    required this.tglPeriksa,
    required this.jam,
    required this.nmPerawatan,
    required this.nilai,
    required this.nilaiRujukan,
    required this.satuan,
    this.keterangan,
  });

  factory LabResult.fromJson(Map<String, dynamic> json) {
    return LabResult(
      noRawat: json['no_rawat'] ?? '',
      tglPeriksa: json['tgl_periksa'] ?? '',
      jam: json['jam'] ?? '',
      nmPerawatan: json['nm_perawatan'] ?? '',
      nilai: json['nilai'] ?? '',
      nilaiRujukan: json['nilai_rujukan'] ?? '',
      satuan: json['satuan'] ?? '',
      keterangan: json['keterangan'],
    );
  }

  // Parse min value from nilai_rujukan
  double? get minNormal {
    if (nilaiRujukan.isEmpty) return null;
    if (nilaiRujukan.contains('-')) {
      final parts = nilaiRujukan.split('-');
      return double.tryParse(parts[0].trim());
    }
    if (nilaiRujukan.startsWith('<')) {
      return 0.0;
    }
    if (nilaiRujukan.startsWith('>')) {
      return double.tryParse(nilaiRujukan.substring(1).trim());
    }
    return null;
  }

  // Parse max value from nilai_rujukan
  double? get maxNormal {
    if (nilaiRujukan.isEmpty) return null;
    if (nilaiRujukan.contains('-')) {
      final parts = nilaiRujukan.split('-');
      return double.tryParse(parts[1].trim());
    }
    if (nilaiRujukan.startsWith('<')) {
      return double.tryParse(nilaiRujukan.substring(1).trim());
    }
    if (nilaiRujukan.startsWith('>')) {
      return double.infinity;
    }
    return null;
  }

  double? get numericValue => double.tryParse(nilai.trim());

  bool get isAbnormal {
    final val = numericValue;
    if (val == null) return false;

    final min = minNormal;
    final max = maxNormal;

    if (min != null && max != null) {
      return val < min || val > max;
    }
    return false;
  }

  // Status: 'high', 'low', or 'normal'
  String get status {
    final val = numericValue;
    if (val == null) return 'normal';

    final min = minNormal;
    final max = maxNormal;

    if (min != null && val < min) return 'low';
    if (max != null && val > max) return 'high';
    return 'normal';
  }

  // Progress percentage for visual bar (0.0 to 1.0)
  double get progressPercentage {
    final val = numericValue;
    final min = minNormal;
    final max = maxNormal;

    if (val == null || min == null || max == null) return 0.5;
    if (max == double.infinity) return 0.5;

    final range = max - min;
    if (range == 0) return 0.5;

    final position = (val - min) / range;
    return position.clamp(0.0, 1.0);
  }
}
