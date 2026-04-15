import 'package:equatable/equatable.dart';
import '../../models/booking.dart';

abstract class BookingState extends Equatable {
  const BookingState();

  @override
  List<Object?> get props => [];
}

class BookingInitial extends BookingState {
  const BookingInitial();
}

class BookingLoading extends BookingState {
  const BookingLoading();
}

class BookingSuccess extends BookingState {
  final String message;

  const BookingSuccess({required this.message});

  @override
  List<Object?> get props => [message];
}

class BookingHistoryLoaded extends BookingState {
  final List<Booking> bookingList;

  const BookingHistoryLoaded({required this.bookingList});

  @override
  List<Object?> get props => [bookingList];
}

class BookingError extends BookingState {
  final String message;

  const BookingError({required this.message});

  @override
  List<Object?> get props => [message];
}
