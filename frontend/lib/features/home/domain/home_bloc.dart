import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import '../../profile/domain/profile_model.dart';
import '../../profile/data/profile_repository.dart';
import '../../connections/data/connection_repository.dart';

// ── Events ────────────────────────────────────────────────────

abstract class HomeEvent extends Equatable {
  const HomeEvent();
  @override
  List<Object?> get props => [];
}

class HomeLoadFeedEvent extends HomeEvent {
  const HomeLoadFeedEvent();
}

class HomeRefreshEvent extends HomeEvent {
  const HomeRefreshEvent();
}

class HomeSendConnectEvent extends HomeEvent {
  const HomeSendConnectEvent(this.profile);
  final ProfileModel profile;
  @override
  List<Object?> get props => [profile];
}

// ── States ────────────────────────────────────────────────────

abstract class HomeState extends Equatable {
  const HomeState();
  @override
  List<Object?> get props => [];
}

class HomeInitialState extends HomeState {
  const HomeInitialState();
}

class HomeLoadingState extends HomeState {
  const HomeLoadingState();
}

class HomeLoadedState extends HomeState {
  const HomeLoadedState({
    required this.profiles,
    this.connectingId,
    this.connectedIds = const {},
  });

  final List<ProfileModel> profiles;
  final String? connectingId; // profile currently being connected
  final Set<String> connectedIds; // profiles already connected

  @override
  List<Object?> get props => [profiles, connectingId, connectedIds];
}

class HomeErrorState extends HomeState {
  const HomeErrorState(this.message);
  final String message;
  @override
  List<Object?> get props => [message];
}

// ── BLoC ──────────────────────────────────────────────────────

class HomeBloc extends Bloc<HomeEvent, HomeState> {
  HomeBloc({
    required ProfileRepository profileRepository,
    required ConnectionRepository connectionRepository,
  })  : _profileRepo = profileRepository,
        _connectionRepo = connectionRepository,
        super(const HomeInitialState()) {
    on<HomeLoadFeedEvent>(_onLoadFeed);
    on<HomeRefreshEvent>(_onRefresh);
    on<HomeSendConnectEvent>(_onSendConnect);
  }

  final ProfileRepository _profileRepo;
  final ConnectionRepository _connectionRepo;

  Future<void> _onLoadFeed(
    HomeLoadFeedEvent event,
    Emitter<HomeState> emit,
  ) async {
    emit(const HomeLoadingState());
    try {
      final profiles = await _profileRepo.discoverNearby();
      emit(HomeLoadedState(profiles: profiles));
    } catch (e) {
      emit(HomeErrorState(e.toString()));
    }
  }

  Future<void> _onRefresh(
    HomeRefreshEvent event,
    Emitter<HomeState> emit,
  ) async {
    try {
      final profiles = await _profileRepo.discoverNearby();
      final currentConnected = state is HomeLoadedState
          ? (state as HomeLoadedState).connectedIds
          : <String>{};
      emit(HomeLoadedState(
        profiles: profiles,
        connectedIds: currentConnected,
      ));
    } catch (e) {
      emit(HomeErrorState(e.toString()));
    }
  }

  Future<void> _onSendConnect(
    HomeSendConnectEvent event,
    Emitter<HomeState> emit,
  ) async {
    if (state is! HomeLoadedState) return;
    final current = state as HomeLoadedState;

    // Show connecting state
    emit(HomeLoadedState(
      profiles: current.profiles,
      connectingId: event.profile.id,
      connectedIds: current.connectedIds,
    ));

    try {
      await _connectionRepo.sendRequest(targetId: event.profile.id);
      emit(HomeLoadedState(
        profiles: current.profiles,
        connectedIds: {...current.connectedIds, event.profile.id},
      ));
    } catch (e) {
      // Revert — show error but keep the feed
      emit(HomeLoadedState(
        profiles: current.profiles,
        connectedIds: current.connectedIds,
      ));
    }
  }
}
