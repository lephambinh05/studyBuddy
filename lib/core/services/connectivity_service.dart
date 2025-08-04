import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

enum ConnectivityStatus { connected, disconnected, unknown }

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  /// Stream để lắng nghe thay đổi kết nối
  Stream<ConnectivityResult> get connectivityStream => _connectivity.onConnectivityChanged.map((results) => results.first);

  /// Kiểm tra kết nối hiện tại
  Future<bool> get isConnected async {
    final results = await _connectivity.checkConnectivity();
    return results.isNotEmpty && results.first != ConnectivityResult.none;
  }

  /// Lấy trạng thái kết nối hiện tại
  Future<ConnectivityStatus> get connectivityStatus async {
    final results = await _connectivity.checkConnectivity();
    if (results.isEmpty) return ConnectivityStatus.unknown;
    
    final result = results.first;
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return ConnectivityStatus.connected;
      case ConnectivityResult.none:
        return ConnectivityStatus.disconnected;
      default:
        return ConnectivityStatus.unknown;
    }
  }

  /// Bắt đầu lắng nghe thay đổi kết nối
  void startListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final result = results.first;
      print('Connectivity changed: $result');
    });
  }

  /// Dừng lắng nghe
  void stopListening() {
    _connectivitySubscription?.cancel();
    _connectivitySubscription = null;
  }

  /// Dispose
  void dispose() {
    stopListening();
  }
}

// Riverpod providers
final connectivityServiceProvider = Provider<ConnectivityService>((ref) {
  final service = ConnectivityService();
  service.startListening();
  ref.onDispose(() => service.dispose());
  return service;
});

final connectivityStatusProvider = StreamProvider<ConnectivityStatus>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream.map((result) {
    switch (result) {
      case ConnectivityResult.wifi:
      case ConnectivityResult.mobile:
      case ConnectivityResult.ethernet:
        return ConnectivityStatus.connected;
      case ConnectivityResult.none:
        return ConnectivityStatus.disconnected;
      default:
        return ConnectivityStatus.unknown;
    }
  });
});

final isConnectedProvider = StreamProvider<bool>((ref) {
  final service = ref.watch(connectivityServiceProvider);
  return service.connectivityStream.map((result) => result != ConnectivityResult.none);
});
