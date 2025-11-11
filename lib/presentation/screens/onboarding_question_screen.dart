// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:sizer/sizer.dart';
// import '../../logic/onboarding/onboarding_bloc.dart';
// import '../../logic/onboarding/onboarding_event.dart';
// import '../../logic/onboarding/onboarding_state.dart';
// import '../widgets/audio_recorder_widget.dart';
// import '../widgets/video_recorder_widget.dart';
//
// class OnboardingQuestionScreen extends StatelessWidget {
//   const OnboardingQuestionScreen({super.key});
//
//   @override
//   Widget build(BuildContext context) {
//     return BlocProvider(
//       create: (_) => OnboardingBloc(),
//       child: const _OnboardingQuestionView(),
//     );
//   }
// }
//
// class _OnboardingQuestionView extends StatelessWidget {
//   const _OnboardingQuestionView();
//
//   static const int _answerMaxLen = 600;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: Text('Onboarding Question', style: TextStyle(fontSize: 12.sp))),
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 4.w, vertical: 2.h),
//           child: BlocBuilder<OnboardingBloc, OnboardingState>(
//             builder: (context, state) {
//               return SingleChildScrollView(
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text('Tell us about yourself', style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.w600)),
//                     SizedBox(height: 1.h),
//                     TextField(
//                       maxLines: 6,
//                       maxLength: _answerMaxLen,
//                       onChanged: (val) => context.read<OnboardingBloc>().add(UpdateAnswerText(val)),
//                       decoration: InputDecoration(
//                         hintText: 'Write your answer here (max 600 chars)',
//                         border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
//                         contentPadding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 2.h),
//                       ),
//                     ),
//                     SizedBox(height: 2.h),
//
//                     // AUDIO
//                     const AudioRecorderWidget(),
//                     SizedBox(height: 3.h),
//
//                     // VIDEO
//                     const VideoRecorderWidget(),
//                     SizedBox(height: 5.h),
//
//                     SizedBox(
//                       width: double.infinity,
//                       height: 7.h,
//                       child: ElevatedButton(
//                         onPressed: () {
//                           debugPrint('Answer: ${state.answer}');
//                           debugPrint('Audio: ${state.audioFile?.path}');
//                           debugPrint('Video: ${state.videoFile?.path}');
//                         },
//                         child: Text('Submit', style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w600)),
//                       ),
//                     ),
//                   ],
//                 ),
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }
