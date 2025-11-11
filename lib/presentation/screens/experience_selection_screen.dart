import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:hotspot_onboarding/logic/onboarding/onboarding_bloc.dart';
import 'package:hotspot_onboarding/presentation/screens/onboarding_question_screen.dart';
import 'package:sizer/sizer.dart';
import 'package:hotspot_onboarding/core/constants/app_text_styles.dart';
import 'package:hotspot_onboarding/core/constants/app_strings.dart'; // ✅ New import
import 'package:hotspot_onboarding/logic/experiences/experience_bloc.dart';
import 'package:hotspot_onboarding/logic/experiences/experience_event.dart';
import 'package:hotspot_onboarding/logic/experiences/experience_state.dart';
import 'package:hotspot_onboarding/presentation/widgets/WavyProgressPainter.dart';
import 'package:hotspot_onboarding/presentation/widgets/experience_card..dart';

class ExperienceSelectionScreen extends StatefulWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  State<ExperienceSelectionScreen> createState() => _ExperienceSelectionScreenState();
}

class _ExperienceSelectionScreenState extends State<ExperienceSelectionScreen> {
  final TextEditingController _commentController = TextEditingController();
  static const int _commentMaxLength = 250;
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);
    KeyboardVisibilityController().onChange.listen((bool visible) {
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
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onNextPressed(ExperienceLoadSuccess state) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => BlocProvider(
          create: (_) => OnboardingBloc(),
          child: const OnboardingQuestionScreen(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = 4.w;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: BlocBuilder<ExperienceBloc, ExperienceState>(
          builder: (context, state) {
            if (state is ExperienceInitial || state is ExperienceLoading) {
              return const Center(child: CircularProgressIndicator());
            } else if (state is ExperienceFailure) {
              return Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(AppStrings.failedToLoad,
                        style: TextStyle(fontSize: 12.sp, color: Colors.white)),
                    SizedBox(height: 2.h),
                    ElevatedButton(
                      onPressed: () => context.read<ExperienceBloc>().add(FetchExperiences()),
                      child: Text(AppStrings.retry, style: TextStyle(fontSize: 10.sp)),
                    ),
                  ],
                ),
              );
            } else if (state is ExperienceLoadSuccess) {
              final experiences = state.experiences;
              final hasSelected = state.selectedIds.isNotEmpty;

              // sync comment
              if (_commentController.text != state.comment) {
                _commentController.text = state.comment;
                _commentController.selection = TextSelection.fromPosition(
                  TextPosition(offset: _commentController.text.length),
                );
              }

              return Padding(
                padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
                child: Column(
                  children: [
                    // ===== App Bar =====
                    Padding(
                      padding: EdgeInsets.only(top: 1.h),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.arrow_back_ios_new_rounded,
                                color: Colors.white, size: 20),
                            tooltip: AppStrings.back,
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
                            icon: const Icon(Icons.close, color: Colors.white, size: 22),
                            tooltip: AppStrings.close,
                          ),
                        ],
                      ),
                    ),

                    // ===== Body =====
                    Expanded(
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 600),
                        curve: Curves.easeInOutCubic,
                        transform: Matrix4.translationValues(0, _keyboardVisible ? -5.h : 0, 0),
                        child: SingleChildScrollView(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: _keyboardVisible ? 8.h : 30.h),

                              // ===== Header Text =====
                              AnimatedSlide(
                                duration: const Duration(milliseconds: 500),
                                curve: Curves.easeOutExpo,
                                offset: _keyboardVisible ? const Offset(0, -0.1) : Offset.zero,
                                child: AnimatedDefaultTextStyle(
                                  duration: const Duration(milliseconds: 350),
                                  style: _keyboardVisible ? AppTextStyles.h2Bold : AppTextStyles.h3Bold,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        AppStrings.step01,
                                        style: TextStyle(
                                            color: Colors.white.withOpacity(0.3),
                                            fontSize: 9.sp),
                                      ),
                                      SizedBox(height: 0.5.h),
                                      AnimatedSwitcher(
                                        duration: const Duration(milliseconds: 400),
                                        child: Text(
                                          hasSelected
                                              ? AppStrings.questionExperiences
                                              : AppStrings.questionHotspots,
                                          key: ValueKey(hasSelected),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),

                              SizedBox(height: 2.h),

                              // ===== Horizontal Cards =====
                              SizedBox(
                                height: 12.h,
                                child: ListView.builder(
                                  controller: _scrollController,
                                  scrollDirection: Axis.horizontal,
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: experiences.length,
                                  itemBuilder: (context, index) {
                                    final exp = experiences[index];
                                    final selected = state.selectedIds.contains(exp.id);

                                    double itemOffset = (index * 110.0) - _scrollController.offset;
                                    double scale = (1 - (itemOffset.abs() / 600)).clamp(0.85, 1.0);
                                    double opacity = (1 - (itemOffset.abs() / 500)).clamp(0.4, 1.0);
                                    double rotationY = (itemOffset / 600).clamp(-0.4, 0.4);

                                    return AnimatedOpacity(
                                      opacity: opacity,
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeOut,
                                      child: Transform(
                                        alignment: Alignment.center,
                                        transform: Matrix4.identity()
                                          ..setEntry(3, 2, 0.0012)
                                          ..rotateY(rotationY)
                                          ..scale(scale),
                                        child: Padding(
                                          padding: EdgeInsets.only(right: 2.w),
                                          child: ExperienceCard(
                                            imageUrl: exp.imageUrl,
                                            selected: selected,
                                            onTap: () => context.read<ExperienceBloc>().add(
                                                ToggleExperienceSelection(exp.id)),
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),

                              SizedBox(height: 1.5.h),

                              // ===== Comment Box =====
                              Container(
                                decoration: BoxDecoration(
                                  color: const Color(0xFF1A1A1A),
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: TextField(
                                  controller: _commentController,
                                  maxLines: 4,
                                  maxLength: _commentMaxLength,
                                  style: AppTextStyles.bodyRegular,
                                  onChanged: (val) => context.read<ExperienceBloc>().add(
                                      UpdateExperienceComment(val)),
                                  decoration: InputDecoration(
                                    hintText: AppStrings.commentHint,
                                    hintStyle: AppTextStyles.bodyRegularDark,
                                    contentPadding: EdgeInsets.symmetric(
                                        horizontal: 3.w, vertical: 2.h),
                                    border: InputBorder.none,
                                    counterText: "",
                                  ),
                                ),
                              ),

                              SizedBox(height: 2.h),

                              // ===== Next Button =====
                              TweenAnimationBuilder<double>(
                                tween: Tween(begin: 0, end: hasSelected ? 1 : 0),
                                duration: const Duration(milliseconds: 400),
                                builder: (context, value, child) {
                                  return Transform.scale(
                                    scale: 0.95 + (0.05 * value),
                                    child: AnimatedContainer(
                                      duration: const Duration(milliseconds: 250),
                                      width: double.infinity,
                                      height: 7.h,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        gradient: LinearGradient(
                                          colors: hasSelected
                                              ? [
                                            const Color(0xFFB5B5B5),
                                            const Color(0xFF7A7A7A),
                                          ]
                                              : [
                                            const Color(0xFF3A3A3A),
                                            const Color(0xFF1E1E1E),
                                          ],
                                          begin: Alignment.topLeft,
                                          end: Alignment.bottomRight,
                                        ),
                                        boxShadow: [
                                          if (hasSelected)
                                            BoxShadow(
                                              color: Colors.white.withOpacity(0.12),
                                              blurRadius: 10,
                                              offset: const Offset(0, 4),
                                            )
                                          else
                                            BoxShadow(
                                              color: Colors.black.withOpacity(0.2),
                                              blurRadius: 6,
                                              offset: const Offset(0, 2),
                                            ),
                                        ],
                                      ),
                                      child: ElevatedButton(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.transparent,
                                          shadowColor: Colors.transparent,
                                          shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12)),
                                        ),
                                        onPressed: hasSelected ? () => _onNextPressed(state) : null,
                                        child: Text(
                                          AppStrings.next,
                                          style: TextStyle(
                                            fontSize: 12.sp,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white.withOpacity(hasSelected ? 0.9 : 0.4),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              SizedBox(height: _keyboardVisible ? 3.h : 8.h),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            } else {
              return const SizedBox();
            }
          },
        ),
      ),
    );
  }
}
