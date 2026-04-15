import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/radiology_service.dart';
import 'radiology_event.dart';
import 'radiology_state.dart';

class RadiologyBloc extends Bloc<RadiologyEvent, RadiologyState> {
  final RadiologyService _service = RadiologyService();

  RadiologyBloc() : super(RadiologyInitial()) {
    on<LoadRadiologyHistory>((event, emit) async {
      emit(RadiologyLoading());
      try {
        final history = await _service.getRadiologyHistory(
          refresh: event.isRefresh,
        );
        emit(RadiologyLoaded(history));
      } catch (e) {
        emit(RadiologyError(e.toString()));
      }
    });

    on<LoadRadiologyDetail>((event, emit) async {
      print('🔄 BLoC: Loading radiology detail for ${event.noRawat}');
      emit(RadiologyDetailLoading());
      try {
        final results = await _service.getRadiologyDetail(event.noRawat);
        print(
          '🔄 BLoC: Emitting RadiologyDetailLoaded with ${results.length} results',
        );
        emit(RadiologyDetailLoaded(results));
      } catch (e) {
        print('🔄 BLoC: Emitting RadiologyError: $e');
        emit(RadiologyError(e.toString()));
      }
    });
  }
}
