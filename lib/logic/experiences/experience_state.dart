import 'package:equatable/equatable.dart';
import 'package:hotspot_onboarding/data/models/experience_model.dart';

abstract class ExperienceState extends Equatable {
  @override
  List<Object?> get props => [];
}

class ExperienceInitial extends ExperienceState {}

class ExperienceLoading extends ExperienceState {}

class ExperienceLoadSuccess extends ExperienceState {
  final List< Experience> experiences;
  final List<int> selectedIds;
  final String comment;

  ExperienceLoadSuccess({
    required this.experiences,
    this.selectedIds = const [],
    this.comment = '',
  });

  ExperienceLoadSuccess copyWith({
    List<Experience>? experiences,
    List<int>? selectedIds,
    String? comment,
  }) {
    return ExperienceLoadSuccess(
      experiences: experiences ?? this.experiences,
      selectedIds: selectedIds ?? this.selectedIds,
      comment: comment ?? this.comment,
    );
  }

  @override
  List<Object?> get props => [experiences, selectedIds, comment];
}

class ExperienceFailure extends ExperienceState {
  final String message;
  ExperienceFailure(this.message);
  @override
  List<Object?> get props => [message];
}
