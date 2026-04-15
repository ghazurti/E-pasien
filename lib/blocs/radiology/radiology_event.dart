import 'package:equatable/equatable.dart';

abstract class RadiologyEvent extends Equatable {
  const RadiologyEvent();

  @override
  List<Object> get props => [];
}

class LoadRadiologyHistory extends RadiologyEvent {
  final bool isRefresh;
  const LoadRadiologyHistory({this.isRefresh = false});

  @override
  List<Object> get props => [isRefresh];
}

class LoadRadiologyDetail extends RadiologyEvent {
  final String noRawat;
  const LoadRadiologyDetail(this.noRawat);

  @override
  List<Object> get props => [noRawat];
}
