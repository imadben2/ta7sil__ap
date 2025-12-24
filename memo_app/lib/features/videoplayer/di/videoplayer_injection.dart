import 'package:get_it/get_it.dart';
import '../presentation/bloc/video_player_bloc.dart';

/// Register video player dependencies
///
/// Call this function during app initialization to register
/// video player related dependencies with GetIt.
void registerVideoPlayerDependencies(GetIt sl) {
  // Register VideoPlayerBloc as a factory (new instance each time)
  // This allows multiple video players to coexist independently
  sl.registerFactory<VideoPlayerBloc>(() => VideoPlayerBloc());
}

/// Unregister video player dependencies
///
/// Call this if you need to clean up video player registrations.
void unregisterVideoPlayerDependencies(GetIt sl) {
  if (sl.isRegistered<VideoPlayerBloc>()) {
    sl.unregister<VideoPlayerBloc>();
  }
}
