import 'package:flutter/material.dart';

import '../features/search/presentation/screens/home_search_screen.dart';
import '../shared/widgets/mobile_shell.dart';
import 'app_theme.dart';

/// Root widget: theme, title and the entry screen of the search flow.
class VillaHomestayApp extends StatelessWidget {
  const VillaHomestayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Villa Homestay Search',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light(),
      home: const HomeSearchScreen(),
      builder: (BuildContext context, Widget? child) =>
          MobileShell(child: child ?? const SizedBox.shrink()),
    );
  }
}
