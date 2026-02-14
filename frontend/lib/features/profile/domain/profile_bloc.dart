import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../data/profile_repository.dart';
import 'profile_model.dart';
import '../../connections/data/connection_repository.dart';

// ── Events ────────────────────────────────────────────────────

abstract class ProfileEvent extends Equatable {
  const ProfileEvent();
  @override
  List<Object?> get props => [];
}

class ProfileLoadEvent extends ProfileEvent {
  const ProfileLoadEvent();
}

class ProfileRefreshEvent extends ProfileEvent {
  const ProfileRefreshEvent();
}

class ProfileUpdateBioEvent extends ProfileEvent {
  const ProfileUpdateBioEvent(this.bio);
  final String bio;
  @override
  List<Object?> get props => [bio];
}

class ProfileUpdateTechStackEvent extends ProfileEvent {
  const ProfileUpdateTechStackEvent(this.techStack);
  final List<String> techStack;
  @override
  List<Object?> get props => [techStack];
}

// ── States ────────────────────────────────────────────────────

abstract class ProfileState extends Equatable {
  const ProfileState();
  @override
  List<Object?> get props => [];
}

class ProfileInitialState extends ProfileState {
  const ProfileInitialState();
}

class ProfileLoadingState extends ProfileState {
  const ProfileLoadingState();
}

class ProfileLoadedState extends ProfileState {
  const ProfileLoadedState({
    required this.profile,
    this.connections = 0,
  });

  final ProfileModel profile;
  final int connections;

  @override
  List<Object?> get props => [profile, connections];
}

class ProfileNotAuthenticatedState extends ProfileState {
  const ProfileNotAuthenticatedState();
}

class ProfileErrorState extends ProfileState {
  const ProfileErrorState(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────

class ProfileBloc extends Bloc<ProfileEvent, ProfileState> {
  ProfileBloc({
    required ProfileRepository profileRepository,
    required ConnectionRepository connectionRepository,
  })  : _profileRepo = profileRepository,
        _connectionRepo = connectionRepository,
        super(const ProfileInitialState()) {
    on<ProfileLoadEvent>(_onLoad);
    on<ProfileRefreshEvent>(_onRefresh);
    on<ProfileUpdateBioEvent>(_onUpdateBio);
    on<ProfileUpdateTechStackEvent>(_onUpdateTechStack);
  }

  final ProfileRepository _profileRepo;
  final ConnectionRepository _connectionRepo;

  Future<void> _onLoad(
    ProfileLoadEvent event,
    Emitter<ProfileState> emit,
  ) async {
    emit(const ProfileLoadingState());
    await _loadProfile(emit);
  }

  Future<void> _onRefresh(
    ProfileRefreshEvent event,
    Emitter<ProfileState> emit,
  ) async {
    await _loadProfile(emit);
  }

  Future<void> _loadProfile(Emitter<ProfileState> emit) async {
    try {
      final profile = await _profileRepo.getMyProfile();
      if (profile == null) {
        emit(const ProfileNotAuthenticatedState());
        return;
      }

      // Count connections
      int connectionCount = 0;
      try {
        final connections = await _connectionRepo.getMyConnections();
        connectionCount = connections
            .where((c) => c.status == 'accepted')
            .length;
      } catch (_) {
        // Non-critical
      }

      emit(ProfileLoadedState(
        profile: profile,
        connections: connectionCount,
      ));
    } catch (e) {
      emit(ProfileErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateBio(
    ProfileUpdateBioEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoadedState) return;
    final current = (state as ProfileLoadedState).profile;

    try {
      final updated = await _profileRepo.upsertProfile(
        ProfileModel(
          id: current.id,
          githubUsername: current.githubUsername,
          displayName: current.displayName,
          avatarUrl: current.avatarUrl,
          bio: event.bio,
          techStack: current.techStack,
          githubRepos: current.githubRepos,
          xp: current.xp,
          rank: current.rank,
        ),
      );
      emit(ProfileLoadedState(
        profile: updated,
        connections: (state as ProfileLoadedState).connections,
      ));
    } catch (e) {
      emit(ProfileErrorState(e.toString()));
    }
  }

  Future<void> _onUpdateTechStack(
    ProfileUpdateTechStackEvent event,
    Emitter<ProfileState> emit,
  ) async {
    if (state is! ProfileLoadedState) return;
    final current = (state as ProfileLoadedState).profile;

    try {
      final updated = await _profileRepo.upsertProfile(
        ProfileModel(
          id: current.id,
          githubUsername: current.githubUsername,
          displayName: current.displayName,
          avatarUrl: current.avatarUrl,
          bio: current.bio,
          techStack: event.techStack,
          githubRepos: current.githubRepos,
          xp: current.xp,
          rank: current.rank,
        ),
      );
      emit(ProfileLoadedState(
        profile: updated,
        connections: (state as ProfileLoadedState).connections,
      ));
    } catch (e) {
      emit(ProfileErrorState(e.toString()));
    }
  }
}
