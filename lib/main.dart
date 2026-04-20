import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/exercise_provider.dart';
import 'utils/theme.dart';
import 'screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ExerciseProvider()),
      ],
      child: const EchoLearnApp(),
    ),
  );
}

class EchoLearnApp extends StatelessWidget {
  const EchoLearnApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EchoLearn',
      debugShowCheckedModeBanner: false,
      theme: EchoLearnTheme.lightTheme,
      builder: (context, child) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: child!,
        );
      },
      home: const HomeScreen(),
    );
  }
}
