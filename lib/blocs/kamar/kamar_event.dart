import 'package:equatable/equatable.dart';

abstract class KamarEvent extends Equatable {
  @override
  List<Object> get props => [];
}

class FetchKetersediaanKamar extends KamarEvent {
  final bool isRefresh;

  FetchKetersediaanKamar({this.isRefresh = false});

  @override
  List<Object> get props => [isRefresh];
}
