import 'package:equatable/equatable.dart';
import '../../models/radiology_result.dart';

abstract class RadiologyState extends Equatable {
  const RadiologyState();

  @override
  List<Object> get props => [];
}

class RadiologyInitial extends RadiologyState {}

class RadiologyLoading extends RadiologyState {}

class RadiologyLoaded extends RadiologyState {
  final List<RadiologyOrder> history;
  const RadiologyLoaded(this.history);

  @override
  List<Object> get props => [history];
}

class RadiologyDetailLoading extends RadiologyState {}

class RadiologyDetailLoaded extends RadiologyState {
  final List<RadiologyResult> results;
  const RadiologyDetailLoaded(this.results);

  @override
  List<Object> get props => [results];
}

class RadiologyError extends RadiologyState {
  final String message;
  const RadiologyError(this.message);

  @override
  List<Object> get props => [message];
}
