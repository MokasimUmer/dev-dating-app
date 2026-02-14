import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/terminal_theme.dart';
import '../domain/home_bloc.dart';
import 'widgets/developer_card.dart';
import 'widgets/stories_bar.dart';

/// Instagram-style home feed with developer cards — loaded from Supabase.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    context.read<HomeBloc>().add(const HomeLoadFeedEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ── App Bar ─────────────────────────────────────
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Row(
                  children: [
                    const Text(
                      'DevDate',
                      style: TextStyle(
                        fontFamily: 'Fira Code',
                        color: TerminalColors.green,
                        fontWeight: FontWeight.bold,
                        fontSize: 22,
                      ),
                    ),
                    const Spacer(),
                    IconButton(
                      icon: const Icon(
                        Icons.notifications_none,
                        color: TerminalColors.white,
                      ),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.chat_bubble_outline,
                        color: TerminalColors.white,
                      ),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ),

            // ── Stories Bar ─────────────────────────────────
            const SliverToBoxAdapter(
              child: StoriesBar(),
            ),

            // ── Divider ────────────────────────────────────
            SliverToBoxAdapter(
              child: Divider(
                color: TerminalColors.surface,
                height: 1,
                thickness: 0.5,
              ),
            ),

            // ── Feed ────────────────────────────────────────
            BlocBuilder<HomeBloc, HomeState>(
              builder: (context, state) {
                if (state is HomeLoadingState) {
                  return const SliverFillRemaining(
                    child: Center(
                      child: CircularProgressIndicator(
                        color: TerminalColors.green,
                      ),
                    ),
                  );
                }

                if (state is HomeErrorState) {
                  return SliverFillRemaining(
                    child: Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.cloud_off,
                            color: TerminalColors.grey,
                            size: 48,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Could not load feed',
                            style: TextStyle(
                              color: TerminalColors.grey,
                              fontSize: 14,
                            ),
                          ),
                          const SizedBox(height: 12),
                          GestureDetector(
                            onTap: () => context
                                .read<HomeBloc>()
                                .add(const HomeRefreshEvent()),
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
                    ),
                  );
                }

                if (state is HomeLoadedState) {
                  if (state.profiles.isEmpty) {
                    return SliverFillRemaining(
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.people_outline,
                              color: TerminalColors.grey,
                              size: 48,
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'No developers yet',
                              style: TextStyle(
                                color: TerminalColors.grey,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Be the first to join!',
                              style: TextStyle(
                                color: TerminalColors.grey,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        final profile = state.profiles[index];
                        final isConnected =
                            state.connectedIds.contains(profile.id);
                        final isConnecting =
                            state.connectingId == profile.id;

                        return DeveloperCard(
                          profile: profile,
                          isConnected: isConnected,
                          isConnecting: isConnecting,
                          onConnect: () {
                            context
                                .read<HomeBloc>()
                                .add(HomeSendConnectEvent(profile));
                          },
                        );
                      },
                      childCount: state.profiles.length,
                    ),
                  );
                }

                return const SliverToBoxAdapter(child: SizedBox.shrink());
              },
            ),

            // Bottom padding
            const SliverToBoxAdapter(
              child: SizedBox(height: 16),
            ),
          ],
        ),
      ),
    );
  }
}
