// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:flutter_audio_waveforms/flutter_audio_waveforms.dart';
// import 'package:sizer/sizer.dart';
// import '../../logic/onboarding/onboarding_bloc.dart';
// import '../../logic/onboarding/onboarding_event.dart';
// import '../../logic/onboarding/onboarding_state.dart';
//
// class AudioRecorderWidget extends StatefulWidget {
//   const AudioRecorderWidget({super.key});
//   @override
//   State<AudioRecorderWidget> createState() => _AudioRecorderWidgetState();
// }
//
// class _AudioRecorderWidgetState extends State<AudioRecorderWidget> {
//   Timer? _timer;
//   int _seconds = 0;
//
//   @override
//   void dispose() {
//     _timer?.cancel();
//     super.dispose();
//   }
//
//   void _startTimer() {
//     _timer?.cancel();
//     _seconds = 0;
//     _timer = Timer.periodic(const Duration(seconds: 1), (_) {
//       setState(() => _seconds++);
//     });
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<OnboardingBloc, OnboardingState>(
//       builder: (context, state) {
//         if (state.isRecordingAudio) {
//           return Column(
//             children: [
//               SizedBox(height: 2.h),
//               Text('Recording... ${_seconds}s', style: TextStyle(fontSize: 11.sp)),
//               SizedBox(height: 1.h),
//               SizedBox(
//                 height: 6.h,
//                 child: AudioWaveforms(
//                   enableGesture: false,
//                   waveStyle: const WaveStyle(
//                     waveColor: Colors.blue,
//                     showMiddleLine: false,
//                   ),
//                   size: Size(90.w, 6.h),
//                   recorderController: RecorderController(),
//                 ),
//               ),
//               SizedBox(height: 2.h),
//               ElevatedButton.icon(
//                 onPressed: () {
//                   context.read<OnboardingBloc>().add(StopAudioRecording());
//                   _timer?.cancel();
//                 },
//                 icon: const Icon(Icons.stop),
//                 label: const Text('Stop Recording'),
//               ),
//               TextButton(
//                 onPressed: () {
//                   context.read<OnboardingBloc>().add(DeleteAudioRecording());
//                   _timer?.cancel();
//                 },
//                 child: const Text('Cancel'),
//               ),
//             ],
//           );
//         } else if (state.audioFile != null) {
//           final file = state.audioFile!;
//           return Column(
//             children: [
//               SizedBox(height: 1.h),
//               Text('Recorded audio: ${file.path.split('/').last}', style: TextStyle(fontSize: 10.sp)),
//               SizedBox(height: 1.h),
//               ElevatedButton.icon(
//                 onPressed: () => context.read<OnboardingBloc>().add(DeleteAudioRecording()),
//                 icon: const Icon(Icons.delete),
//                 label: const Text('Delete Audio'),
//               ),
//             ],
//           );
//         } else {
//           return ElevatedButton.icon(
//             onPressed: () {
//               _startTimer();
//               context.read<OnboardingBloc>().add(StartAudioRecording());
//             },
//             icon: const Icon(Icons.mic),
//             label: const Text('Record Audio'),
//           );
//         }
//       },
//     );
//   }
// }
