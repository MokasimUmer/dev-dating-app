import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../profile/domain/profile_model.dart';
import '../../profile/data/profile_repository.dart';
import '../../connections/data/connection_repository.dart';

// ── Events ────────────────────────────────────────────────────

abstract class DiscoverEvent extends Equatable {
  const DiscoverEvent();
  @override
  List<Object?> get props => [];
}

class DiscoverLoadEvent extends DiscoverEvent {
  const DiscoverLoadEvent();
}

class DiscoverSearchEvent extends DiscoverEvent {
  const DiscoverSearchEvent(this.query);
  final String query;
  @override
  List<Object?> get props => [query];
}

class DiscoverFilterByTechEvent extends DiscoverEvent {
  const DiscoverFilterByTechEvent(this.tech);
  final String? tech; // null means "All"
  @override
  List<Object?> get props => [tech];
}

class DiscoverConnectEvent extends DiscoverEvent {
  const DiscoverConnectEvent(this.profile);
  final ProfileModel profile;
  @override
  List<Object?> get props => [profile];
}

// ── States ────────────────────────────────────────────────────

abstract class DiscoverState extends Equatable {
  const DiscoverState();
  @override
  List<Object?> get props => [];
}

class DiscoverInitialState extends DiscoverState {
  const DiscoverInitialState();
}

class DiscoverLoadingState extends DiscoverState {
  const DiscoverLoadingState();
}

class DiscoverLoadedState extends DiscoverState {
  const DiscoverLoadedState({
    required this.allProfiles,
    required this.filteredProfiles,
    this.selectedTech,
    this.searchQuery = '',
    this.connectedIds = const {},
  });

  final List<ProfileModel> allProfiles;
  final List<ProfileModel> filteredProfiles;
  final String? selectedTech;
  final String searchQuery;
  final Set<String> connectedIds;

  @override
  List<Object?> get props =>
      [allProfiles, filteredProfiles, selectedTech, searchQuery, connectedIds];
}

class DiscoverErrorState extends DiscoverState {
  const DiscoverErrorState(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────

class DiscoverBloc extends Bloc<DiscoverEvent, DiscoverState> {
  DiscoverBloc({
    required ProfileRepository profileRepository,
    required ConnectionRepository connectionRepository,
  })  : _profileRepo = profileRepository,
        _connectionRepo = connectionRepository,
        super(const DiscoverInitialState()) {
    on<DiscoverLoadEvent>(_onLoad);
    on<DiscoverSearchEvent>(_onSearch);
    on<DiscoverFilterByTechEvent>(_onFilterByTech);
    on<DiscoverConnectEvent>(_onConnect);
  }

  final ProfileRepository _profileRepo;
  final ConnectionRepository _connectionRepo;

  Future<void> _onLoad(
    DiscoverLoadEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    emit(const DiscoverLoadingState());
    try {
      final profiles = await _profileRepo.discoverNearby();
      emit(DiscoverLoadedState(
        allProfiles: profiles,
        filteredProfiles: profiles,
      ));
    } catch (e) {
      emit(DiscoverErrorState(e.toString()));
    }
  }

  void _onSearch(
    DiscoverSearchEvent event,
    Emitter<DiscoverState> emit,
  ) {
    if (state is! DiscoverLoadedState) return;
    final current = state as DiscoverLoadedState;

    final filtered = _applyFilters(
      current.allProfiles,
      event.query,
      current.selectedTech,
    );

    emit(DiscoverLoadedState(
      allProfiles: current.allProfiles,
      filteredProfiles: filtered,
      selectedTech: current.selectedTech,
      searchQuery: event.query,
      connectedIds: current.connectedIds,
    ));
  }

  void _onFilterByTech(
    DiscoverFilterByTechEvent event,
    Emitter<DiscoverState> emit,
  ) {
    if (state is! DiscoverLoadedState) return;
    final current = state as DiscoverLoadedState;

    final filtered = _applyFilters(
      current.allProfiles,
      current.searchQuery,
      event.tech,
    );

    emit(DiscoverLoadedState(
      allProfiles: current.allProfiles,
      filteredProfiles: filtered,
      selectedTech: event.tech,
      searchQuery: current.searchQuery,
      connectedIds: current.connectedIds,
    ));
  }

  Future<void> _onConnect(
    DiscoverConnectEvent event,
    Emitter<DiscoverState> emit,
  ) async {
    if (state is! DiscoverLoadedState) return;
    final current = state as DiscoverLoadedState;

    try {
      await _connectionRepo.sendRequest(targetId: event.profile.id);
      emit(DiscoverLoadedState(
        allProfiles: current.allProfiles,
        filteredProfiles: current.filteredProfiles,
        selectedTech: current.selectedTech,
        searchQuery: current.searchQuery,
        connectedIds: {...current.connectedIds, event.profile.id},
      ));
    } catch (_) {
      // Silently fail — keep current state
    }
  }

  List<ProfileModel> _applyFilters(
    List<ProfileModel> profiles,
    String query,
    String? tech,
  ) {
    var result = profiles;

    // Filter by tech
    if (tech != null && tech.isNotEmpty) {
      result = result
          .where((p) => p.techStack
              .any((t) => t.toLowerCase() == tech.toLowerCase()))
          .toList();
    }

    // Filter by search query
    if (query.isNotEmpty) {
      final q = query.toLowerCase();
      result = result
          .where((p) =>
              p.githubUsername.toLowerCase().contains(q) ||
              (p.displayName?.toLowerCase().contains(q) ?? false) ||
              p.techStack.any((t) => t.toLowerCase().contains(q)))
          .toList();
    }

    return result;
  }
}
