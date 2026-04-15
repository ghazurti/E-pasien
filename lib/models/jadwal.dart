import 'package:equatable/equatable.dart';

class Jadwal extends Equatable {
  final String kdDokter;
  final String nmDokter;
  final String kdPoli;
  final String nmPoli;
  final String hariKerja;
  final String jamMulai;
  final String jamSelesai;

  const Jadwal({
    required this.kdDokter,
    required this.nmDokter,
    required this.kdPoli,
    required this.nmPoli,
    required this.hariKerja,
    required this.jamMulai,
    required this.jamSelesai,
  });

  factory Jadwal.fromJson(Map<String, dynamic> json) {
    return Jadwal(
      kdDokter: json['kd_dokter'] ?? '',
      nmDokter: json['nm_dokter'] ?? '',
      kdPoli: json['kd_poli'] ?? '',
      nmPoli: json['nm_poli'] ?? '',
      hariKerja: json['hari_kerja'] ?? '',
      jamMulai: json['jam_mulai'] ?? '',
      jamSelesai: json['jam_selesai'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'kd_dokter': kdDokter,
      'nm_dokter': nmDokter,
      'kd_poli': kdPoli,
      'nm_poli': nmPoli,
      'hari_kerja': hariKerja,
      'jam_mulai': jamMulai,
      'jam_selesai': jamSelesai,
    };
  }

  @override
  List<Object?> get props => [
        kdDokter,
        nmDokter,
        kdPoli,
        nmPoli,
        hariKerja,
        jamMulai,
        jamSelesai,
      ];
}
