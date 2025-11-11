import 'package:equatable/equatable.dart';

abstract class ExperienceEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class FetchExperiences extends ExperienceEvent {}

class ToggleExperienceSelection extends ExperienceEvent {
  final int id;
  ToggleExperienceSelection(this.id);
  @override
  List<Object?> get props => [id];
}

class UpdateExperienceComment extends ExperienceEvent {
  final String comment;
  UpdateExperienceComment(this.comment);
  @override
  List<Object?> get props => [comment];
}
