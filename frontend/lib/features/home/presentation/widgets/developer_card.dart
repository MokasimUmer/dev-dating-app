import 'package:flutter/material.dart';
import '../../../../core/theme/terminal_theme.dart';
import '../../../profile/domain/profile_model.dart';

/// Instagram-style developer profile card for the feed.
class DeveloperCard extends StatelessWidget {
  const DeveloperCard({
    super.key,
    required this.profile,
    this.onTap,
    this.onConnect,
    this.isConnected = false,
    this.isConnecting = false,
  });

  final ProfileModel profile;
  final VoidCallback? onTap;
  final VoidCallback? onConnect;
  final bool isConnected;
  final bool isConnecting;

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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: TerminalColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: TerminalColors.dimGreen.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header: Avatar + Username + Rank ──────────────
            Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: TerminalColors.green,
                        width: 2,
                      ),
                    ),
                    child: ClipOval(
                      child: profile.avatarUrl != null
                          ? Image.network(
                              profile.avatarUrl!,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _avatarFallback(),
                            )
                          : _avatarFallback(),
                    ),
                  ),
                  const SizedBox(width: 10),
                  // Name + Username
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                profile.displayName ??
                                    profile.githubUsername,
                                style: const TextStyle(
                                  color: TerminalColors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 14,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 4),
                            Text(_rankEmoji, style: const TextStyle(fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '@${profile.githubUsername}',
                          style: const TextStyle(
                            color: TerminalColors.dimGreen,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Connect button
                  _ConnectButton(
                    onTap: isConnected || isConnecting ? null : onConnect,
                    isConnected: isConnected,
                    isConnecting: isConnecting,
                  ),
                ],
              ),
            ),

            // ── Bio ──────────────────────────────────────────
            if (profile.bio != null && profile.bio!.isNotEmpty)
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14),
                child: Text(
                  profile.bio!,
                  style: const TextStyle(
                    color: TerminalColors.grey,
                    fontSize: 13,
                    height: 1.4,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

            const SizedBox(height: 10),

            // ── Tech Stack Chips ─────────────────────────────
            if (profile.techStack.isNotEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 14),
                child: Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: profile.techStack
                      .take(6)
                      .map((tech) => _TechChip(label: tech))
                      .toList(),
                ),
              ),

            const SizedBox(height: 12),

            // ── Stats Row ────────────────────────────────────
            Container(
              padding: const EdgeInsets.symmetric(
                  horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: TerminalColors.background.withValues(alpha: 0.5),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.star_outline,
                    value: '${profile.xp}',
                    label: 'XP',
                  ),
                  _StatItem(
                    icon: Icons.military_tech_outlined,
                    value: profile.rank,
                    label: 'Rank',
                  ),
                  _StatItem(
                    icon: Icons.code,
                    value: '${profile.githubRepos.length}',
                    label: 'Repos',
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _avatarFallback() {
    return Container(
      color: TerminalColors.inputBar,
      child: Center(
        child: Text(
          profile.githubUsername.isNotEmpty
              ? profile.githubUsername[0].toUpperCase()
              : '?',
          style: const TextStyle(
            color: TerminalColors.green,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class _ConnectButton extends StatelessWidget {
  const _ConnectButton({
    this.onTap,
    this.isConnected = false,
    this.isConnecting = false,
  });
  final VoidCallback? onTap;
  final bool isConnected;
  final bool isConnecting;

  @override
  Widget build(BuildContext context) {
    if (isConnecting) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: TerminalColors.surface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: TerminalColors.dimGreen, width: 0.5),
        ),
        child: const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            color: TerminalColors.green,
          ),
        ),
      );
    }

    if (isConnected) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        decoration: BoxDecoration(
          color: TerminalColors.green.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: TerminalColors.green.withValues(alpha: 0.3),
            width: 0.5,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check, color: TerminalColors.green, size: 13),
            SizedBox(width: 3),
            Text(
              'Sent',
              style: TextStyle(
                color: TerminalColors.green,
                fontWeight: FontWeight.bold,
                fontSize: 11,
              ),
            ),
          ],
        ),
      );
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: TerminalColors.green,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Text(
          'Connect',
          style: TextStyle(
            color: TerminalColors.background,
            fontWeight: FontWeight.bold,
            fontSize: 11,
          ),
        ),
      ),
    );
  }
}

class _TechChip extends StatelessWidget {
  const _TechChip({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: TerminalColors.green.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: TerminalColors.dimGreen.withValues(alpha: 0.4),
          width: 0.5,
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: TerminalColors.green,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({
    required this.icon,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: TerminalColors.cyan, size: 14),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: TerminalColors.white,
                fontWeight: FontWeight.bold,
                fontSize: 13,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(
            color: TerminalColors.grey,
            fontSize: 10,
          ),
        ),
      ],
    );
  }
}
