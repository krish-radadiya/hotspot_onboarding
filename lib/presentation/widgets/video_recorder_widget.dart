// import 'dart:io';
// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:path_provider/path_provider.dart';
// import 'package:sizer/sizer.dart';
// import '../../logic/onboarding/onboarding_bloc.dart';
// import '../../logic/onboarding/onboarding_event.dart';
// import '../../logic/onboarding/onboarding_state.dart';
//
// class VideoRecorderWidget extends StatefulWidget {
//   const VideoRecorderWidget({super.key});
//
//   @override
//   State<VideoRecorderWidget> createState() => _VideoRecorderWidgetState();
// }
//
// class _VideoRecorderWidgetState extends State<VideoRecorderWidget> {
//   CameraController? _controller;
//   late Future<void> _initCam;
//
//   @override
//   void initState() {
//     super.initState();
//     _initCam = _initializeCamera();
//   }
//
//   Future<void> _initializeCamera() async {
//     final cams = await availableCameras();
//     _controller = CameraController(cams.first, ResolutionPreset.medium);
//     await _controller!.initialize();
//   }
//
//   @override
//   void dispose() {
//     _controller?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocBuilder<OnboardingBloc, OnboardingState>(
//       builder: (context, state) {
//         if (state.videoFile != null) {
//           return Column(
//             children: [
//               Image.file(state.videoFile!, height: 20.h, fit: BoxFit.cover),
//               SizedBox(height: 1.h),
//               ElevatedButton.icon(
//                 onPressed: () => context.read<OnboardingBloc>().add(DeleteVideoRecording()),
//                 icon: const Icon(Icons.delete),
//                 label: const Text('Delete Video'),
//               ),
//             ],
//           );
//         }
//
//         return FutureBuilder(
//           future: _initCam,
//           builder: (context, snapshot) {
//             if (snapshot.connectionState != ConnectionState.done) {
//               return const CircularProgressIndicator();
//             }
//
//             return Column(
//               children: [
//                 SizedBox(
//                   height: 25.h,
//                   child: CameraPreview(_controller!),
//                 ),
//                 SizedBox(height: 1.h),
//                 if (!state.isRecordingVideo)
//                   ElevatedButton.icon(
//                     onPressed: () async {
//                       context.read<OnboardingBloc>().add(StartVideoRecording());
//                       final dir = await getTemporaryDirectory();
//                       final filePath =
//                           '${dir.path}/onboarding_video_${DateTime.now().millisecondsSinceEpoch}.mp4';
//                       await _controller!.startVideoRecording();
//                       await Future.delayed(const Duration(seconds: 5)); // demo 5s clip
//                       final file = await _controller!.stopVideoRecording();
//                       await file.saveTo(filePath);
//                       context.read<OnboardingBloc>().add(StopVideoRecording(filePath));
//                     },
//                     icon: const Icon(Icons.videocam),
//                     label: const Text('Record Video'),
//                   )
//                 else
//                   const Text('Recording...'),
//               ],
//             );
//           },
//         );
//       },
//     );
//   }
// }
