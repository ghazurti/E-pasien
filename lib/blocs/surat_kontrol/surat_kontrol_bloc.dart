import 'package:flutter_bloc/flutter_bloc.dart';
import 'surat_kontrol_event.dart';
import 'surat_kontrol_state.dart';
import '../../services/surat_kontrol_service.dart';

class SuratKontrolBloc extends Bloc<SuratKontrolEvent, SuratKontrolState> {
  final SuratKontrolService _service = SuratKontrolService();

  SuratKontrolBloc() : super(const SuratKontrolInitial()) {
    on<FetchSuratKontrol>(_onFetchSuratKontrol);
    on<DownloadSuratKontrol>(_onDownloadSuratKontrol);
  }

  Future<void> _onFetchSuratKontrol(
    FetchSuratKontrol event,
    Emitter<SuratKontrolState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const SuratKontrolLoading());
    }
    try {
      final list = await _service.getSuratKontrolList(refresh: event.isRefresh);
      emit(SuratKontrolLoaded(list));
    } catch (e) {
      emit(SuratKontrolError(e.toString()));
    }
  }

  Future<void> _onDownloadSuratKontrol(
    DownloadSuratKontrol event,
    Emitter<SuratKontrolState> emit,
  ) async {
    emit(SuratKontrolDownloading(event.noSurat));
    try {
      final filePath = await _service.downloadSuratKontrolPdf(event.noSurat);
      emit(SuratKontrolDownloaded(filePath));
    } catch (e) {
      emit(SuratKontrolError(e.toString()));
    }
  }
}
