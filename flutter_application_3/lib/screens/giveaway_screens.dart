import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../app_state.dart';
import '../data/giveaway_repository.dart';
import '../models/giveaway.dart';

class GamesScreen extends ConsumerStatefulWidget {
  const GamesScreen({super.key});

  @override
  ConsumerState<GamesScreen> createState() => _GamesScreenState();
}

class _GamesScreenState extends ConsumerState<GamesScreen> {
  static const _filters = ['All', 'PC', 'Steam', 'Epic', 'Console'];
  final _searchKey = GlobalKey();
  String _filter = 'All';
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final giveaways = ref.watch(giveawaysProvider);
    final colors = Theme.of(context).colorScheme;

    return RefreshIndicator(
      onRefresh: () => ref.refresh(giveawaysProvider.future),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(child: _PageHeading()),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 22),
              child: _FeaturedBanner(onBrowse: _scrollToSearch),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              key: _searchKey,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: (value) => setState(() => _query = value.trim()),
                decoration: InputDecoration(
                  hintText: 'Search games and giveaways',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: colors.surfaceContainerLow,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(vertical: 15),
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: SizedBox(
              height: 66,
              child: ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
                scrollDirection: Axis.horizontal,
                itemCount: _filters.length,
                separatorBuilder: (_, _) => const SizedBox(width: 9),
                itemBuilder: (context, index) {
                  final filter = _filters[index];
                  return ChoiceChip(
                    label: Text(filter),
                    selected: _filter == filter,
                    onSelected: (_) => setState(() => _filter = filter),
                  );
                },
              ),
            ),
          ),
          giveaways.when(
            data: (items) {
              final visible = items.where(_matches).toList(growable: false);
              return _giveawayGridSliver(
                context,
                visible,
                emptyMessage: 'No giveaways match your search.',
              );
            },
            error: (error, _) => _messageSliver(
              context,
              icon: Icons.cloud_off_outlined,
              title: 'Couldn’t load giveaways',
              message: error.toString(),
              action: FilledButton.icon(
                onPressed: () => ref.invalidate(giveawaysProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ),
            loading: () => _loadingSliver(context),
          ),
        ],
      ),
    );
  }

  bool _matches(Giveaway giveaway) {
    final matchesFilter =
        _filter == 'All' ||
        giveaway.platforms.toLowerCase().contains(_filter.toLowerCase());
    final searchable =
        '${giveaway.title} ${giveaway.description} ${giveaway.platforms}'
            .toLowerCase();
    return matchesFilter && searchable.contains(_query.toLowerCase());
  }

  void _scrollToSearch() {
    final searchContext = _searchKey.currentContext;
    if (searchContext != null) {
      Scrollable.ensureVisible(
        searchContext,
        duration: const Duration(milliseconds: 250),
      );
    }
  }
}

class SavedScreen extends ConsumerWidget {
  const SavedScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final savedIds = ref.watch(savedGiveawaysProvider);
    final giveaways = ref.watch(giveawaysProvider);

    return RefreshIndicator(
      onRefresh: () => ref.refresh(giveawaysProvider.future),
      child: CustomScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        slivers: [
          const SliverToBoxAdapter(
            child: _PageHeading(
              eyebrow: 'YOUR COLLECTION',
              title: 'Saved games',
              subtitle: 'Keep the giveaways you love close by.',
            ),
          ),
          giveaways.when(
            data: (items) {
              final saved = items
                  .where((item) => savedIds.contains(item.id))
                  .toList();
              return _giveawayGridSliver(
                context,
                saved,
                emptyMessage: 'Tap the bookmark on any game to save it here.',
                emptyTitle: 'Nothing saved yet',
                emptyIcon: Icons.bookmark_add_outlined,
              );
            },
            error: (error, _) => _messageSliver(
              context,
              icon: Icons.cloud_off_outlined,
              title: 'Couldn’t load saved games',
              message: error.toString(),
              action: FilledButton.icon(
                onPressed: () => ref.invalidate(giveawaysProvider),
                icon: const Icon(Icons.refresh),
                label: const Text('Try again'),
              ),
            ),
            loading: () => _loadingSliver(context),
          ),
        ],
      ),
    );
  }
}

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  static const _colors = [
    Color(0xFF7457F5),
    Color(0xFF0B8A72),
    Color(0xFFDF5E55),
    Color(0xFF2876D2),
    Color(0xFFB14A9A),
    Color(0xFFB18118),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(themeModeProvider);
    final seed = ref.watch(themeColorProvider);
    final colors = Theme.of(context).colorScheme;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
      children: [
        const _PageHeading(
          eyebrow: 'MAKE IT YOURS',
          title: 'Settings',
          subtitle: 'Set the mood for your next discovery.',
        ),
        const SizedBox(height: 24),
        Card(
          child: SwitchListTile(
            secondary: CircleAvatar(
              backgroundColor: colors.primaryContainer,
              child: Icon(Icons.dark_mode_outlined, color: colors.primary),
            ),
            title: const Text('Dark mode'),
            subtitle: Text(
              mode == ThemeMode.system
                  ? 'Currently following your device'
                  : 'Turn dark appearance ${mode == ThemeMode.dark ? 'off' : 'on'}',
            ),
            value: mode == ThemeMode.dark,
            onChanged: (enabled) {
              ref.read(themeModeProvider.notifier).state = enabled
                  ? ThemeMode.dark
                  : ThemeMode.light;
            },
          ),
        ),
        const SizedBox(height: 12),
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Accent color',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 5),
                Text(
                  'Choose a color for buttons and highlights.',
                  style: TextStyle(color: colors.onSurfaceVariant),
                ),
                const SizedBox(height: 18),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    for (final color in _colors)
                      Semantics(
                        label: 'Choose ${_colorName(color)} theme',
                        button: true,
                        child: InkWell(
                          onTap: () =>
                              ref.read(themeColorProvider.notifier).state =
                                  color,
                          customBorder: const CircleBorder(),
                          child: Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: color,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: seed == color
                                    ? colors.onSurface
                                    : Colors.transparent,
                                width: 2.5,
                              ),
                            ),
                            child: seed == color
                                ? const Icon(Icons.check, color: Colors.white)
                                : null,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 24),
        Text(
          'PLAYDROP  •  POWERED BY GAMERPOWER',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: colors.onSurfaceVariant,
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.1,
          ),
        ),
      ],
    );
  }

  String _colorName(Color color) {
    if (color == _colors[0]) return 'violet';
    if (color == _colors[1]) return 'green';
    if (color == _colors[2]) return 'coral';
    if (color == _colors[3]) return 'blue';
    if (color == _colors[4]) return 'pink';
    return 'gold';
  }
}

class GiveawayDetailScreen extends ConsumerWidget {
  const GiveawayDetailScreen({required this.giveaway, super.key});

  final Giveaway giveaway;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final saved = ref.watch(savedGiveawaysProvider).contains(giveaway.id);

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            pinned: true,
            expandedHeight: 280,
            title: const Text('Giveaway details'),
            actions: [
              IconButton(
                tooltip: saved ? 'Remove from saved' : 'Save giveaway',
                onPressed: () => _toggleSaved(ref),
                icon: Icon(saved ? Icons.bookmark : Icons.bookmark_outline),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: _GiveawayImage(
                imageUrl: giveaway.thumbnail,
                borderRadius: BorderRadius.zero,
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(22, 24, 22, 40),
            sliver: SliverList.list(
              children: [
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    _InfoPill(
                      label: giveaway.type,
                      icon: Icons.category_outlined,
                    ),
                    _InfoPill(
                      label: giveaway.worth,
                      icon: Icons.redeem_outlined,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Text(
                  giveaway.title,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                    height: 1.12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  giveaway.description,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: colors.onSurfaceVariant,
                    height: 1.55,
                  ),
                ),
                const SizedBox(height: 26),
                _DetailRow(
                  icon: Icons.devices_outlined,
                  label: 'Platforms',
                  value: giveaway.platforms,
                ),
                _DetailRow(
                  icon: Icons.event_outlined,
                  label: 'Ends',
                  value: giveaway.endDate,
                ),
                if (giveaway.instructions.isNotEmpty) ...[
                  const SizedBox(height: 16),
                  Text(
                    'How to claim',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    giveaway.instructions,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: colors.onSurfaceVariant,
                      height: 1.55,
                    ),
                  ),
                ],
                const SizedBox(height: 28),
                FilledButton.icon(
                  onPressed: () => openGiveaway(context, giveaway),
                  icon: const Icon(Icons.open_in_new),
                  label: const Text('Get this giveaway'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _toggleSaved(WidgetRef ref) {
    final current = ref.read(savedGiveawaysProvider);
    final updated = Set<int>.from(current);
    if (!updated.add(giveaway.id)) {
      updated.remove(giveaway.id);
    }
    ref.read(savedGiveawaysProvider.notifier).state = updated;
  }
}

class _PageHeading extends StatelessWidget {
  const _PageHeading({
    this.eyebrow = 'LEVEL UP YOUR LIBRARY',
    this.title = 'Free games,\nfound for you.',
    this.subtitle = 'Fresh drops. Zero cost. All yours.',
  });

  final String eyebrow;
  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(22, 25, 22, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            eyebrow,
            style: TextStyle(
              color: colors.primary,
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineLarge?.copyWith(
              fontWeight: FontWeight.w900,
              height: 1.02,
              letterSpacing: -1.1,
            ),
          ),
          const SizedBox(height: 9),
          Text(
            subtitle,
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(color: colors.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _FeaturedBanner extends StatelessWidget {
  const _FeaturedBanner({required this.onBrowse});

  final VoidCallback onBrowse;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [colors.primary, colors.tertiary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      padding: const EdgeInsets.all(22),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: .2),
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: const Text(
                    'THE DROP ZONE',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.2,
                    ),
                  ),
                ),
                const SizedBox(height: 14),
                const Text(
                  'Your next\nfavorite is free.',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 23,
                    fontWeight: FontWeight.w900,
                    height: 1.06,
                  ),
                ),
                const SizedBox(height: 14),
                TextButton(
                  onPressed: onBrowse,
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('Browse giveaways'),
                      SizedBox(width: 6),
                      Icon(Icons.arrow_forward, size: 16),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          const Icon(
            Icons.sports_esports_rounded,
            color: Colors.white,
            size: 68,
          ),
        ],
      ),
    );
  }
}

Widget _giveawayGridSliver(
  BuildContext context,
  List<Giveaway> giveaways, {
  required String emptyMessage,
  String emptyTitle = 'No giveaways found',
  IconData emptyIcon = Icons.search_off_rounded,
}) {
  if (giveaways.isEmpty) {
    return _messageSliver(
      context,
      icon: emptyIcon,
      title: emptyTitle,
      message: emptyMessage,
    );
  }

  return SliverPadding(
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
    sliver: SliverGrid(
      delegate: SliverChildBuilderDelegate(
        (context, index) => _GiveawayCard(giveaway: giveaways[index]),
        childCount: giveaways.length,
      ),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        mainAxisExtent: 324,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
    ),
  );
}

Widget _loadingSliver(BuildContext context) {
  return const SliverFillRemaining(
    hasScrollBody: false,
    child: Center(child: CircularProgressIndicator()),
  );
}

Widget _messageSliver(
  BuildContext context, {
  required IconData icon,
  required String title,
  required String message,
  Widget? action,
}) {
  final colors = Theme.of(context).colorScheme;
  return SliverFillRemaining(
    hasScrollBody: false,
    child: Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 48, color: colors.primary),
            const SizedBox(height: 14),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
            if (action != null) ...[const SizedBox(height: 16), action],
          ],
        ),
      ),
    ),
  );
}

class _GiveawayCard extends ConsumerWidget {
  const _GiveawayCard({required this.giveaway});

  final Giveaway giveaway;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = Theme.of(context).colorScheme;
    final saved = ref.watch(savedGiveawaysProvider).contains(giveaway.id);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => GiveawayDetailScreen(giveaway: giveaway),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 156,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  _GiveawayImage(
                    imageUrl: giveaway.thumbnail,
                    borderRadius: BorderRadius.zero,
                  ),
                  Positioned(
                    left: 11,
                    top: 11,
                    child: _InfoPill(
                      label: giveaway.worth,
                      icon: Icons.redeem_outlined,
                      filled: true,
                    ),
                  ),
                  Positioned(
                    right: 5,
                    top: 5,
                    child: IconButton(
                      tooltip: saved ? 'Remove from saved' : 'Save giveaway',
                      onPressed: () => _toggleSaved(ref),
                      style: IconButton.styleFrom(
                        backgroundColor: colors.surface.withValues(alpha: .92),
                      ),
                      icon: Icon(
                        saved ? Icons.bookmark : Icons.bookmark_outline,
                        color: saved ? colors.primary : colors.onSurface,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 12, 14, 12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      giveaway.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        height: 1.15,
                      ),
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Icon(
                          Icons.devices_outlined,
                          size: 15,
                          color: colors.onSurfaceVariant,
                        ),
                        const SizedBox(width: 5),
                        Expanded(
                          child: Text(
                            giveaway.platforms,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.labelMedium
                                ?.copyWith(color: colors.onSurfaceVariant),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: colors.primary,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _toggleSaved(WidgetRef ref) {
    final updated = Set<int>.from(ref.read(savedGiveawaysProvider));
    if (!updated.add(giveaway.id)) {
      updated.remove(giveaway.id);
    }
    ref.read(savedGiveawaysProvider.notifier).state = updated;
  }
}

class _GiveawayImage extends StatelessWidget {
  const _GiveawayImage({required this.imageUrl, required this.borderRadius});

  final String imageUrl;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return ClipRRect(
      borderRadius: borderRadius,
      child: imageUrl.isEmpty
          ? _placeholder(colors)
          : Image.network(
              imageUrl,
              fit: BoxFit.cover,
              webHtmlElementStrategy: WebHtmlElementStrategy.fallback,
              errorBuilder: (context, error, stackTrace) =>
                  _placeholder(colors),
            ),
    );
  }

  Widget _placeholder(ColorScheme colors) {
    return Container(
      color: colors.primaryContainer,
      alignment: Alignment.center,
      child: Icon(
        Icons.sports_esports_outlined,
        size: 42,
        color: colors.primary,
      ),
    );
  }
}

class _InfoPill extends StatelessWidget {
  const _InfoPill({
    required this.label,
    required this.icon,
    this.filled = false,
  });

  final String label;
  final IconData icon;
  final bool filled;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: filled
            ? colors.surface.withValues(alpha: .94)
            : colors.primaryContainer,
        borderRadius: BorderRadius.circular(30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.primary),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: colors.onSurface,
              fontSize: 11,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colors.primary),
          const SizedBox(width: 12),
          SizedBox(
            width: 88,
            child: Text(
              label,
              style: const TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: colors.onSurfaceVariant),
            ),
          ),
        ],
      ),
    );
  }
}
