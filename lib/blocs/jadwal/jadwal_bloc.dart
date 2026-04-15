import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_epasien/services/api_service.dart';
import 'package:flutter_epasien/blocs/jadwal/jadwal_event.dart';
import 'package:flutter_epasien/blocs/jadwal/jadwal_state.dart';

class JadwalBloc extends Bloc<JadwalEvent, JadwalState> {
  final ApiService _apiService;

  JadwalBloc({ApiService? apiService})
    : _apiService = apiService ?? ApiService(),
      super(const JadwalInitial()) {
    on<LoadJadwal>(_onLoadJadwal);
    on<FilterJadwalByHari>(_onFilterJadwalByHari);
  }

  Future<void> _onLoadJadwal(
    LoadJadwal event,
    Emitter<JadwalState> emit,
  ) async {
    // Only emit loading if not refreshing (pull-to-refresh has its own indicator)
    if (!event.isRefresh) {
      emit(const JadwalLoading());
    }

    try {
      final jadwalList = await _apiService.getJadwal(refresh: event.isRefresh);
      emit(
        JadwalLoaded(jadwalList: jadwalList, filteredJadwalList: jadwalList),
      );
    } catch (e) {
      emit(JadwalError(message: e.toString()));
    }
  }

  Future<void> _onFilterJadwalByHari(
    FilterJadwalByHari event,
    Emitter<JadwalState> emit,
  ) async {
    if (state is JadwalLoaded) {
      final currentState = state as JadwalLoaded;

      if (event.hari == null || event.hari!.isEmpty) {
        // Show all
        emit(
          JadwalLoaded(
            jadwalList: currentState.jadwalList,
            filteredJadwalList: currentState.jadwalList,
          ),
        );
      } else {
        // Filter by hari
        final filtered = currentState.jadwalList
            .where(
              (jadwal) =>
                  jadwal.hariKerja.toLowerCase() == event.hari!.toLowerCase(),
            )
            .toList();

        emit(
          JadwalLoaded(
            jadwalList: currentState.jadwalList,
            filteredJadwalList: filtered,
            selectedHari: event.hari,
          ),
        );
      }
    }
  }
}
