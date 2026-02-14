import 'package:supabase_flutter/supabase_flutter.dart';

/// Model representing a connection/collab request between two developers.
class ConnectionModel {
  const ConnectionModel({
    required this.id,
    required this.requesterId,
    required this.targetId,
    required this.status,
    this.projectId,
    this.createdAt,
    // Joined profile fields (optional)
    this.requesterUsername,
    this.requesterAvatar,
    this.targetUsername,
    this.targetAvatar,
  });

  final String id;
  final String requesterId;
  final String targetId;
  final String status; // 'pending', 'accepted', 'rejected'
  final String? projectId;
  final DateTime? createdAt;
  final String? requesterUsername;
  final String? requesterAvatar;
  final String? targetUsername;
  final String? targetAvatar;

  factory ConnectionModel.fromJson(Map<String, dynamic> json) {
    return ConnectionModel(
      id: json['id'] as String,
      requesterId: json['requester_id'] as String,
      targetId: json['target_id'] as String,
      status: json['status'] as String? ?? 'pending',
      projectId: json['project_id'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      requesterUsername: json['requester']?['github_username'] as String?,
      requesterAvatar: json['requester']?['avatar_url'] as String?,
      targetUsername: json['target']?['github_username'] as String?,
      targetAvatar: json['target']?['avatar_url'] as String?,
    );
  }
}

/// Repository for managing developer connections (collab requests).
class ConnectionRepository {
  ConnectionRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Send a collab request to another developer by their profile ID.
  Future<ConnectionModel> sendRequest({
    required String targetId,
    String? projectName,
  }) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) throw Exception('Not authenticated');

    final data = await _client.from('connections').insert({
      'requester_id': userId,
      'target_id': targetId,
      'status': 'pending',
    }).select().single();

    return ConnectionModel.fromJson(data);
  }

  /// Send a collab request by username (looks up profile first).
  Future<ConnectionModel> sendRequestByUsername({
    required String username,
    String? projectName,
  }) async {
    // Look up the target user's profile
    final profile = await _client
        .from('profiles')
        .select('id')
        .eq('github_username', username)
        .maybeSingle();

    if (profile == null) {
      throw Exception('User @$username not found');
    }

    return sendRequest(
      targetId: profile['id'] as String,
      projectName: projectName,
    );
  }

  /// Accept or reject a connection request.
  Future<void> updateStatus({
    required String connectionId,
    required String status, // 'accepted' or 'rejected'
  }) async {
    await _client.from('connections').update({
      'status': status,
    }).eq('id', connectionId);
  }

  /// Get all connections for the current user (sent and received).
  Future<List<ConnectionModel>> getMyConnections() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from('connections')
        .select('*, requester:profiles!requester_id(github_username, avatar_url), target:profiles!target_id(github_username, avatar_url)')
        .or('requester_id.eq.$userId,target_id.eq.$userId')
        .order('created_at', ascending: false);

    return (data as List)
        .map((row) => ConnectionModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Get pending incoming requests.
  Future<List<ConnectionModel>> getPendingRequests() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return [];

    final data = await _client
        .from('connections')
        .select('*, requester:profiles!requester_id(github_username, avatar_url)')
        .eq('target_id', userId)
        .eq('status', 'pending')
        .order('created_at', ascending: false);

    return (data as List)
        .map((row) => ConnectionModel.fromJson(row as Map<String, dynamic>))
        .toList();
  }

  /// Check if a connection already exists between current user and target.
  Future<bool> isConnected(String targetId) async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return false;

    final data = await _client
        .from('connections')
        .select('id')
        .or('and(requester_id.eq.$userId,target_id.eq.$targetId),and(requester_id.eq.$targetId,target_id.eq.$userId)')
        .maybeSingle();

    return data != null;
  }
}
