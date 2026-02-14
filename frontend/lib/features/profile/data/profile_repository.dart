import 'package:supabase_flutter/supabase_flutter.dart';
import '../domain/profile_model.dart';

/// Repository for developer profile CRUD against the Supabase `profiles` table.
class ProfileRepository {
  ProfileRepository({SupabaseClient? client})
      : _client = client ?? Supabase.instance.client;

  final SupabaseClient _client;

  /// Fetch the current user's profile.
  Future<ProfileModel?> getMyProfile() async {
    final userId = _client.auth.currentUser?.id;
    if (userId == null) return null;

    final data = await _client
        .from('profiles')
        .select()
        .eq('id', userId)
        .maybeSingle();

    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }

  /// Create or update the current user's profile (upsert).
  Future<ProfileModel> upsertProfile(ProfileModel profile) async {
    final data = await _client
        .from('profiles')
        .upsert(profile.toJson())
        .select()
        .single();

    return ProfileModel.fromJson(data);
  }

  /// Discover developers near a location, optionally filtered by tech.
  ///
  /// Uses a Supabase RPC function `nearby_profiles` (PostGIS).
  /// Falls back to a basic select if the RPC isn't set up yet.
  Future<List<ProfileModel>> discoverNearby({
    double? latitude,
    double? longitude,
    double radiusKm = 50,
    String? tech,
  }) async {
    try {
      // Try the PostGIS RPC first
      final result = await _client.rpc('nearby_profiles', params: {
        'lat': latitude ?? 0,
        'lng': longitude ?? 0,
        'radius_km': radiusKm,
        if (tech != null) 'filter_tech': tech,
      });

      return (result as List)
          .map((row) => ProfileModel.fromJson(row as Map<String, dynamic>))
          .toList();
    } catch (_) {
      // Fallback: basic query without geospatial filter
      var query = _client.from('profiles').select();
      if (tech != null) {
        query = query.contains('tech_stack', [tech]);
      }
      final data = await query.limit(20);

      return (data as List)
          .map((row) => ProfileModel.fromJson(row as Map<String, dynamic>))
          .toList();
    }
  }

  /// Get a profile by GitHub username.
  Future<ProfileModel?> getByUsername(String username) async {
    final data = await _client
        .from('profiles')
        .select()
        .eq('github_username', username)
        .maybeSingle();

    if (data == null) return null;
    return ProfileModel.fromJson(data);
  }
}
