import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';

// part 'times.g.dart';

enum PunchType {
  punchIn,
  punchOut;
}

@JsonSerializable()
class Punch {
  Punch(this.punchType, this.dateTime);

  PunchType punchType;
  DateTime dateTime;
}

@JsonSerializable()
class Durations {
  /// How long this item has been going for
  Duration duration = Duration.zero;

  /// The times that were clocked in and out
  List<Punch> times = [];
}

@JsonSerializable()
class Times with ChangeNotifier {
  static final Times _instance = Times._internal();

  /// This is a private constructor for this class
  Times._internal();

  factory Times() => _instance;

  String? currentId;

  final Map<DateTime, Map<String, Durations>> days = {};

  Map<String, Durations> getDay(DateTime day) {
    // Add if it doesn't contain
    if (!days.containsKey(day)) {
      days[day] = {};
    }

    return days[day]!;
  }

  void setState([VoidCallback? fn]) {
    if (fn != null) fn();
    notifyListeners();
  }
}