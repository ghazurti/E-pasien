import 'package:equatable/equatable.dart';

abstract class SuratKontrolEvent extends Equatable {
  const SuratKontrolEvent();

  @override
  List<Object?> get props => [];
}

class FetchSuratKontrol extends SuratKontrolEvent {
  final bool isRefresh;
  const FetchSuratKontrol({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class DownloadSuratKontrol extends SuratKontrolEvent {
  final String noSurat;

  const DownloadSuratKontrol(this.noSurat);

  @override
  List<Object?> get props => [noSurat];
}
