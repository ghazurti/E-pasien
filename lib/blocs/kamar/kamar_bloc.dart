import 'package:flutter_bloc/flutter_bloc.dart';
import 'kamar_event.dart';
import 'kamar_state.dart';
import '../../services/api_service.dart';

class KamarBloc extends Bloc<KamarEvent, KamarState> {
  final ApiService _apiService;

  KamarBloc({required ApiService apiService})
    : _apiService = apiService,
      super(KamarInitial()) {
    on<FetchKetersediaanKamar>(_onFetchKetersediaanKamar);
  }

  Future<void> _onFetchKetersediaanKamar(
    FetchKetersediaanKamar event,
    Emitter<KamarState> emit,
  ) async {
    emit(KamarLoading());
    try {
      final kamar = await _apiService.getKamar(refresh: event.isRefresh);
      emit(KamarLoaded(kamar));
    } catch (e) {
      emit(KamarError(e.toString()));
    }
  }
}
