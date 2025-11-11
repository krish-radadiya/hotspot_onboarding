import 'dart:async';
import 'dart:io';
import 'package:bloc/bloc.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'onboarding_event.dart';
import 'onboarding_state.dart';
import 'package:image_picker/image_picker.dart';

class OnboardingBloc extends Bloc<OnboardingEvent, OnboardingState> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final ImagePicker _picker = ImagePicker();

  OnboardingBloc() : super(const OnboardingState()) {
    _init();

    on<UpdateTextAnswer>((e, emit) => emit(state.copyWith(text: e.text)));

    // 🎙️ Start Audio Recording
    on<StartAudioRecording>((e, emit) async {
      if (state.hasVideo) return; // prevent if video already exists
      final mic = await Permission.microphone.request();
      if (!mic.isGranted) return;

      final dir = await getTemporaryDirectory();
      final path = '${dir.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';

      await _recorder.startRecorder(toFile: path, codec: Codec.aacADTS);
      emit(state.copyWith(isRecordingAudio: true, hasAudio: false, audioPath: path));
    });

    // 🛑 Stop Audio Recording
    on<StopAudioRecording>((e, emit) async {
      if (!_recorder.isRecording) return;
      final path = await _recorder.stopRecorder();
      emit(state.copyWith(isRecordingAudio: false, hasAudio: true, audioPath: path));
    });

    // ▶️ Play Audio
    on<PlayAudio>((e, emit) async {
      if (state.audioPath == null) return;
      if (_player.isPlaying) {
        await _player.stopPlayer();
        emit(state.copyWith(isPlayingAudio: false));
      } else {
        await _player.startPlayer(
          fromURI: state.audioPath!,
          whenFinished: () {
            add(StopAudioPlayback());
          },
        );
        emit(state.copyWith(isPlayingAudio: true));
      }
    });

    // ⏹ Stop Audio
    on<StopAudioPlayback>((e, emit) async {
      await _player.stopPlayer();
      emit(state.copyWith(isPlayingAudio: false));
    });

    // 🗑 Delete Audio
    on<DeleteAudio>((e, emit) async {
      final p = state.audioPath;
      if (p != null && await File(p).exists()) await File(p).delete();
      await _player.stopPlayer();
      emit(state.copyWith(audioPath: null, hasAudio: false, isPlayingAudio: false));
    });

    // 🎥 Start Video Recording (via system camera)
    on<StartVideoRecording>((e, emit) async {
      if (state.hasAudio) return; // prevent if audio exists
      final cam = await Permission.camera.request();
      final mic = await Permission.microphone.request();
      if (!cam.isGranted || !mic.isGranted) return;

      final video = await _picker.pickVideo(source: ImageSource.camera, preferredCameraDevice: CameraDevice.front);
      if (video == null) return;
      emit(state.copyWith(videoPath: video.path, hasVideo: true));
    });

    // 🗑 Delete Video
    on<DeleteVideo>((e, emit) async {
      final p = state.videoPath;
      if (p != null && await File(p).exists()) await File(p).delete();
      emit(state.copyWith(videoPath: null, hasVideo: false));
    });
  }

  Future<void> _init() async {
    await _recorder.openRecorder();
    await _player.openPlayer();
  }

  @override
  Future<void> close() async {
    await _recorder.closeRecorder();
    await _player.closePlayer();
    return super.close();
  }
}
