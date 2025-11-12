import 'dart:async';
import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:hotspot_onboarding/core/constants/app_colors.dart';
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

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: AppColors.base1,
      resizeToAvoidBottomInset: false,
      body: Stack(
        children: [
          // === BACKGROUND IMAGE ===
          Positioned.fill(child: Image.asset('assets/images/background image.png', fit: BoxFit.cover)),

          BlocBuilder<OnboardingBloc, OnboardingState>(
            builder: (context, state) {
              if (state.hasVideo && state.videoPath != null && _videoPlayerController == null) {
                _videoPlayerController = VideoPlayerController.file(File(state.videoPath!))..initialize().then((_) => setState(() {}));
              }

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

              return SafeArea(
                child: Stack(
                  children: [
                    // === MAIN SCROLLABLE CONTENT ===
                    SingleChildScrollView(
                      controller: _scrollController,
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(left: 5.w, right: 5.w, bottom: bottomInset + 100),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(height: 1.h),

                          // === APP BAR CONTAINER ===
                          Container(
                            decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(horizontal: 2.w, vertical: 0.8.h),
                            margin: EdgeInsets.only(bottom: 2.h),
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

                          // === HEADINGS ===
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: TextStyle(fontSize: _keyboardVisible ? 9.sp : 10.sp, color: Colors.white.withOpacity(0.3)),
                            child: Text(AppStrings.step02),
                          ),
                          SizedBox(height: 0.5.h),
                          AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 250),
                            style: _keyboardVisible ? AppTextStyles.bodyRegular : AppTextStyles.bodyMedium,
                            child: Text(AppStrings.questionWhyHost),
                          ),
                          AnimatedOpacity(
                            opacity: _keyboardVisible ? 1.0 : 1.0,
                            duration: const Duration(milliseconds: 250),
                            child: Padding(
                              padding: EdgeInsets.only(top: 0.6.h),
                              child: Text(AppStrings.questionIntent, style: AppTextStyles.bodyRegularGrey),
                            ),
                          ),

                          SizedBox(height: hasMedia ? 1.h : 3.h),

                          // === TEXT FIELD ===
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOut,
                            decoration: BoxDecoration(color: const Color(0xFF1A1A1A), borderRadius: BorderRadius.circular(12)),
                            padding: EdgeInsets.symmetric(horizontal: 3.w),
                            constraints: BoxConstraints(
                              minHeight: hasMedia ? (_keyboardVisible ? 10.h : 22.h) : (_keyboardVisible ? 12.h : 30.h),
                              maxHeight: hasMedia ? (_keyboardVisible ? 18.h : 28.h) : (_keyboardVisible ? 22.h : 40.h),
                            ),
                            child: TextField(
                              controller: _controller,
                              minLines: _keyboardVisible ? 6 : 14,
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

                          // === RECORDED SECTIONS ===
                          if (state.isRecordingAudio) _buildAudioRecording(),
                          if (!state.isRecordingAudio && state.hasAudio && state.audioPath != null) _buildAudioRecorded(state),
                          if (state.hasVideo && _videoPlayerController != null && _videoPlayerController!.value.isInitialized) _buildVideoRecorded(),
                        ],
                      ),
                    ),

                    // === FIXED BOTTOM BAR ===
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: _keyboardVisible ? bottomInset : 0.h,
                      child: Container(
                        color: AppColors.base1.withOpacity(0.9),
                        padding: EdgeInsets.symmetric(horizontal: 5.w, vertical: 0.8.h),
                        child: SafeArea(
                          top: false,
                          child: Builder(
                            builder: (context) {
                              final hasMedia = state.hasAudio || state.hasVideo;

                              if (hasMedia) {
                                return AnimatedContainer(
                                  duration: const Duration(milliseconds: 300),
                                  width: double.infinity,
                                  height: 6.5.h,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    gradient: const LinearGradient(
                                      colors: [Color(0xFF222222), Color(0xFF999999), Color(0xFF222222)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                  ),
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                    ),
                                    onPressed: () {},
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          AppStrings.next,
                                          style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white),
                                        ),
                                        SizedBox(width: 2.w),
                                        Image.asset('assets/icon/next_icon.png', height: 16, width: 16, color: Colors.white),
                                      ],
                                    ),
                                  ),
                                );
                              }

                              return Row(
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
                                        borderRadius: BorderRadius.circular(10),
                                        color: AppColors.surfaceWhite1.withOpacity(0.15),
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
                                        borderRadius: BorderRadius.circular(10),
                                        color: AppColors.surfaceWhite1.withOpacity(0.15),
                                      ),
                                      child: const Icon(Icons.videocam_outlined, color: Colors.white),
                                    ),
                                  ),
                                  SizedBox(width: 3.w),
                                  Expanded(
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 300),
                                      height: 6.2.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        color: AppColors.surfaceWhite1.withOpacity(0.15),
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: null,
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              AppStrings.next,
                                              style: TextStyle(fontSize: 12.sp, fontWeight: FontWeight.w700, color: Colors.white38),
                                            ),
                                            SizedBox(width: 2.w),
                                            Image.asset('assets/icon/next_icon.png', height: 16, width: 16, color: Colors.white38),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  // ===== AUDIO RECORDING WIDGET =====
  Widget _buildAudioRecording() {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(color: const Color(0xFF151515), borderRadius: BorderRadius.circular(12)),
      padding: EdgeInsets.all(3.w),
      child: Row(
        children: [
          Container(
            width: 10.w,
            height: 10.h,
            decoration: BoxDecoration(color: AppColors.secondaryAccent, shape: BoxShape.circle),
            child: const Icon(Icons.mic, color: Colors.white, size: 22),
          ),
          SizedBox(width: 3.w),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppStrings.recordingAudio,
                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11.sp),
                ),
                SizedBox(height: 0.8.h),
                _waveform1(true),
              ],
            ),
          ),
          Text(
            _formatTime(_recordSeconds),
            style: TextStyle(color: Colors.white70, fontSize: 11.sp, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }

  // ===== AUDIO RECORDED WIDGET =====
  Widget _buildAudioRecorded(OnboardingState state) {
    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        gradient: const LinearGradient(colors: [Color(0xFF1A1A1A), Color(0xFF0F0F0F)], begin: Alignment.topLeft, end: Alignment.bottomRight),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // ✅ Play / Stop Icon Circle
          GestureDetector(
            onTap: () => context.read<OnboardingBloc>().add(PlayAudio()),
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: state.isPlayingAudio
                    ? const LinearGradient(colors: [Color(0xFF999999), Color(0xFFCCCCCC)], begin: Alignment.topLeft, end: Alignment.bottomRight)
                    : const LinearGradient(colors: [Color(0xFF8B9BFF), Color(0xFF586BFF)], begin: Alignment.topLeft, end: Alignment.bottomRight),
              ),
              child: Icon(state.isPlayingAudio ? Icons.stop_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 24),
            ),
          ),
          SizedBox(width: 3.w),
          // ✅ Text + Waveform
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      AppStrings.audioRecorded,
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 11.sp),
                    ),
                    Text(
                      " .${_formatTime(_finalDuration)}",
                      style: TextStyle(color: AppColors.neutralGray, fontSize: 10.sp, fontWeight: FontWeight.w600),
                    ),
                    Spacer(),
                    GestureDetector(
                      onTap: () => context.read<OnboardingBloc>().add(DeleteAudio()),
                      child: Icon(Icons.delete, color: AppColors.secondaryAccent, size: 20),
                    ),
                  ],
                ),
                SizedBox(height: 0.7.h),
                _waveform(false),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== VIDEO RECORDED WIDGET =====
  Widget _buildVideoRecorded() {
    if (_videoPlayerController == null ||
        !_videoPlayerController!.value.isInitialized) {
      return const SizedBox(); // avoid rendering until ready
    }

    // Safely get values
    final videoValue = _videoPlayerController!.value;
    final totalDuration = videoValue.duration.inSeconds;
    final currentPosition = videoValue.position.inSeconds;

    // handle duration = 0 (metadata not yet loaded)
    final int duration =
    (totalDuration == 0 && videoValue.isInitialized) ? (videoValue.duration.inMilliseconds ~/ 1000) : totalDuration;
    final int current =
    currentPosition > duration ? duration : currentPosition;

    return Container(
      margin: EdgeInsets.only(bottom: 1.5.h),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: EdgeInsets.symmetric(horizontal: 3.w, vertical: 1.5.h),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // === THUMBNAIL ===
          GestureDetector(
            onTap: () {
              if (_videoPlayerController!.value.isPlaying) {
                _videoPlayerController!.pause();
              } else {
                _videoPlayerController!.play();
              }
              setState(() {});
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: SizedBox(
                    width: 56,
                    height: 56,
                    child: AspectRatio(
                      aspectRatio: videoValue.aspectRatio,
                      child: VideoPlayer(_videoPlayerController!),
                    ),
                  ),
                ),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.black.withOpacity(0.35),
                  ),
                ),
                Icon(
                  _videoPlayerController!.value.isPlaying
                      ? Icons.pause_rounded
                      : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
              ],
            ),
          ),

          SizedBox(width: 3.w),

          // === TEXT + TIMER + DELETE ===
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    "${AppStrings.videoRecorded} • ${_formatTime(current)}",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 11.sp,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    context.read<OnboardingBloc>().add(DeleteVideo());
                    _videoPlayerController?.dispose();
                    _videoPlayerController = null;
                  },
                  child: const Icon(
                    Icons.delete_outline,
                    color: Color(0xFF8B9BFF),
                    size: 20,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===== WAVEFORM WIDGET =====
  Widget _waveform(bool animate) {
    return SizedBox(
      height: 24, // Height of waveform container
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List.generate(26, (i) {
          // Smooth sine-based animation for recording
          final t = DateTime.now().millisecond / 1000;
          final double height = animate
              ? (8 + 6 * (1 + sin((i * 0.5) + (t * 8))))
                    .toDouble() // 🔹 animated recording
              : (10 + (i % 5) * 3).toDouble(); // 🔹 static waveform

          return AnimatedContainer(
            duration: const Duration(milliseconds: 100),
            margin: const EdgeInsets.symmetric(horizontal: 1.2),
            width: 3,
            height: height,
            // ✅ now a double
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(2),
              gradient: LinearGradient(
                colors: [Colors.white.withOpacity(0.9), Colors.white.withOpacity(0.7)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _waveform1(bool animate) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: List.generate(20, (i) {
        final height = animate ? (8 + (DateTime.now().millisecond % (10 + i % 4))).toDouble() : (8 + (i % 5) * 4).toDouble();
        return AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 3,
          height: height,
          decoration: BoxDecoration(color: Colors.white.withOpacity(0.85), borderRadius: BorderRadius.circular(2)),
        );
      }),
    );
  }
}
