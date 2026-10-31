import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import 'models/giveaway.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) => ThemeMode.system);
final themeColorProvider = StateProvider<Color>(
  (ref) => const Color(0xFF7457F5),
);
final savedGiveawaysProvider = StateProvider<Set<int>>((ref) => <int>{});

Future<void> openGiveaway(BuildContext context, Giveaway giveaway) async {
  final uri = Uri.tryParse(giveaway.openGiveawayUrl);
  if (uri == null || !uri.hasScheme) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('This giveaway link is not available.')),
    );
    return;
  }

  try {
    final opened = await launchUrl(uri, mode: LaunchMode.externalApplication);
    if (!opened && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not open the giveaway link.')),
      );
    }
  } catch (error) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open the giveaway link: $error')),
      );
    }
  }
}
