import 'package:uuid/uuid.dart';

enum DetectionStatus {
  pending,
  confirmed,
  ignored,
  duplicate,
}

class DetectedTransaction {
  final String id;
  final String fingerprint;
  final String packageName;
  final String notificationTitle;
  final String notificationText;
  final double amount;
  final String? senderName;
  final DateTime timestamp;
  final double confidenceScore;
  final DetectionStatus status;

  DetectedTransaction({
    String? id,
    required this.fingerprint,
    required this.packageName,
    required this.notificationTitle,
    required this.notificationText,
    required this.amount,
    this.senderName,
    required this.timestamp,
    required this.confidenceScore,
    this.status = DetectionStatus.pending,
  }) : id = id ?? const Uuid().v4();

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fingerprint': fingerprint,
      'package_name': packageName,
      'notification_title': notificationTitle,
      'notification_text': notificationText,
      'amount': amount,
      'sender_name': senderName,
      'timestamp': timestamp.toIso8601String(),
      'confidence_score': confidenceScore,
      'status': status.name,
    };
  }

  factory DetectedTransaction.fromMap(Map<String, dynamic> map) {
    return DetectedTransaction(
      id: map['id'] as String,
      fingerprint: map['fingerprint'] as String,
      packageName: map['package_name'] as String,
      notificationTitle: map['notification_title'] as String,
      notificationText: map['notification_text'] as String,
      amount: (map['amount'] as num).toDouble(),
      senderName: map['sender_name'] as String?,
      timestamp: DateTime.parse(map['timestamp'] as String),
      confidenceScore: (map['confidence_score'] as num).toDouble(),
      status: DetectionStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => DetectionStatus.pending,
      ),
    );
  }

  DetectedTransaction copyWith({
    String? id,
    String? fingerprint,
    String? packageName,
    String? notificationTitle,
    String? notificationText,
    double? amount,
    String? senderName,
    DateTime? timestamp,
    double? confidenceScore,
    DetectionStatus? status,
  }) {
    return DetectedTransaction(
      id: id ?? this.id,
      fingerprint: fingerprint ?? this.fingerprint,
      packageName: packageName ?? this.packageName,
      notificationTitle: notificationTitle ?? this.notificationTitle,
      notificationText: notificationText ?? this.notificationText,
      amount: amount ?? this.amount,
      senderName: senderName ?? this.senderName,
      timestamp: timestamp ?? this.timestamp,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      status: status ?? this.status,
    );
  }
}
