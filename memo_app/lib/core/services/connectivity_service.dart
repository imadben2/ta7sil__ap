import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';

/// Service for monitoring network connectivity with stream-based updates
///
/// This service provides real-time connectivity status through a broadcast stream
/// and complements the existing NetworkInfo service
class ConnectivityService {
  final Connectivity _connectivity;
  StreamController<bool>? _connectivityController;
  StreamSubscription<List<ConnectivityResult>>? _subscription;

  ConnectivityService(this._connectivity);

  /// Stream that emits connectivity status changes
  ///
  /// Emits `true` when connected, `false` when disconnected
  Stream<bool> get onConnectivityChanged => _connectivityController!.stream;

  /// Initialize the service and start listening to connectivity changes
  Future<void> init() async {
    _connectivityController = StreamController<bool>.broadcast();

    // Listen to connectivity changes
    _subscription = _connectivity.onConnectivityChanged.listen((results) {
      final isConnected = results.any((result) => result != ConnectivityResult.none);

      debugPrint('[ConnectivityService] Connectivity changed: $isConnected (results: $results)');
      _connectivityController!.add(isConnected);
    });

    // Emit initial connectivity status
    final initialStatus = await checkConnectivity();
    debugPrint('[ConnectivityService] Initial connectivity: $initialStatus');
  }

  /// Check current connectivity status
  ///
  /// Returns `true` if connected to any network (WiFi, mobile, ethernet, etc.)
  Future<bool> checkConnectivity() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return results.any((result) => result != ConnectivityResult.none);
    } catch (e) {
      debugPrint('[ConnectivityService] Error checking connectivity: $e');
      return false;
    }
  }

  /// Dispose the service and clean up resources
  void dispose() {
    _subscription?.cancel();
    _connectivityController?.close();
    debugPrint('[ConnectivityService] Disposed');
  }
}
