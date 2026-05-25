import 'dart:async';
import 'package:flutter/foundation.dart';

class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final _syncQueue = <Function()>[];
  bool _isSyncing = false;

  /// Adds a task to the queue and starts processing if not already doing so.
  void enqueue(Future<void> Function() task) {
    _syncQueue.add(task);
    _processQueue();
  }

  Future<void> _processQueue() async {
    if (_isSyncing || _syncQueue.isEmpty) return;
    
    _isSyncing = true;
    
    while (_syncQueue.isNotEmpty) {
      final task = _syncQueue.removeAt(0);
      try {
        await task();
      } catch (e) {
        debugPrint('Sync task failed: $e');
        // In a robust system, we would add it back to the queue or save it for later
        // For now, we drop it to avoid infinite loops, but log the error.
      }
    }
    
    _isSyncing = false;
  }
}
