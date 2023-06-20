// // GENERATED CODE - DO NOT MODIFY BY HAND
//
// part of 'times.dart';
//
// // **************************************************************************
// // JsonSerializableGenerator
// // **************************************************************************
//
// Punch _$PunchFromJson(Map<String, dynamic> json) => Punch(
//       $enumDecode(_$PunchTypeEnumMap, json['punchType']),
//       DateTime.parse(json['dateTime'] as String),
//     );
//
// Map<String, dynamic> _$PunchToJson(Punch instance) => <String, dynamic>{
//       'punchType': _$PunchTypeEnumMap[instance.punchType]!,
//       'dateTime': instance.dateTime.toIso8601String(),
//     };
//
// const _$PunchTypeEnumMap = {
//   PunchType.punchIn: 'punchIn',
//   PunchType.punchOut: 'punchOut',
// };
//
// Durations _$DurationsFromJson(Map<String, dynamic> json) => Durations()
//   ..duration = Duration(microseconds: json['duration'] as int)
//   ..times = (json['times'] as List<dynamic>)
//       .map((e) => Punch.fromJson(e as Map<String, dynamic>))
//       .toList();
//
// Map<String, dynamic> _$DurationsToJson(Durations instance) => <String, dynamic>{
//       'duration': instance.duration.inMicroseconds,
//       'times': instance.times,
//     };
//
// Times _$TimesFromJson(Map<String, dynamic> json) =>
//     Times()..currentId = json['currentId'] as String?;
//
// Map<String, dynamic> _$TimesToJson(Times instance) => <String, dynamic>{
//       'currentId': instance.currentId,
//     };
