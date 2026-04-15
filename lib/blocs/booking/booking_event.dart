import 'package:equatable/equatable.dart';
import 'package:flutter_epasien/models/booking.dart';

abstract class BookingEvent extends Equatable {
  const BookingEvent();

  @override
  List<Object?> get props => [];
}

class CreateBookingEvent extends BookingEvent {
  final CreateBookingRequest request;

  const CreateBookingEvent({required this.request});

  @override
  List<Object?> get props => [request];
}

class LoadBookingHistory extends BookingEvent {
  final String noRm;
  final bool isRefresh;

  const LoadBookingHistory({required this.noRm, this.isRefresh = false});

  @override
  List<Object?> get props => [noRm, isRefresh];
}

class CheckInBooking extends BookingEvent {
  final Booking booking;

  const CheckInBooking({required this.booking});

  @override
  List<Object?> get props => [booking];
}

class CancelBooking extends BookingEvent {
  final Booking booking;

  const CancelBooking({required this.booking});

  @override
  List<Object?> get props => [booking];
}
