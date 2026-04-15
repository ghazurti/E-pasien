import 'package:equatable/equatable.dart';

class Booking extends Equatable {
  final String? tanggalBooking;
  final String? jamBooking;
  final String noRkmMedis;
  final String tanggalPeriksa;
  final String? kdDokter;
  final String? nmDokter;
  final String? kdPoli;
  final String? nmPoli;
  final String? noReg;
  final String? status;

  const Booking({
    this.tanggalBooking,
    this.jamBooking,
    required this.noRkmMedis,
    required this.tanggalPeriksa,
    this.kdDokter,
    this.nmDokter,
    this.kdPoli,
    this.nmPoli,
    this.noReg,
    this.status,
  });

  factory Booking.fromJson(Map<String, dynamic> json) {
    return Booking(
      tanggalBooking: json['tanggal_booking'],
      jamBooking: json['jam_booking'],
      noRkmMedis: json['no_rkm_medis'] ?? '',
      tanggalPeriksa: json['tanggal_periksa'] ?? '',
      kdDokter: json['kd_dokter'],
      nmDokter: json['nm_dokter'],
      kdPoli: json['kd_poli'],
      nmPoli: json['nm_poli'],
      noReg: json['no_reg'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'tanggal_booking': tanggalBooking,
      'jam_booking': jamBooking,
      'no_rkm_medis': noRkmMedis,
      'tanggal_periksa': tanggalPeriksa,
      'kd_dokter': kdDokter,
      'kd_poli': kdPoli,
      'no_reg': noReg,
      'status': status,
    };
  }

  @override
  List<Object?> get props => [
        tanggalBooking,
        jamBooking,
        noRkmMedis,
        tanggalPeriksa,
        kdDokter,
        kdPoli,
        noReg,
        status,
      ];
}

class CreateBookingRequest {
  final String noRkmMedis;
  final String tanggalPeriksa;
  final String kdDokter;
  final String kdPoli;
  final String kdPj;
  final String? keluhan;

  const CreateBookingRequest({
    required this.noRkmMedis,
    required this.tanggalPeriksa,
    required this.kdDokter,
    required this.kdPoli,
    required this.kdPj,
    this.keluhan,
  });

  Map<String, dynamic> toJson() {
    return {
      'no_rkm_medis': noRkmMedis,
      'tanggal_periksa': tanggalPeriksa,
      'kd_dokter': kdDokter,
      'kd_poli': kdPoli,
      'kd_pj': kdPj,
      'keluhan': keluhan,
    };
  }
}
