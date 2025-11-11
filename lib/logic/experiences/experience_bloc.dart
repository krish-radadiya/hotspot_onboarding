import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/experience_repository.dart';
import 'experience_event.dart';
import 'experience_state.dart';

class ExperienceBloc extends Bloc<ExperienceEvent, ExperienceState> {
  final ExperienceRepository repository;

  ExperienceBloc({required this.repository}) : super(ExperienceInitial()) {
    on<FetchExperiences>(_onFetchExperiences);
    on<ToggleExperienceSelection>(_onToggleSelection);
    on<UpdateExperienceComment>(_onUpdateComment);
  }

  Future<void> _onFetchExperiences(FetchExperiences event, Emitter<ExperienceState> emit) async {
    emit(ExperienceLoading());
    try {
      final list = await repository.fetchExperiences();
      // Sort by order (if required)
      list.sort((a, b) => a.order.compareTo(b.order));
      emit(ExperienceLoadSuccess(experiences: list));
    } catch (e) {
      emit(ExperienceFailure(e.toString()));
    }
  }

  void _onToggleSelection(ToggleExperienceSelection event, Emitter<ExperienceState> emit) {
    final current = state;
    if (current is ExperienceLoadSuccess) {
      final selected = List<int>.from(current.selectedIds);
      if (selected.contains(event.id)) {
        selected.remove(event.id);
      } else {
        selected.add(event.id);
      }
      emit(current.copyWith(selectedIds: selected));
    }
  }

  void _onUpdateComment(UpdateExperienceComment event, Emitter<ExperienceState> emit) {
    final current = state;
    if (current is ExperienceLoadSuccess) {
      emit(current.copyWith(comment: event.comment));
    }
  }
}
