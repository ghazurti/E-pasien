import 'package:equatable/equatable.dart';
import 'package:flutter_epasien/models/jadwal.dart';

abstract class JadwalState extends Equatable {
  const JadwalState();

  @override
  List<Object?> get props => [];
}

class JadwalInitial extends JadwalState {
  const JadwalInitial();
}

class JadwalLoading extends JadwalState {
  const JadwalLoading();
}

class JadwalLoaded extends JadwalState {
  final List<Jadwal> jadwalList;
  final List<Jadwal> filteredJadwalList;
  final String? selectedHari;

  const JadwalLoaded({
    required this.jadwalList,
    required this.filteredJadwalList,
    this.selectedHari,
  });

  @override
  List<Object?> get props => [jadwalList, filteredJadwalList, selectedHari];
}

class JadwalError extends JadwalState {
  final String message;

  const JadwalError({required this.message});

  @override
  List<Object?> get props => [message];
}
