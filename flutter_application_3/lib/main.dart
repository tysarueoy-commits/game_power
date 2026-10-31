import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_state.dart';
import 'screens/giveaway_screens.dart';

void main() {
  runApp(const ProviderScope(child: GiveawayApp()));
}

class GiveawayApp extends ConsumerWidget {
  const GiveawayApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final seedColor = ref.watch(themeColorProvider);

    return MaterialApp(
      title: 'Playdrop',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: _buildTheme(seedColor, Brightness.light),
      darkTheme: _buildTheme(seedColor, Brightness.dark),
      home: const GiveawayHome(),
    );
  }

  ThemeData _buildTheme(Color seedColor, Brightness brightness) {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: colorScheme.surface,
      cardTheme: CardThemeData(
        color: colorScheme.surfaceContainerLow,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }
}

class GiveawayHome extends StatefulWidget {
  const GiveawayHome({super.key});

  @override
  State<GiveawayHome> createState() => _GiveawayHomeState();
}

class _GiveawayHomeState extends State<GiveawayHome> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    const pages = [GamesScreen(), SavedScreen(), SettingsScreen()];

    return Scaffold(
      body: SafeArea(
        bottom: false,
        child: IndexedStack(index: _selectedIndex, children: pages),
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _selectedIndex,
        onDestinationSelected: (index) {
          setState(() => _selectedIndex = index);
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.sports_esports_outlined),
            selectedIcon: Icon(Icons.sports_esports),
            label: 'Games',
          ),
          NavigationDestination(
            icon: Icon(Icons.bookmark_outline),
            selectedIcon: Icon(Icons.bookmark),
            label: 'Saved',
          ),
          NavigationDestination(
            icon: Icon(Icons.tune),
            selectedIcon: Icon(Icons.tune),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
