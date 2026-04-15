import 'package:equatable/equatable.dart';

abstract class LabEvent extends Equatable {
  const LabEvent();

  @override
  List<Object?> get props => [];
}

class FetchLabOrders extends LabEvent {
  final bool isRefresh;
  const FetchLabOrders({this.isRefresh = false});

  @override
  List<Object?> get props => [isRefresh];
}

class FetchLabResults extends LabEvent {
  final String noRawat;

  const FetchLabResults({required this.noRawat});

  @override
  List<Object?> get props => [noRawat];
}
