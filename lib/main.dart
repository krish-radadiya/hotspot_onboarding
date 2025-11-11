import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hotspot_onboarding/core/theme/app_theme.dart';
import 'package:hotspot_onboarding/logic/experiences/experience_bloc.dart';
import 'package:hotspot_onboarding/logic/experiences/experience_event.dart';
import 'package:sizer/sizer.dart';

import 'data/repositories/experience_repository.dart';
import 'presentation/screens/experience_selection_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return Sizer(
      builder: (context, orientation, deviceType) {
        return RepositoryProvider(
          create: (_) => ExperienceRepository(),
          child: BlocProvider(
            create: (context) => ExperienceBloc(repository: context.read<ExperienceRepository>())..add(FetchExperiences()),
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Hotspot Onboarding',
              theme: AppTheme.light(),
              home: const ExperienceSelectionScreen(),
            ),
          ),
        );
      },
    );
  }
}
