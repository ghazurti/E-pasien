import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/lab_service.dart';
import 'lab_event.dart';
import 'lab_state.dart';

class LabBloc extends Bloc<LabEvent, LabState> {
  final LabService _labService = LabService();

  LabBloc() : super(LabInitial()) {
    on<FetchLabOrders>(_onFetchLabOrders);
    on<FetchLabResults>(_onFetchLabResults);
  }

  Future<void> _onFetchLabOrders(
    FetchLabOrders event,
    Emitter<LabState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(LabLoading());
    }
    try {
      final orders = await _labService.getLabOrders(refresh: event.isRefresh);
      emit(LabOrdersLoaded(orders: orders));
    } catch (e) {
      emit(LabError(message: e.toString()));
    }
  }

  Future<void> _onFetchLabResults(
    FetchLabResults event,
    Emitter<LabState> emit,
  ) async {
    emit(LabLoading());
    try {
      final results = await _labService.getLabResults(event.noRawat);
      emit(LabResultsLoaded(results: results, noRawat: event.noRawat));
    } catch (e) {
      emit(LabError(message: e.toString()));
    }
  }
}
