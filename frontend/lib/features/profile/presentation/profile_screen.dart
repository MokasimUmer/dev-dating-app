import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/theme/terminal_theme.dart';
import '../../auth/domain/auth_bloc.dart';
import '../../auth/domain/auth_event.dart';
import '../domain/profile_bloc.dart';
import '../domain/profile_model.dart';

/// User's own profile screen — shows real data from Supabase.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Load profile when screen is first built
    context.read<ProfileBloc>().add(const ProfileLoadEvent());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: TerminalColors.background,
      body: SafeArea(
        child: BlocBuilder<ProfileBloc, ProfileState>(
          builder: (context, state) {
            if (state is ProfileLoadingState) {
              return const Center(
                child: CircularProgressIndicator(
                  color: TerminalColors.green,
                ),
              );
            }

            if (state is ProfileLoadedState) {
              return _AuthenticatedProfile(
                profile: state.profile,
                connections: state.connections,
              );
            }

            if (state is ProfileErrorState) {
              return _UnauthenticatedProfile(
                errorMessage: state.message,
              );
            }

            // Initial or unauthenticated
            return const _UnauthenticatedProfile();
          },
        ),
      ),
    );
  }
}

// ── Authenticated Profile View ──────────────────────────────

class _AuthenticatedProfile extends StatelessWidget {
  const _AuthenticatedProfile({
    required this.profile,
    this.connections = 0,
  });

  final ProfileModel profile;
  final int connections;

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
    return RefreshIndicator(
      onRefresh: () async {
        context.read<ProfileBloc>().add(const ProfileRefreshEvent());
      },
      color: TerminalColors.green,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 8),

            // ── Header Row ────────────────────────────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Profile',
                  style: TextStyle(
                    fontFamily: 'Fira Code',
                    color: TerminalColors.green,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(
                        Icons.refresh,
                        color: TerminalColors.white,
                        size: 20,
                      ),
                      onPressed: () {
                        context
                            .read<ProfileBloc>()
                            .add(const ProfileRefreshEvent());
                      },
                    ),
                    IconButton(
                      icon: const Icon(
                        Icons.logout,
                        color: TerminalColors.red,
                        size: 20,
                      ),
                      onPressed: () {
                        context.read<AuthBloc>().add(const AuthLogoutEvent());
                      },
                    ),
                  ],
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ── Avatar ────────────────────────────────────
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: TerminalColors.green,
                  width: 3,
                ),
                color: TerminalColors.surface,
              ),
              child: ClipOval(
                child: profile.avatarUrl != null
                    ? Image.network(
                        profile.avatarUrl!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => const Center(
                          child: Icon(
                            Icons.person,
                            color: TerminalColors.green,
                            size: 48,
                          ),
                        ),
                      )
                    : const Center(
                        child: Icon(
                          Icons.person,
                          color: TerminalColors.green,
                          size: 48,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 14),

            // ── Name + Username ────────────────────────────
            Text(
              profile.displayName ?? profile.githubUsername,
              style: const TextStyle(
                color: TerminalColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '@${profile.githubUsername}',
              style: const TextStyle(
                color: TerminalColors.dimGreen,
                fontSize: 14,
              ),
            ),

            const SizedBox(height: 12),

            // ── Bio ───────────────────────────────────────
            Text(
              profile.bio ?? 'No bio set',
              style: const TextStyle(
                color: TerminalColors.grey,
                fontSize: 13,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 20),

            // ── Stats Row ─────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: TerminalColors.surface,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _ProfileStat(
                      value: '${profile.xp}', label: 'XP'),
                  const _Divider(),
                  _ProfileStat(
                      value: '$_rankEmoji',
                      label: profile.rank),
                  const _Divider(),
                  _ProfileStat(
                      value: '${profile.githubRepos.length}',
                      label: 'Repos'),
                  const _Divider(),
                  _ProfileStat(
                      value: '$connections', label: 'Connections'),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // ── Action Buttons ────────────────────────────
            Row(
              children: [
                Expanded(
                  child: _ActionButton(
                    label: 'Edit Profile',
                    icon: Icons.edit_outlined,
                    filled: true,
                    onTap: () {
                      // TODO: Navigate to edit profile screen
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ActionButton(
                    label: 'Share',
                    icon: Icons.share_outlined,
                    filled: false,
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Share @${profile.githubUsername}',
                            style: const TextStyle(
                              fontFamily: 'Fira Code',
                              color: TerminalColors.background,
                            ),
                          ),
                          backgroundColor: TerminalColors.green,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ── Tech Stack Section ────────────────────────
            const _SectionHeader(title: 'Tech Stack'),
            const SizedBox(height: 8),
            if (profile.techStack.isEmpty)
              const _EmptyState(
                icon: Icons.code,
                message: 'No tech stack detected yet',
              )
            else
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: profile.techStack.map((tech) {
                  return Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: TerminalColors.green.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color:
                            TerminalColors.dimGreen.withValues(alpha: 0.4),
                        width: 0.5,
                      ),
                    ),
                    child: Text(
                      tech,
                      style: const TextStyle(
                        color: TerminalColors.green,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 24),

            // ── Repos Section ─────────────────────────────
            const _SectionHeader(title: 'Top Repositories'),
            const SizedBox(height: 8),
            if (profile.githubRepos.isEmpty)
              const _EmptyState(
                icon: Icons.folder_outlined,
                message: 'No repositories found',
              )
            else
              ...profile.githubRepos.take(5).map((repo) {
                final name = repo['name'] ?? 'Unnamed';
                final desc = repo['description'] ?? '';
                final lang = repo['language'] ?? '';
                final stars = repo['stars'] ?? 0;

                return Container(
                  margin: const EdgeInsets.only(bottom: 8),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: TerminalColors.surface,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.folder,
                              color: TerminalColors.cyan, size: 16),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              name.toString(),
                              style: const TextStyle(
                                color: TerminalColors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          if (stars > 0)
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: TerminalColors.yellow, size: 14),
                                const SizedBox(width: 2),
                                Text(
                                  '$stars',
                                  style: const TextStyle(
                                    color: TerminalColors.yellow,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                        ],
                      ),
                      if (desc.toString().isNotEmpty) ...[
                        const SizedBox(height: 4),
                        Text(
                          desc.toString(),
                          style: const TextStyle(
                            color: TerminalColors.grey,
                            fontSize: 12,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                      if (lang.toString().isNotEmpty) ...[
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              width: 8,
                              height: 8,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: TerminalColors.green,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              lang.toString(),
                              style: const TextStyle(
                                color: TerminalColors.dimGreen,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                );
              }),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

// ── Unauthenticated Profile View ────────────────────────────

class _UnauthenticatedProfile extends StatelessWidget {
  const _UnauthenticatedProfile({this.errorMessage});
  final String? errorMessage;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const SizedBox(height: 8),

          // ── Header Row ────────────────────────────────
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Profile',
                style: TextStyle(
                  fontFamily: 'Fira Code',
                  color: TerminalColors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.settings_outlined,
                  color: TerminalColors.white,
                ),
                onPressed: () {},
              ),
            ],
          ),

          const SizedBox(height: 20),

          // ── Avatar ────────────────────────────────────
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: TerminalColors.green,
                width: 3,
              ),
              color: TerminalColors.surface,
            ),
            child: const Center(
              child: Icon(
                Icons.person,
                color: TerminalColors.green,
                size: 48,
              ),
            ),
          ),

          const SizedBox(height: 14),

          // ── Name ────────────────────────────────────
          const Text(
            'DevDate User',
            style: TextStyle(
              color: TerminalColors.white,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            '@your_username',
            style: TextStyle(
              color: TerminalColors.dimGreen,
              fontSize: 14,
            ),
          ),

          const SizedBox(height: 12),

          const Text(
            'Sign in with GitHub to see your profile',
            style: TextStyle(
              color: TerminalColors.grey,
              fontSize: 13,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),

          const SizedBox(height: 20),

          // ── Stats (empty) ─────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(vertical: 16),
            decoration: BoxDecoration(
              color: TerminalColors.surface,
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ProfileStat(value: '0', label: 'XP'),
                _Divider(),
                _ProfileStat(value: '🌱', label: 'Intern'),
                _Divider(),
                _ProfileStat(value: '0', label: 'Projects'),
                _Divider(),
                _ProfileStat(value: '0', label: 'Stars'),
              ],
            ),
          ),

          const SizedBox(height: 32),

          // ── Sign In CTA ───────────────────────────────
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: TerminalColors.surface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: TerminalColors.green.withValues(alpha: 0.3),
              ),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.login,
                  color: TerminalColors.green,
                  size: 32,
                ),
                const SizedBox(height: 10),
                const Text(
                  'Connect GitHub',
                  style: TextStyle(
                    color: TerminalColors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Sign in to populate your profile with repos, stats, and tech stack.',
                  style: TextStyle(
                    color: TerminalColors.grey,
                    fontSize: 12,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    context
                        .read<AuthBloc>()
                        .add(const AuthLoginWithGitHubEvent());
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: TerminalColors.green,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Sign in with GitHub',
                      style: TextStyle(
                        color: TerminalColors.background,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }
}

// ── Sub-widgets ──────────────────────────────────────────────

class _ProfileStat extends StatelessWidget {
  const _ProfileStat({required this.value, required this.label});
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: TerminalColors.white,
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(
            color: TerminalColors.grey,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

class _Divider extends StatelessWidget {
  const _Divider();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 0.5,
      height: 30,
      color: TerminalColors.dimGreen.withValues(alpha: 0.3),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: filled ? TerminalColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: TerminalColors.dimGreen.withValues(alpha: 0.4),
            width: 0.5,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: TerminalColors.white, size: 16),
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: TerminalColors.white,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});
  final String title;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          color: TerminalColors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.icon, required this.message});
  final IconData icon;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: TerminalColors.surface,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        children: [
          Icon(icon, color: TerminalColors.grey, size: 28),
          const SizedBox(height: 8),
          Text(
            message,
            style: const TextStyle(
              color: TerminalColors.grey,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
