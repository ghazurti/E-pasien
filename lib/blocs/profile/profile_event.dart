import 'package:equatable/equatable.dart';
import '../../models/pasien.dart';

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();

  @override
  List<Object?> get props => [];
}

class LoadProfile extends ProfileEvent {
  const LoadProfile();
}

class ChangePasswordEvent extends ProfileEvent {
  final ChangePasswordRequest request;

  const ChangePasswordEvent({required this.request});

  @override
  List<Object?> get props => [request];
}
