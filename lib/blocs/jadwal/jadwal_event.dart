import 'package:equatable/equatable.dart';

abstract class JadwalEvent extends Equatable {
  const JadwalEvent();

  @override
  List<Object?> get props => [];
}

class LoadJadwal extends JadwalEvent {
  final bool isRefresh;
  const LoadJadwal({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class FilterJadwalByHari extends JadwalEvent {
  final String? hari;

  const FilterJadwalByHari({this.hari});

  @override
  List<Object?> get props => [hari];
}
