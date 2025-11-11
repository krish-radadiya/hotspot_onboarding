// import 'dart:io';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:record/record.dart';
// import 'onboarding_event.dart';
// import 'onboarding_state.dart';
//
// class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
//   final _recorder = Record();
//
//   OnboardingBloc() : super(const OnboardingState()) {
//     on<UpdateAnswerText>((e, emit) => emit(state.copyWith(answer: e.text)));
//
//     on<StartAudioRecording>(_onStartAudio);
//     on<StopAudioRecording>(_onStopAudio);
//     on<DeleteAudioRecording>(_onDeleteAudio);
//
//     on<StartVideoRecording>(_onStartVideo);
//     on<StopVideoRecording>(_onStopVideo);
//     on<DeleteVideoRecording>(_onDeleteVideo);
//   }
//
//   Future<void> _onStartAudio(StartAudioRecording e, Emitter emit) async {
//     final perm = await _recorder.hasPermission();
//     if (!perm) return;
//     final dir = await getTemporaryDirectory();
//     final path = '${dir.path}/onboarding_audio_${DateTime.now().millisecondsSinceEpoch}.m4a';
//     await _recorder.start(path: path, encoder: AudioEncoder.aacLc);
//     emit(state.copyWith(isRecordingAudio: true));
//   }
//
//   Future<void> _onStopAudio(StopAudioRecording e, Emitter emit) async {
//     final path = await _recorder.stop();
//     if (path == null) return;
//     emit(state.copyWith(isRecordingAudio: false, audioFile: File(path)));
//   }
//
//   Future<void> _onDeleteAudio(DeleteAudioRecording e, Emitter emit) async {
//     if (state.audioFile != null && await state.audioFile!.exists()) {
//       await state.audioFile!.delete();
//     }
//     emit(state.copyWith(audioFile: null, isRecordingAudio: false));
//   }
//
//   Future<void> _onStartVideo(StartVideoRecording e, Emitter emit) async {
//     emit(state.copyWith(isRecordingVideo: true));
//   }
//
//   Future<void> _onStopVideo(StopVideoRecording e, Emitter emit) async {
//     emit(state.copyWith(isRecordingVideo: false, videoFile: File(e.filePath)));
//   }
//
//   Future<void> _onDeleteVideo(DeleteVideoRecording e, Emitter emit) async {
//     if (state.videoFile != null && await state.videoFile!.exists()) {
//       await state.videoFile!.delete();
//     }
//     emit(state.copyWith(videoFile: null));
//   }
//
//   @override
//   Future<void> close() {
//     _recorder.dispose();
//     return super.close();
//   }
// }
