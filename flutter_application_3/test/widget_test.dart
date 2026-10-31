import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_application_3/data/giveaway_repository.dart';
import 'package:flutter_application_3/main.dart';
import 'package:flutter_application_3/models/giveaway.dart';

const _sampleGiveaway = Giveaway(
  id: 12,
  title: 'Sample Game Giveaway',
  thumbnail: '',
  description: 'A free game to play.',
  instructions: 'Sign in and claim your game.',
  platforms: 'PC, Steam',
  type: 'Game',
  worth: '\$19.99',
  endDate: 'While supplies last',
  openGiveawayUrl: 'https://example.com/giveaway',
);

void main() {
  Widget buildApp() {
    return ProviderScope(
      overrides: [
        giveawaysProvider.overrideWith((ref) async => [_sampleGiveaway]),
      ],
      child: const GiveawayApp(),
    );
  }

  testWidgets('shows giveaway cards and opens the details screen', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    expect(find.text('Free games,\nfound for you.'), findsOneWidget);
    expect(find.text('Sample Game Giveaway'), findsOneWidget);

    await tester.ensureVisible(find.text('Sample Game Giveaway'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Sample Game Giveaway'));
    await tester.pumpAndSettle();

    expect(find.text('Giveaway details'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Sign in and claim your game.'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Sign in and claim your game.'), findsOneWidget);
    await tester.scrollUntilVisible(
      find.text('Get this giveaway'),
      300,
      scrollable: find.byType(Scrollable).last,
    );
    expect(find.text('Get this giveaway'), findsOneWidget);
  });

  testWidgets('saves a giveaway and shows it on the Saved tab', (tester) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.ensureVisible(find.text('Sample Game Giveaway'));
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('Save giveaway'));
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.bookmark_outline));
    await tester.pumpAndSettle();
    expect(find.text('Saved games'), findsOneWidget);
    expect(find.text('Sample Game Giveaway'), findsOneWidget);
  });

  testWidgets('allows dark mode and accent color to be changed', (
    tester,
  ) async {
    await tester.pumpWidget(buildApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byIcon(Icons.tune));
    await tester.pumpAndSettle();

    expect(find.text('Dark mode'), findsOneWidget);
    await tester.tap(find.byType(Switch));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );

    final previousPrimary = tester
        .widget<MaterialApp>(find.byType(MaterialApp))
        .theme!
        .colorScheme
        .primary;
    await tester.tap(find.bySemanticsLabel('Choose green theme'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<MaterialApp>(find.byType(MaterialApp))
          .theme
          ?.colorScheme
          .primary,
      isNot(previousPrimary),
    );
  });
}
