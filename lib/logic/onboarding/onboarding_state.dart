import 'package:equatable/equatable.dart';

class OnboardingState extends Equatable {
  final String text;
  final bool isRecordingAudio;
  final String? audioPath;
  final bool isPlayingAudio;
  final bool hasAudio;
  final bool hasVideo;
  final String? videoPath;

  const OnboardingState({
    this.text = '',
    this.isRecordingAudio = false,
    this.audioPath,
    this.isPlayingAudio = false,
    this.hasAudio = false,
    this.hasVideo = false,
    this.videoPath,
  });

  OnboardingState copyWith({
    String? text,
    bool? isRecordingAudio,
    String? audioPath,
    bool? isPlayingAudio,
    bool? hasAudio,
    bool? hasVideo,
    String? videoPath,
  }) {
    return OnboardingState(
      text: text ?? this.text,
      isRecordingAudio: isRecordingAudio ?? this.isRecordingAudio,
      audioPath: audioPath ?? this.audioPath,
      isPlayingAudio: isPlayingAudio ?? this.isPlayingAudio,
      hasAudio: hasAudio ?? this.hasAudio,
      hasVideo: hasVideo ?? this.hasVideo,
      videoPath: videoPath ?? this.videoPath,
    );
  }

  @override
  List<Object?> get props => [text, isRecordingAudio, audioPath, isPlayingAudio, hasAudio, hasVideo, videoPath];
}
