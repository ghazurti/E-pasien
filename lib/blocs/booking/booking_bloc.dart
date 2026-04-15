import 'package:flutter_bloc/flutter_bloc.dart';
import '../../services/api_service.dart';
import 'booking_event.dart';
import 'booking_state.dart';

class BookingBloc extends Bloc<BookingEvent, BookingState> {
  final ApiService _apiService;

  BookingBloc({ApiService? apiService})
    : _apiService = apiService ?? ApiService(),
      super(const BookingInitial()) {
    on<CreateBookingEvent>(_onCreateBooking);
    on<LoadBookingHistory>(_onLoadBookingHistory);
    on<CheckInBooking>(_onCheckInBooking);
    on<CancelBooking>(_onCancelBooking);
  }

  Future<void> _onCreateBooking(
    CreateBookingEvent event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    try {
      final result = await _apiService.createBooking(event.request);

      if (result['success'] == true) {
        emit(BookingSuccess(message: result['message'] as String));
      } else {
        emit(BookingError(message: result['message'] as String));
      }
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  Future<void> _onLoadBookingHistory(
    LoadBookingHistory event,
    Emitter<BookingState> emit,
  ) async {
    if (!event.isRefresh) {
      emit(const BookingLoading());
    }

    try {
      final bookingList = await _apiService.getBookingHistory(
        event.noRm,
        refresh: event.isRefresh,
      );
      emit(BookingHistoryLoaded(bookingList: bookingList));
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  Future<void> _onCheckInBooking(
    CheckInBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    try {
      final result = await _apiService.checkInBooking(event.booking);

      if (result['success'] == true) {
        emit(BookingSuccess(message: result['message'] as String));
        // Reload history after check-in
        add(LoadBookingHistory(noRm: event.booking.noRkmMedis));
      } else {
        emit(BookingError(message: result['message'] as String));
      }
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }

  Future<void> _onCancelBooking(
    CancelBooking event,
    Emitter<BookingState> emit,
  ) async {
    emit(const BookingLoading());

    try {
      final result = await _apiService.cancelBooking(event.booking);

      if (result['success'] == true) {
        emit(BookingSuccess(message: result['message'] as String));
        // Reload history after cancellation
        add(LoadBookingHistory(noRm: event.booking.noRkmMedis));
      } else {
        emit(BookingError(message: result['message'] as String));
      }
    } catch (e) {
      emit(BookingError(message: e.toString()));
    }
  }
}
