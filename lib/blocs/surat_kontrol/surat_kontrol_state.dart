import 'package:equatable/equatable.dart';
import '../../models/surat_kontrol.dart';

abstract class SuratKontrolState extends Equatable {
  const SuratKontrolState();

  @override
  List<Object?> get props => [];
}

class SuratKontrolInitial extends SuratKontrolState {
  const SuratKontrolInitial();
}

class SuratKontrolLoading extends SuratKontrolState {
  const SuratKontrolLoading();
}

class SuratKontrolLoaded extends SuratKontrolState {
  final List<SuratKontrol> suratKontrolList;

  const SuratKontrolLoaded(this.suratKontrolList);

  @override
  List<Object?> get props => [suratKontrolList];
}

class SuratKontrolError extends SuratKontrolState {
  final String message;

  const SuratKontrolError(this.message);

  @override
  List<Object?> get props => [message];
}

class SuratKontrolDownloading extends SuratKontrolState {
  final String noSurat;

  const SuratKontrolDownloading(this.noSurat);

  @override
  List<Object?> get props => [noSurat];
}

class SuratKontrolDownloaded extends SuratKontrolState {
  final String filePath;

  const SuratKontrolDownloaded(this.filePath);

  @override
  List<Object?> get props => [filePath];
}
