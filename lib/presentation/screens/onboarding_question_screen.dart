// import 'dart:async';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:hotspot_onboarding/core/constants/app_strings.dart';
// import 'package:hotspot_onboarding/core/constants/app_text_styles.dart';
// import 'package:hotspot_onboarding/logic/onboarding/onboarding_bloc.dart';
// import 'package:hotspot_onboarding/logic/onboarding/onboarding_event.dart';
// import 'package:hotspot_onboarding/logic/onboarding/onboarding_state.dart';
// import 'package:hotspot_onboarding/presentation/widgets/WavyProgressPainter.dart';
// import 'package:video_player/video_player.dart';
// import 'package:sizer/sizer.dart';
//
// class OnboardingQuestionScreen extends StatefulWidget {
//   const OnboardingQuestionScreen({super.key});
//
//   @override
//   State<OnboardingQuestionScreen> createState() => _OnboardingQuestionScreenState();
// }
//
// class _OnboardingQuestionScreenState extends State<OnboardingQuestionScreen> {
//   final TextEditingController _controller = TextEditingController();
//   VideoPlayerController? _videoPlayerController;
//   final ScrollController _scrollController = ScrollController();
//   double _scrollProgress = 0.0;
//
//   Timer? _recordTimer;
//   int _recordSeconds = 0;
//   int _finalDuration = 0;
//
//   @override
//   void initState() {
//     super.initState();
//     _scrollController.addListener(_updateScrollProgress);
//   }
//
//   void _updateScrollProgress() {
//     if (!_scrollController.hasClients || !_scrollController.position.hasContentDimensions) return;
//     final maxScroll = _scrollController.position.maxScrollExtent;
//     final current = _scrollController.offset;
//     setState(() {
//       _scrollProgress = (maxScroll == 0) ? 0.0 : (current / maxScroll).clamp(0.0, 1.0);
//     });
//   }
//
//   @override
//   void dispose() {
//     _controller.dispose();
//     _videoPlayerController?.dispose();
//     _recordTimer?.cancel();
//     super.dispose();
//   }
//
//   String _formatTime(int seconds) {
//     final m = (seconds ~/ 60).toString().padLeft(2, '0');
//     final s = (seconds % 60).toString().padLeft(2, '0');
//     return "$m:$s";
//   }
//
//   Widget _waveform(bool animate) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: List.generate(22, (i) {
//         final height = animate ? (8 + (DateTime.now().millisecond % (10 + i % 4))).toDouble() : (8 + (i % 5) * 4).toDouble();
//         return AnimatedContainer(
//           duration: const Duration(milliseconds: 150),
//           width: 3,
//           height: height,
//           decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(2)),
//         );
//       }),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       backgroundColor: const Color(0xFF0D0D0D),
//       resizeToAvoidBottomInset: true,
//       body: SafeArea(
//         child: Padding(
//           padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 2.h),
//           child: BlocBuilder<OnboardingBloc, OnboardingState>(
//             builder: (context, state) {
//               if (state.hasVideo && state.videoPath != null && _videoPlayerController == null) {
//                 _videoPlayerController = VideoPlayerController.file(File(state.videoPath!))..initialize().then((_) => setState(() {}));
//               }
//
//               // 🎙 Manage live recording timer
//               if (state.isRecordingAudio && _recordTimer == null) {
//                 _recordSeconds = 0;
//                 _finalDuration = 0;
//                 _recordTimer = Timer.periodic(const Duration(seconds: 1), (t) {
//                   setState(() => _recordSeconds++);
//                 });
//               } else if (!state.isRecordingAudio && _recordTimer != null) {
//                 _recordTimer?.cancel();
//                 _recordTimer = null;
//                 _finalDuration = _recordSeconds;
//               }
//
//               return Column(
//                 children: [
//                   // ==== Scrollable Content ====
//                   Expanded(
//                     child: SingleChildScrollView(
//                       physics: const ClampingScrollPhysics(),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           // ==== App Bar ====
//                           Row(
//                             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                             children: [
//                               IconButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
//                                 tooltip: AppStrings.back,
//                               ),
//                               Expanded(
//                                 child: Padding(
//                                   padding: EdgeInsets.symmetric(horizontal: 4.w),
//                                   child: CustomPaint(
//                                     painter: WavyProgressPainter(progress: _scrollProgress),
//                                     size: const Size(double.infinity, 8),
//                                   ),
//                                 ),
//                               ),
//                               IconButton(
//                                 onPressed: () => Navigator.pop(context),
//                                 icon: const Icon(Icons.close, color: Colors.white),
//                                 tooltip: AppStrings.close,
//                               ),
//                             ],
//                           ),
//                           SizedBox(height: 12.h),
//
//                           // ==== Text Section ====
//                           Text(
//                             AppStrings.step02,
//                             style: TextStyle(color: Colors.white.withOpacity(0.3), fontSize: 10.sp),
//                           ),
//                           SizedBox(height: 1.h),
//                           Text(AppStrings.questionWhyHost, style: AppTextStyles.bodyMedium),
//                           SizedBox(height: 1.h),
//                           Text(AppStrings.questionIntent, style: AppTextStyles.bodyRegularGrey),
//                           SizedBox(height: 2.h),
//
//                           // ==== Text Field ====
//                           Container(
//                             decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
//                             padding: EdgeInsets.symmetric(horizontal: 3.w),
//                             child: TextField(
//                               controller: _controller,
//                               minLines: 10,
//                               maxLines: 18,
//                               onChanged: (val) => context.read<OnboardingBloc>().add(UpdateTextAnswer(val)),
//                               style: TextStyle(color: Colors.white, fontSize: 11.sp),
//                               decoration: InputDecoration(
//                                 hintText: AppStrings.hintStartTyping,
//                                 hintStyle: TextStyle(color: Colors.white30, fontSize: 11.sp),
//                                 border: InputBorder.none,
//                               ),
//                             ),
//                           ),
//                           SizedBox(height: 2.h),
//
//                           // ==== Recording UI ====
//                           if (state.isRecordingAudio)
//                             Container(
//                               margin: EdgeInsets.only(bottom: 2.h),
//                               decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(12)),
//                               padding: EdgeInsets.all(3.w),
//                               child: Row(
//                                 children: [
//                                   Container(
//                                     width: 44,
//                                     height: 44,
//                                     decoration: const BoxDecoration(color: Color(0xFF8B9BFF), shape: BoxShape.circle),
//                                     child: const Icon(Icons.mic, color: Colors.white, size: 22),
//                                   ),
//                                   SizedBox(width: 3.w),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           AppStrings.recordingAudio,
//                                           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11.sp),
//                                         ),
//                                         SizedBox(height: 0.8.h),
//                                         _waveform(true),
//                                       ],
//                                     ),
//                                   ),
//                                   Text(
//                                     _formatTime(_recordSeconds),
//                                     style: TextStyle(color: Colors.white70, fontSize: 11.sp, fontWeight: FontWeight.w500),
//                                   ),
//                                 ],
//                               ),
//                             ),
//
//                           // ==== Recorded Audio ====
//                           if (!state.isRecordingAudio && state.hasAudio && state.audioPath != null)
//                             Container(
//                               margin: EdgeInsets.only(bottom: 2.h),
//                               decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(12)),
//                               padding: EdgeInsets.all(3.w),
//                               child: Row(
//                                 children: [
//                                   GestureDetector(
//                                     onTap: () => context.read<OnboardingBloc>().add(PlayAudio()),
//                                     child: Container(
//                                       width: 44,
//                                       height: 44,
//                                       decoration: BoxDecoration(
//                                         color: state.isPlayingAudio ? Colors.white : const Color(0xFF8B9BFF),
//                                         shape: BoxShape.circle,
//                                       ),
//                                       child: Icon(
//                                         state.isPlayingAudio ? Icons.stop : Icons.play_arrow,
//                                         color: state.isPlayingAudio ? Colors.black : Colors.white,
//                                         size: 24,
//                                       ),
//                                     ),
//                                   ),
//                                   SizedBox(width: 3.w),
//                                   Expanded(
//                                     child: Column(
//                                       crossAxisAlignment: CrossAxisAlignment.start,
//                                       children: [
//                                         Text(
//                                           "${AppStrings.audioRecorded} • ${_formatTime(_finalDuration)}",
//                                           style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11.sp),
//                                         ),
//                                         SizedBox(height: 0.8.h),
//                                         _waveform(false),
//                                       ],
//                                     ),
//                                   ),
//                                   IconButton(
//                                     onPressed: () => context.read<OnboardingBloc>().add(DeleteAudio()),
//                                     icon: const Icon(Icons.delete_outline, color: Colors.white),
//                                   ),
//                                 ],
//                               ),
//                             ),
//                         ],
//                       ),
//                     ),
//                   ),
//
//                   // ==== Video Recorded ====
//                   if (state.hasVideo && _videoPlayerController != null && _videoPlayerController!.value.isInitialized)
//                     StatefulBuilder(
//                       builder: (context, setInnerState) {
//                         Timer.periodic(const Duration(seconds: 1), (t) {
//                           if (!mounted) {
//                             t.cancel();
//                             return;
//                           }
//                           if (_videoPlayerController!.value.isPlaying) {
//                             setInnerState(() {});
//                           } else {
//                             t.cancel();
//                           }
//                         });
//
//                         final duration = _videoPlayerController!.value.duration.inSeconds;
//                         final position = _videoPlayerController!.value.position.inSeconds;
//                         final current = position > duration ? duration : position;
//
//                         return Container(
//                           margin: EdgeInsets.only(bottom: 2.h),
//                           decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(12)),
//                           padding: EdgeInsets.all(3.w),
//                           child: Row(
//                             crossAxisAlignment: CrossAxisAlignment.center,
//                             children: [
//                               GestureDetector(
//                                 onTap: () {
//                                   if (_videoPlayerController!.value.isPlaying) {
//                                     _videoPlayerController!.pause();
//                                   } else {
//                                     _videoPlayerController!.play();
//                                   }
//                                   setInnerState(() {});
//                                 },
//                                 child: SizedBox(
//                                   width: 60,
//                                   height: 60,
//                                   child: Stack(
//                                     alignment: Alignment.center,
//                                     children: [
//                                       ClipRRect(
//                                         borderRadius: BorderRadius.circular(8),
//                                         child: AspectRatio(
//                                           aspectRatio: _videoPlayerController!.value.aspectRatio,
//                                           child: VideoPlayer(_videoPlayerController!),
//                                         ),
//                                       ),
//                                       if (!_videoPlayerController!.value.isPlaying) const Icon(Icons.play_circle_fill, color: Colors.white, size: 30),
//                                     ],
//                                   ),
//                                 ),
//                               ),
//                               SizedBox(width: 3.w),
//                               Expanded(
//                                 child: Column(
//                                   crossAxisAlignment: CrossAxisAlignment.start,
//                                   children: [
//                                     Text(
//                                       AppStrings.videoRecorded,
//                                       style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11.sp),
//                                     ),
//                                     SizedBox(height: 0.8.h),
//                                     Text(
//                                       "${_formatTime(current)} / ${_formatTime(duration)}",
//                                       style: TextStyle(color: Colors.white70, fontSize: 10.sp),
//                                     ),
//                                   ],
//                                 ),
//                               ),
//                               IconButton(
//                                 onPressed: () {
//                                   context.read<OnboardingBloc>().add(DeleteVideo());
//                                   _videoPlayerController?.dispose();
//                                   _videoPlayerController = null;
//                                 },
//                                 icon: const Icon(Icons.delete_outline, color: Colors.white),
//                               ),
//                             ],
//                           ),
//                         );
//                       },
//                     ),
//
//                   // ==== Bottom Buttons ====
//                   Padding(
//                     padding: EdgeInsets.only(top: 1.h),
//                     child: Row(
//                       children: [
//                         if (!state.hasVideo)
//                           GestureDetector(
//                             onTap: () {
//                               if (state.isRecordingAudio) {
//                                 context.read<OnboardingBloc>().add(StopAudioRecording());
//                               } else {
//                                 context.read<OnboardingBloc>().add(StartAudioRecording());
//                               }
//                             },
//                             child: Container(
//                               width: 14.w,
//                               height: 6.h,
//                               decoration: BoxDecoration(color: const Color(0xFF1B1B1B), borderRadius: BorderRadius.circular(10)),
//                               child: Icon(state.isRecordingAudio ? Icons.stop : Icons.mic_none, color: Colors.white),
//                             ),
//                           ),
//                         SizedBox(width: 3.w),
//                         if (!state.hasAudio)
//                           GestureDetector(
//                             onTap: () => context.read<OnboardingBloc>().add(StartVideoRecording()),
//                             child: Container(
//                               width: 14.w,
//                               height: 6.h,
//                               decoration: BoxDecoration(color: const Color(0xFF1B1B1B), borderRadius: BorderRadius.circular(10)),
//                               child: const Icon(Icons.videocam_outlined, color: Colors.white),
//                             ),
//                           ),
//                         const Spacer(),
//                         SizedBox(
//                           width: 55.w,
//                           height: 6.2.h,
//                           child: ElevatedButton(
//                             style: ElevatedButton.styleFrom(
//                               backgroundColor: Colors.white.withOpacity(0.15),
//                               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
//                             ),
//                             onPressed: () {},
//                             child: Text(AppStrings.next, style: AppTextStyles.bodyBold),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ],
//               );
//             },
//           ),
//         ),
//       ),
//     );
//   }
// }


import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:hotspot_onboarding/core/constants/app_strings.dart';
import 'package:hotspot_onboarding/core/constants/app_text_styles.dart';
import 'package:hotspot_onboarding/logic/onboarding/onboarding_bloc.dart';
import 'package:hotspot_onboarding/logic/onboarding/onboarding_event.dart';
import 'package:hotspot_onboarding/logic/onboarding/onboarding_state.dart';
import 'package:hotspot_onboarding/presentation/widgets/WavyProgressPainter.dart';
import 'package:video_player/video_player.dart';
import 'package:sizer/sizer.dart';

class OnboardingQuestionScreen extends StatefulWidget {
  const OnboardingQuestionScreen({super.key});

  @override
  State<OnboardingQuestionScreen> createState() => _OnboardingQuestionScreenState();
}

class _OnboardingQuestionScreenState extends State<OnboardingQuestionScreen> {
  final TextEditingController _controller = TextEditingController();
  VideoPlayerController? _videoPlayerController;
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  bool _keyboardVisible = false;

  Timer? _recordTimer;
  int _recordSeconds = 0;
  int _finalDuration = 0;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
    KeyboardVisibilityController().onChange.listen((visible) {
      setState(() => _keyboardVisible = visible);
    });
  }

  void _updateScrollProgress() {
    if (!_scrollController.hasClients || !_scrollController.position.hasContentDimensions) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    setState(() {
      _scrollProgress = (maxScroll == 0) ? 0.0 : (current / maxScroll).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    _videoPlayerController?.dispose();
    _recordTimer?.cancel();
    super.dispose();
  }

  String _formatTime(int seconds) {
    final m = (seconds ~/ 60).toString().padLeft(2, '0');
    final s = (seconds % 60).toString().padLeft(2, '0');
    return "$m:$s";
  }

  Widget _waveform(bool animate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(20, (i) {
        final height =
        animate ? (8 + (DateTime.now().millisecond % (10 + i % 4))).toDouble() : (8 + (i % 5) * 4).toDouble();
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 3,
          height: height,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(2)),
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFF0D0D0D),
      resizeToAvoidBottomInset: false,
      body: BlocBuilder<OnboardingBloc, OnboardingState>(
        builder: (context, state) {
          // initialize video
          if (state.hasVideo && state.videoPath != null && _videoPlayerController == null) {
            _videoPlayerController = VideoPlayerController.file(File(state.videoPath!))
              ..initialize().then((_) => setState(() {}));
          }

          // recording timer
          if (state.isRecordingAudio && _recordTimer == null) {
            _recordSeconds = 0;
            _finalDuration = 0;
            _recordTimer = Timer.periodic(const Duration(seconds: 1), (_) => setState(() => _recordSeconds++));
          } else if (!state.isRecordingAudio && _recordTimer != null) {
            _recordTimer?.cancel();
            _recordTimer = null;
            _finalDuration = _recordSeconds;
          }

          final hasMedia = state.hasAudio || state.hasVideo;

          return Stack(
            children: [
              // ==== MAIN CONTENT ====
              SafeArea(
                child: SingleChildScrollView(
                  controller: _scrollController,
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.only(
                    left: 5.w,
                    right: 5.w,
                    bottom: bottomInset + 90,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ==== HEADER ====
                      Padding(
                        padding: EdgeInsets.only(top: 1.h, bottom: 2.h),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
                            ),
                            Expanded(
                              child: Padding(
                                padding: EdgeInsets.symmetric(horizontal: 4.w),
                                child: CustomPaint(
                                  painter: WavyProgressPainter(progress: _scrollProgress),
                                  size: const Size(double.infinity, 8),
                                ),
                              ),
                            ),
                            IconButton(
                              onPressed: () => Navigator.pop(context),
                              icon: const Icon(Icons.close, color: Colors.white),
                            ),
                          ],
                        ),
                      ),

                      // ==== TEXT HEADINGS ====
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: TextStyle(
                          fontSize: _keyboardVisible ? 9.sp : 11.sp,
                          color: Colors.white.withOpacity(0.3),
                        ),
                        child: Text(AppStrings.step02),
                      ),
                      SizedBox(height: 0.5.h),
                      AnimatedDefaultTextStyle(
                        duration: const Duration(milliseconds: 250),
                        style: _keyboardVisible ? AppTextStyles.bodySmall : AppTextStyles.bodyMedium,
                        child: Text(AppStrings.questionWhyHost),
                      ),
                      AnimatedOpacity(
                        opacity: _keyboardVisible ? 0.0 : 1.0,
                        duration: const Duration(milliseconds: 250),
                        child: Padding(
                          padding: EdgeInsets.only(top: 0.6.h),
                          child: Text(AppStrings.questionIntent, style: AppTextStyles.bodyRegularGrey),
                        ),
                      ),
                      SizedBox(height: 1.5.h),

                      // ==== TEXT FIELD ====
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        curve: Curves.easeOut,
                        decoration: BoxDecoration(
                          color: const Color(0xFF1A1A1A),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 3.w),
                        constraints: BoxConstraints(
                          minHeight: _keyboardVisible ? 12.h : 30.h, // 📏 slightly taller when closed
                          maxHeight: _keyboardVisible ? 22.h : 40.h,
                        ),
                        child: TextField(
                          controller: _controller,
                          minLines: _keyboardVisible ? 6 : 10,
                          maxLines: _keyboardVisible ? 6 : 20,
                          onChanged: (val) => context.read<OnboardingBloc>().add(UpdateTextAnswer(val)),
                          style: TextStyle(color: Colors.white, fontSize: 11.sp),
                          decoration: InputDecoration(
                            hintText: AppStrings.hintStartTyping,
                            hintStyle: TextStyle(color: Colors.white30, fontSize: 11.sp),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                      SizedBox(height: 1.5.h),

                      // ==== AUDIO / VIDEO UI ====
                      if (state.isRecordingAudio) _buildAudioRecording(),
                      if (!state.isRecordingAudio && state.hasAudio && state.audioPath != null)
                        _buildAudioRecorded(state),
                      if (state.hasVideo && _videoPlayerController != null && _videoPlayerController!.value.isInitialized)
                        _buildVideoRecorded(),
                    ],
                  ),
                ),
              ),

              // ==== FIXED BOTTOM BAR ====
              Positioned(
                left: 0,
                right: 0,
                bottom: _keyboardVisible ? bottomInset : 0.h, // 📏 when closed: small gap from bottom
                child: Container(
                  color: Colors.black.withOpacity(0.85),
                  padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.1.h),
                  child: SafeArea(
                    top: false,
                    child: hasMedia
                        ? SizedBox(
                      width: double.infinity,
                      height: 6.5.h,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white.withOpacity(0.15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        onPressed: () {},
                        child: Text(AppStrings.next, style: AppTextStyles.bodyBold),
                      ),
                    )
                        : Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            if (state.isRecordingAudio) {
                              context.read<OnboardingBloc>().add(StopAudioRecording());
                            } else {
                              context.read<OnboardingBloc>().add(StartAudioRecording());
                            }
                          },
                          child: Container(
                            width: 14.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B1B1B),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(state.isRecordingAudio ? Icons.stop : Icons.mic_none, color: Colors.white),
                          ),
                        ),
                        SizedBox(width: 3.w),
                        GestureDetector(
                          onTap: () => context.read<OnboardingBloc>().add(StartVideoRecording()),
                          child: Container(
                            width: 14.w,
                            height: 6.h,
                            decoration: BoxDecoration(
                              color: const Color(0xFF1B1B1B),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(Icons.videocam_outlined, color: Colors.white),
                          ),
                        ),
                        // const Spacer(),
                        SizedBox(
                          width: 55.w,
                          height: 6.2.h,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.white.withOpacity(0.15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            ),
                            onPressed: () {},
                            child: Text(AppStrings.next, style: AppTextStyles.bodyBold),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  // ==== AUDIO RECORDING ====
  Widget _buildAudioRecording() {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.all(3.w),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(color: Color(0xFF8B9BFF), shape: BoxShape.circle),
            child: const Icon(Icons.mic, color: Colors.white, size: 22),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.recordingAudio,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11.sp)),
                SizedBox(height: 0.8.h),
                _waveform(true),
              ],
            ),
          ),
          Text(_formatTime(_recordSeconds),
              style: TextStyle(color: Colors.white70, fontSize: 11.sp, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }

  // ==== AUDIO RECORDED ====
  Widget _buildAudioRecorded(OnboardingState state) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.all(3.w),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => context.read<OnboardingBloc>().add(PlayAudio()),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: state.isPlayingAudio ? Colors.white : const Color(0xFF8B9BFF),
                shape: BoxShape.circle,
              ),
              child: Icon(
                state.isPlayingAudio ? Icons.stop : Icons.play_arrow,
                color: state.isPlayingAudio ? Colors.black : Colors.white,
                size: 24,
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text("${AppStrings.audioRecorded} • ${_formatTime(_finalDuration)}",
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11.sp)),
                SizedBox(height: 0.8.h),
                _waveform(false),
              ],
            ),
          ),
          IconButton(
            onPressed: () => context.read<OnboardingBloc>().add(DeleteAudio()),
            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }

  // ==== VIDEO RECORDED ====
  Widget _buildVideoRecorded() {
    final duration = _videoPlayerController!.value.duration.inSeconds;
    final position = _videoPlayerController!.value.position.inSeconds;
    final current = position > duration ? duration : position;

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.all(3.w),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          GestureDetector(
            onTap: () {
              if (_videoPlayerController!.value.isPlaying) {
                _videoPlayerController!.pause();
              } else {
                _videoPlayerController!.play();
              }
              setState(() {});
            },
            child: SizedBox(
              width: 60,
              height: 60,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: AspectRatio(
                  aspectRatio: _videoPlayerController!.value.aspectRatio,
                  child: VideoPlayer(_videoPlayerController!),
                ),
              ),
            ),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(AppStrings.videoRecorded,
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11.sp)),
                SizedBox(height: 0.8.h),
                Text("${_formatTime(current)} / ${_formatTime(duration)}",
                    style: TextStyle(color: Colors.white70, fontSize: 10.sp)),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              context.read<OnboardingBloc>().add(DeleteVideo());
              _videoPlayerController?.dispose();
              _videoPlayerController = null;
            },
            icon: const Icon(Icons.delete_outline, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
