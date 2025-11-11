// import 'dart:io';
// import 'package:equatable/equatable.dart';
//
// class OnboardingState extends Equatable {
//   final String answer;
//   final File? audioFile;
//   final File? videoFile;
//   final bool isRecordingAudio;
//   final bool isRecordingVideo;
//
//   const OnboardingState({
//     this.answer = '',
//     this.audioFile,
//     this.videoFile,
//     this.isRecordingAudio = false,
//     this.isRecordingVideo = false,
//   });
//
//   OnboardingState copyWith({
//     String? answer,
//     File? audioFile,
//     File? videoFile,
//     bool? isRecordingAudio,
//     bool? isRecordingVideo,
//   }) {
//     return OnboardingState(
//       answer: answer ?? this.answer,
//       audioFile: audioFile,
//       videoFile: videoFile,
//       isRecordingAudio: isRecordingAudio ?? this.isRecordingAudio,
//       isRecordingVideo: isRecordingVideo ?? this.isRecordingVideo,
//     );
//   }
//
//   @override
//   List<Object?> get props => [answer, audioFile?.path, videoFile?.path, isRecordingAudio, isRecordingVideo];
// }
