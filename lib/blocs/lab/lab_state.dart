import 'package:equatable/equatable.dart';
import '../../models/lab_result.dart';

abstract class LabState extends Equatable {
  const LabState();

  @override
  List<Object?> get props => [];
}

class LabInitial extends LabState {}

class LabLoading extends LabState {}

class LabOrdersLoaded extends LabState {
  final List<LabOrder> orders;

  const LabOrdersLoaded({required this.orders});

  @override
  List<Object?> get props => [orders];
}

class LabResultsLoaded extends LabState {
  final List<LabResult> results;
  final String noRawat;

  const LabResultsLoaded({required this.results, required this.noRawat});

  @override
  List<Object?> get props => [results, noRawat];
}

class LabError extends LabState {
  final String message;

  const LabError({required this.message});

  @override
  List<Object?> get props => [message];
}
