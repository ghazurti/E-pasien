import 'package:equatable/equatable.dart';
import '../../models/rekam_medis.dart';

abstract class RekamMedisState extends Equatable {
  const RekamMedisState();

  @override
  List<Object> get props => [];
}

class RekamMedisInitial extends RekamMedisState {}

class RekamMedisLoading extends RekamMedisState {}

class RekamMedisLoaded extends RekamMedisState {
  final List<RekamMedis> history;

  const RekamMedisLoaded(this.history);

  @override
  List<Object> get props => [history];
}

class RekamMedisError extends RekamMedisState {
  final String message;

  const RekamMedisError(this.message);

  @override
  List<Object> get props => [message];
}
