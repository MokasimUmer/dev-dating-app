import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/theme/terminal_theme.dart';
import '../../domain/home_bloc.dart';

/// Stories row showing active developers from the feed.
class StoriesBar extends StatelessWidget {
  const StoriesBar({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 100,
      child: BlocBuilder<HomeBloc, HomeState>(
        builder: (context, state) {
          if (state is HomeLoadedState && state.profiles.isNotEmpty) {
            final stories = state.profiles.take(10).toList();
            return ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: stories.length + 1, // +1 for "You" bubble
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const _StoryBubble(
                    name: 'Your Story',
                    initial: '+',
                    isYou: true,
                  );
                }
                final profile = stories[index - 1];
                return _StoryBubble(
                  name: profile.githubUsername,
                  initial: profile.githubUsername.isNotEmpty
                      ? profile.githubUsername[0].toUpperCase()
                      : '?',
                  avatarUrl: profile.avatarUrl,
                  isYou: false,
                );
              },
            );
          }

          // Fallback — show placeholder bubbles while loading
          return ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 12),
            itemCount: 6,
            itemBuilder: (context, index) {
              if (index == 0) {
                return const _StoryBubble(
                  name: 'Your Story',
                  initial: '+',
                  isYou: true,
                );
              }
              return _StoryBubble(
                name: '...',
                initial: '?',
                isYou: false,
                isPlaceholder: true,
              );
            },
          );
        },
      ),
    );
  }
}

class _StoryBubble extends StatelessWidget {
  const _StoryBubble({
    required this.name,
    required this.initial,
    this.avatarUrl,
    this.isYou = false,
    this.isPlaceholder = false,
  });

  final String name;
  final String initial;
  final String? avatarUrl;
  final bool isYou;
  final bool isPlaceholder;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 6),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Gradient ring
          Container(
            width: 64,
            height: 64,
            padding: const EdgeInsets.all(2.5),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: isYou || isPlaceholder
                  ? null
                  : const LinearGradient(
                      colors: [
                        TerminalColors.green,
                        TerminalColors.cyan,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              border: isYou || isPlaceholder
                  ? Border.all(
                      color: isPlaceholder
                          ? TerminalColors.surface
                          : TerminalColors.grey,
                      width: 1,
                    )
                  : null,
            ),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: TerminalColors.surface,
              ),
              child: ClipOval(
                child: _buildContent(),
              ),
            ),
          ),
          const SizedBox(height: 6),
          SizedBox(
            width: 64,
            child: Text(
              isYou ? 'Your Story' : name,
              style: TextStyle(
                color: isYou || isPlaceholder
                    ? TerminalColors.grey
                    : TerminalColors.white,
                fontSize: 11,
              ),
              textAlign: TextAlign.center,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    if (isYou) {
      return const Center(
        child: Icon(
          Icons.add,
          color: TerminalColors.green,
          size: 24,
        ),
      );
    }

    if (avatarUrl != null && !isPlaceholder) {
      return Image.network(
        avatarUrl!,
        fit: BoxFit.cover,
        width: 64,
        height: 64,
        errorBuilder: (_, __, ___) => _initialFallback(),
      );
    }

    return _initialFallback();
  }

  Widget _initialFallback() {
    return Center(
      child: Text(
        initial,
        style: TextStyle(
          color: isPlaceholder ? TerminalColors.grey : TerminalColors.green,
          fontWeight: FontWeight.bold,
          fontSize: 20,
        ),
      ),
    );
  }
}
