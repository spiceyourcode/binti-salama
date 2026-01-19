import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../utils/logger.dart';

/// Service for checking network connectivity
class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _isConnected = true; // Default to true (optimistic)

  ConnectivityService() {
    _initConnectivity();
  }

  /// Initialize connectivity checking
  Future<void> _initConnectivity() async {
    try {
      // Check initial connectivity status
      final result = await _connectivity.checkConnectivity();
      _isConnected = _hasInternetConnection(result);

      // Listen for connectivity changes
      _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
        (List<ConnectivityResult> results) {
          _isConnected = _hasInternetConnection(results);
          AppLogger.info('Connectivity changed: ${_isConnected ? "Connected" : "Disconnected"}');
        },
      );
    } catch (e) {
      AppLogger.warning('Error initializing connectivity: $e');
      _isConnected = true; // Default to connected on error
    }
  }

  /// Check if device has internet connection
  bool _hasInternetConnection(List<ConnectivityResult> results) {
    // If any connection type is available, consider it connected
    return results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);
  }

  /// Check if device is currently connected to internet
  Future<bool> isConnected() async {
    try {
      final result = await _connectivity.checkConnectivity();
      _isConnected = _hasInternetConnection(result);
      return _isConnected;
    } catch (e) {
      AppLogger.warning('Error checking connectivity: $e');
      return _isConnected; // Return last known state
    }
  }

  /// Get current connectivity status (synchronous, uses last known state)
  bool get isConnectedSync => _isConnected;

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
  }
}



