// made by: Mrblueskyai

/// Custom exception class for Alarmplayer errors
class AlarmplayerException implements Exception {
  /// Error message describing what went wrong
  final String message;
  
  /// Optional error code for categorizing errors
  final String? code;
  
  /// Optional additional details about the error
  final dynamic details;

  AlarmplayerException(this.message, {this.code, this.details});

  @override
  String toString() {
    if (code != null) {
      return 'AlarmplayerException($code): $message';
    }
    return 'AlarmplayerException: $message';
  }
}
// made by: Mrblueskyai
