import 'package:equatable/equatable.dart';

class Pasien extends Equatable {
  final String noRkmMedis;
  final String nmPasien;
  final String? alamat;

  const Pasien({
    required this.noRkmMedis,
    required this.nmPasien,
    this.alamat,
  });

  factory Pasien.fromJson(Map<String, dynamic> json) {
    return Pasien(
      noRkmMedis: json['no_rkm_medis'] ?? '',
      nmPasien: json['nm_pasien'] ?? '',
      alamat: json['alamat'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'no_rkm_medis': noRkmMedis,
      'nm_pasien': nmPasien,
      'alamat': alamat,
    };
  }

  @override
  List<Object?> get props => [noRkmMedis, nmPasien, alamat];
}

class LoginRequest {
  final String noRm;
  final String password;

  const LoginRequest({
    required this.noRm,
    required this.password,
  });

  Map<String, dynamic> toJson() {
    return {
      'no_rm': noRm,
      'password': password,
    };
  }
}

class ChangePasswordRequest {
  final String noRm;
  final String oldPassword;
  final String newPassword;

  const ChangePasswordRequest({
    required this.noRm,
    required this.oldPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'no_rm': noRm,
      'old_password': oldPassword,
      'new_password': newPassword,
    };
  }
}
