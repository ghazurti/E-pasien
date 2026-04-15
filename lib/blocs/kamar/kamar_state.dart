import 'package:equatable/equatable.dart';
import '../../models/kamar.dart';

abstract class KamarState extends Equatable {
  @override
  List<Object> get props => [];
}

class KamarInitial extends KamarState {}

class KamarLoading extends KamarState {}

class KamarLoaded extends KamarState {
  final List<Kamar> kamar;

  KamarLoaded(this.kamar);

  @override
  List<Object> get props => [kamar];
}

class KamarError extends KamarState {
  final String message;

  KamarError(this.message);

  @override
  List<Object> get props => [message];
}
