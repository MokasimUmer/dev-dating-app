import 'package:equatable/equatable.dart';

/// A developer profile entity.
class ProfileModel extends Equatable {
  const ProfileModel({
    required this.id,
    required this.githubUsername,
    this.displayName,
    this.avatarUrl,
    this.bio,
    this.techStack = const [],
    this.githubRepos = const [],
    this.xp = 0,
    this.rank = 'Intern',
    this.latitude,
    this.longitude,
    this.createdAt,
  });

  final String id;
  final String githubUsername;
  final String? displayName;
  final String? avatarUrl;
  final String? bio;
  final List<String> techStack;
  final List<dynamic> githubRepos;
  final int xp;
  final String rank;
  final double? latitude;
  final double? longitude;
  final DateTime? createdAt;

  /// Create from Supabase row.
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] as String,
      githubUsername: json['github_username'] as String,
      displayName: json['display_name'] as String?,
      avatarUrl: json['avatar_url'] as String?,
      bio: json['bio'] as String?,
      techStack: (json['tech_stack'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      githubRepos: (json['github_repos'] as List<dynamic>?) ?? [],
      xp: (json['xp'] as int?) ?? 0,
      rank: (json['rank'] as String?) ?? 'Intern',
      latitude: (json['location_lat'] as num?)?.toDouble(),
      longitude: (json['location_lng'] as num?)?.toDouble(),
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert to JSON for Supabase insert/update.
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'github_username': githubUsername,
      'display_name': displayName,
      'avatar_url': avatarUrl,
      'bio': bio,
      'tech_stack': techStack,
      'github_repos': githubRepos,
      'xp': xp,
      'rank': rank,
      'location_lat': latitude,
      'location_lng': longitude,
    };
  }

  @override
  List<Object?> get props => [
        id,
        githubUsername,
        displayName,
        avatarUrl,
        bio,
        techStack,
        xp,
        rank,
      ];
}
