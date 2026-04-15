import 'package:equatable/equatable.dart';

abstract class RekamMedisEvent extends Equatable {
  const RekamMedisEvent();

  @override
  List<Object> get props => [];
}

class LoadRekamMedisHistory extends RekamMedisEvent {
  final bool isRefresh;
  const LoadRekamMedisHistory({this.isRefresh = false});

  @override
  List<Object> get props => [isRefresh];
}
