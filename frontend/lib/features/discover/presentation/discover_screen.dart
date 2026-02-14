import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/terminal_theme.dart';
import '../domain/discover_bloc.dart';
import '../../profile/domain/profile_model.dart';

/// Discover screen with search, tech filter chips, and real Supabase data.
class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final _searchController = TextEditingController();

  static const _techFilters = [
    'All',
    'Python',
    'Dart',
    'Rust',
    'TypeScript',
    'Go',
    'Java',
    'C++',
    'Swift',
    'Kotlin',
    'JavaScript',
  ];

  @override
  void initState() {
    super.initState();
    context.read<DiscoverBloc>().add(const DiscoverLoadEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // ── Search Bar ──────────────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _searchController,
                onChanged: (query) {
                  context
                      .read<DiscoverBloc>()
                      .add(DiscoverSearchEvent(query));
                },
                style: const TextStyle(
                  color: TerminalColors.white,
                  fontSize: 14,
                ),
                cursorColor: TerminalColors.green,
                decoration: InputDecoration(
                  hintText: 'Search developers...',
                  hintStyle: const TextStyle(color: TerminalColors.grey),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: TerminalColors.grey,
                  ),
                  filled: true,
                  fillColor: TerminalColors.surface,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                ),
              ),
            ),

            // ── Tech Filter Chips ───────────────────────────
            BlocBuilder<DiscoverBloc, DiscoverState>(
              buildWhen: (prev, curr) {
                if (prev is DiscoverLoadedState &&
                    curr is DiscoverLoadedState) {
                  return prev.selectedTech != curr.selectedTech;
                }
                return true;
              },
              builder: (context, state) {
                final selectedTech = state is DiscoverLoadedState
                    ? state.selectedTech
                    : null;

                return SizedBox(
                  height: 40,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    itemCount: _techFilters.length,
                    itemBuilder: (context, index) {
                      final tech = _techFilters[index];
                      final isSelected = (selectedTech == tech) ||
                          (tech == 'All' && selectedTech == null);

                      return Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 4),
                        child: GestureDetector(
                          onTap: () {
                            context.read<DiscoverBloc>().add(
                                  DiscoverFilterByTechEvent(
                                    tech == 'All' ? null : tech,
                                  ),
                                );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? TerminalColors.green
                                  : TerminalColors.surface,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: isSelected
                                    ? TerminalColors.green
                                    : TerminalColors.dimGreen
                                        .withValues(alpha: 0.3),
                                width: 0.5,
                              ),
                            ),
                            child: Text(
                              tech,
                              style: TextStyle(
                                color: isSelected
                                    ? TerminalColors.background
                                    : TerminalColors.white,
                                fontSize: 12,
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),

            const SizedBox(height: 8),

            // ── Results Grid ────────────────────────────────
            Expanded(
              child: BlocBuilder<DiscoverBloc, DiscoverState>(
                builder: (context, state) {
                  if (state is DiscoverLoadingState) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: TerminalColors.green,
                      ),
                    );
                  }

                  if (state is DiscoverErrorState) {
                    return Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.cloud_off,
                              color: TerminalColors.grey, size: 48),
                          const SizedBox(height: 12),
                          const Text(
                            'Failed to load developers',
                            style: TextStyle(
                              color: TerminalColors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => context
                                .read<DiscoverBloc>()
                                .add(const DiscoverLoadEvent()),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 20, vertical: 8),
                              decoration: BoxDecoration(
                                color: TerminalColors.green,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Text(
                                'Retry',
                                style: TextStyle(
                                  color: TerminalColors.background,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }

                  if (state is DiscoverLoadedState) {
                    final filtered = state.filteredProfiles;

                    if (filtered.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.search_off,
                              color: TerminalColors.grey,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No developers found',
                              style: TextStyle(
                                color: TerminalColors.grey,
                                fontSize: 14,
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return GridView.builder(
                      padding: const EdgeInsets.all(12),
                      gridDelegate:
                          const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.78,
                        crossAxisSpacing: 10,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: filtered.length,
                      itemBuilder: (context, index) {
                        final profile = filtered[index];
                        final isConnected =
                            state.connectedIds.contains(profile.id);
                        return _DiscoverTile(
                          profile: profile,
                          isConnected: isConnected,
                          onConnect: () {
                            context
                                .read<DiscoverBloc>()
                                .add(DiscoverConnectEvent(profile));
                          },
                        );
                      },
                    );
                  }

                  return const SizedBox.shrink();
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Compact developer tile for the grid view.
class _DiscoverTile extends StatelessWidget {
  const _DiscoverTile({
    required this.profile,
    this.isConnected = false,
    this.onConnect,
  });
  final ProfileModel profile;
  final bool isConnected;
  final VoidCallback? onConnect;

  String get _rankEmoji {
    switch (profile.rank.toLowerCase()) {
      case 'principal':
        return '👑';
      case 'staff':
        return '⭐';
      case 'senior':
        return '🔥';
      case 'junior':
        return '💻';
      default:
        return '🌱';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TerminalColors.surface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: TerminalColors.dimGreen.withValues(alpha: 0.2),
          width: 0.5,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 12),
          // Avatar
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: TerminalColors.inputBar,
              border: Border.all(
                color: TerminalColors.green.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: ClipOval(
              child: profile.avatarUrl != null
                  ? Image.network(
                      profile.avatarUrl!,
                      fit: BoxFit.cover,
                      width: 56,
                      height: 56,
                      errorBuilder: (_, __, ___) => _avatarFallback(),
                    )
                  : _avatarFallback(),
            ),
          ),
          const SizedBox(height: 8),
          // Name
          Text(
            profile.displayName ?? profile.githubUsername,
            style: const TextStyle(
              color: TerminalColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 2),
          Text(
            '@${profile.githubUsername}',
            style: const TextStyle(
              color: TerminalColors.grey,
              fontSize: 11,
            ),
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 6),
          // Rank badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: TerminalColors.green.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Text(
              '$_rankEmoji ${profile.rank}',
              style: const TextStyle(
                color: TerminalColors.green,
                fontSize: 11,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Tech chips (max 2)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Wrap(
              alignment: WrapAlignment.center,
              spacing: 4,
              children: profile.techStack.take(2).map((t) {
                return Text(
                  t,
                  style: const TextStyle(
                    color: TerminalColors.cyan,
                    fontSize: 10,
                  ),
                );
              }).toList(),
            ),
          ),
          const Spacer(),
          // Connect button
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 10),
            child: GestureDetector(
              onTap: isConnected ? null : onConnect,
              child: SizedBox(
                width: double.infinity,
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  decoration: BoxDecoration(
                    color: isConnected
                        ? TerminalColors.green.withValues(alpha: 0.1)
                        : TerminalColors.green.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(8),
                    border: isConnected
                        ? Border.all(
                            color:
                                TerminalColors.green.withValues(alpha: 0.3),
                            width: 0.5,
                          )
                        : null,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isConnected)
                        const Icon(Icons.check,
                            color: TerminalColors.green, size: 14),
                      if (isConnected) const SizedBox(width: 4),
                      Text(
                        isConnected ? 'Sent' : 'Connect',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: TerminalColors.green,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _avatarFallback() {
    return Center(
      child: Text(
        profile.githubUsername.isNotEmpty
            ? profile.githubUsername[0].toUpperCase()
            : '?',
        style: const TextStyle(
          color: TerminalColors.green,
          fontWeight: FontWeight.bold,
          fontSize: 22,
        ),
      ),
    );
  }
}
