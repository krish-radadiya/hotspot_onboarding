import 'package:equatable/equatable.dart';

abstract class OnboardingEvent extends Equatable {
  @override
  List<Object?> get props => [];
}

class UpdateTextAnswer extends OnboardingEvent {
  final String text;

  UpdateTextAnswer(this.text);

  @override
  List<Object?> get props => [text];
}

// Audio
class StartAudioRecording extends OnboardingEvent {}

class StopAudioRecording extends OnboardingEvent {}

class DeleteAudio extends OnboardingEvent {}

class PlayAudio extends OnboardingEvent {}

class StopAudioPlayback extends OnboardingEvent {}

// Video
class StartVideoRecording extends OnboardingEvent {}

class FinishVideoRecording extends OnboardingEvent {
  final String path;

  FinishVideoRecording(this.path);
}

class DeleteVideo extends OnboardingEvent {}
