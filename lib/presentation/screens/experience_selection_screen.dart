import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:sizer/sizer.dart';
import 'package:hotspot_onboarding/core/constants/app_text_styles.dart';
import 'package:hotspot_onboarding/logic/experiences/experience_bloc.dart';
import 'package:hotspot_onboarding/logic/experiences/experience_event.dart';
import 'package:hotspot_onboarding/logic/experiences/experience_state.dart';
import 'package:hotspot_onboarding/presentation/widgets/WavyProgressPainter.dart';
import 'package:hotspot_onboarding/presentation/widgets/experience_card..dart';

class ExperienceSelectionScreen extends StatefulWidget {
  const ExperienceSelectionScreen({super.key});

  @override
  State<ExperienceSelectionScreen> createState() =>
      _ExperienceSelectionScreenState();
}

class _ExperienceSelectionScreenState
    extends State<ExperienceSelectionScreen> {
  final TextEditingController _commentController = TextEditingController();
  static const int _commentMaxLength = 250;
  final ScrollController _scrollController = ScrollController();
  double _scrollProgress = 0.0;
  bool _keyboardVisible = false;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateScrollProgress);

    // Listen to keyboard visibility
    KeyboardVisibilityController().onChange.listen((bool visible) {
      setState(() {
        _keyboardVisible = visible;
      });
    });
  }

  void _updateScrollProgress() {
    if (!_scrollController.hasClients ||
        !_scrollController.position.hasContentDimensions) return;
    final maxScroll = _scrollController.position.maxScrollExtent;
    final current = _scrollController.offset;
    setState(() {
      _scrollProgress =
      (maxScroll == 0) ? 0.0 : (current / maxScroll).clamp(0.0, 1.0);
    });
  }

  @override
  void dispose() {
    _commentController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onNextPressed(ExperienceLoadSuccess state) {
    debugPrint('Selected experience IDs: ${state.selectedIds}');
    debugPrint('Experience comment: ${state.comment}');
    Navigator.of(context)
        .push(MaterialPageRoute(builder: (_) => const PlaceholderScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final horizontalPadding = 4.w;

    return Scaffold(
      resizeToAvoidBottomInset: true,
      backgroundColor: const Color(0xFF0D0D0D),
      body: SafeArea(
        child: Column(
          children: [
            // ===== Fixed Custom App Bar =====
            Padding(
              padding: EdgeInsets.only(
                  top: 1.h, left: horizontalPadding, right: horizontalPadding),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_ios_new_rounded,
                        color: Colors.white, size: 20),
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
                    icon:
                    const Icon(Icons.close, color: Colors.white, size: 22),
                  ),
                ],
              ),
            ),

            // ===== Flexible Scrollable Section =====
            Expanded(
              child: BlocBuilder<ExperienceBloc, ExperienceState>(
                builder: (context, state) {
                  if (state is ExperienceInitial || state is ExperienceLoading) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (state is ExperienceFailure) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('Failed to load experiences',
                              style: TextStyle(
                                  fontSize: 12.sp, color: Colors.white)),
                          SizedBox(height: 2.h),
                          ElevatedButton(
                            onPressed: () => context
                                .read<ExperienceBloc>()
                                .add(FetchExperiences()),
                            child:
                            Text('Retry', style: TextStyle(fontSize: 10.sp)),
                          ),
                        ],
                      ),
                    );
                  } else if (state is ExperienceLoadSuccess) {
                    final experiences = state.experiences;
                    final hasSelected = state.selectedIds.isNotEmpty;

                    // sync text controller
                    if (_commentController.text != state.comment) {
                      _commentController.text = state.comment;
                      _commentController.selection =
                          TextSelection.fromPosition(TextPosition(
                              offset: _commentController.text.length));
                    }

                    return LayoutBuilder(
                      builder: (context, constraints) {
                        return SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: EdgeInsets.only(
                            left: horizontalPadding,
                            right: horizontalPadding,
                            bottom:
                            MediaQuery.of(context).viewInsets.bottom + 16,
                          ),
                          child: ConstrainedBox(
                            constraints:
                            BoxConstraints(minHeight: constraints.maxHeight),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // ===== Space below app bar (collapses on keyboard open) =====
                                SizedBox(
                                    height: _keyboardVisible ? 5.h : 38.h),

                                // ===== Your existing UI block =====
                                Padding(
                                  padding: const EdgeInsets.all(8.0),
                                  child: Column(
                                    crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                    children: [
                                      // ===== Header Text =====
                                      AnimatedDefaultTextStyle(
                                        duration:
                                        const Duration(milliseconds: 250),
                                        style: _keyboardVisible
                                            ? AppTextStyles.h2Bold
                                            : AppTextStyles.h3Bold,
                                        child: Column(
                                          crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "01",
                                              style: TextStyle(
                                                  color: Colors.white
                                                      .withOpacity(0.3),
                                                  fontSize: 9.sp),
                                            ),
                                            SizedBox(height: 0.5.h),
                                            Text(hasSelected
                                                ? "What kind of experiences do you want to host?"
                                                : "What kind of hotspots do you want to host?"),
                                          ],
                                        ),
                                      ),

                                      SizedBox(height: 3.h),

                                      // ===== Horizontal Image List =====
                                      SizedBox(
                                        height: 11.h,
                                        child: ListView.builder(
                                          controller: _scrollController,
                                          scrollDirection: Axis.horizontal,
                                          itemCount: experiences.length,
                                          itemBuilder: (context, index) {
                                            final exp = experiences[index];
                                            final selected = state.selectedIds
                                                .contains(exp.id);
                                            return Padding(
                                              padding: EdgeInsets.only(right: 3.w),
                                              child: ExperienceCard(
                                                imageUrl: exp.imageUrl,
                                                selected: selected,
                                                onTap: () => context
                                                    .read<ExperienceBloc>()
                                                    .add(ToggleExperienceSelection(
                                                    exp.id)),
                                              ),
                                            );
                                          },
                                        ),
                                      ),

                                      SizedBox(height: 2.h),

                                      // ===== Comment Box =====
                                      Container(
                                        decoration: BoxDecoration(
                                            color: const Color(0xFF1A1A1A),
                                            borderRadius:
                                            BorderRadius.circular(12)),
                                        child: TextField(
                                          controller: _commentController,
                                          maxLines: 4,
                                          maxLength: _commentMaxLength,
                                          style: AppTextStyles.bodyRegular,
                                          onChanged: (val) => context
                                              .read<ExperienceBloc>()
                                              .add(UpdateExperienceComment(val)),
                                          decoration: InputDecoration(
                                            hintText:
                                            '/ Describe your perfect hotspot',
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
                                      SizedBox(
                                        width: double.infinity,
                                        height: 7.h,
                                        child: ElevatedButton(
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: hasSelected
                                                ? Colors.white.withOpacity(0.25) // 🔆 lighter when selected
                                                : Colors.white.withOpacity(0.15), // 🌑 darker when unselected
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            elevation: 0,
                                          ),
                                          onPressed: hasSelected ? () => _onNextPressed(state) : null,
                                          child: Text(
                                            'Next 🔊',
                                            style: TextStyle(
                                              fontSize: 12.sp,
                                              fontWeight: FontWeight.w700,
                                              color: hasSelected
                                                  ? Colors.white.withOpacity(0.75) // brighter text when active
                                                  : Colors.white.withOpacity(0.25),  // faded text when inactive
                                            ),
                                          ),
                                        ),
                                      ),

                                      SizedBox(
                                          height:
                                          _keyboardVisible ? 2.h : 5.h),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  } else {
                    return const SizedBox();
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ====== Placeholder Next Screen ======
class PlaceholderScreen extends StatelessWidget {
  const PlaceholderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
          backgroundColor: Colors.black,
          title: const Text('Next Screen Placeholder')),
      body: const Center(
        child: Text('Implement Onboarding Question screen here',
            style: TextStyle(color: Colors.white)),
      ),
    );
  }
}
