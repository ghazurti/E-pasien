import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/rekam_medis_service.dart';
import 'rekam_medis_event.dart';
import 'rekam_medis_state.dart';

class RekamMedisBloc extends Bloc<RekamMedisEvent, RekamMedisState> {
  final RekamMedisService rekamMedisService;

  RekamMedisBloc({required this.rekamMedisService})
    : super(RekamMedisInitial()) {
    on<LoadRekamMedisHistory>((event, emit) async {
      if (!event.isRefresh) {
        emit(RekamMedisLoading());
      }
      try {
        final history = await rekamMedisService.getRekamMedisHistory(
          refresh: event.isRefresh,
        );
        emit(RekamMedisLoaded(history));
      } catch (e) {
        emit(RekamMedisError(e.toString()));
      }
    });
  }
}
