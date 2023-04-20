import 'package:flutter/foundation.dart';

import '../extensions/bool_extensions.dart';

class Course extends ChangeNotifier {
  String id;
  String name;
  DateTime start;
  DateTime end;
  String professor;
  bool presence;
  bool absence;

  Course({
    required this.id,
    required this.name,
    required this.start,
    required this.end,
    required this.professor,
    required this.presence,
    required this.absence,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['ID'] ?? '',
      name: json['NAME'] ?? '',
      start: json['START'] != null
          ? DateTime.parse(json['START'])
          : DateTime.now(),
      end: json['END'] != null ? DateTime.parse(json['END']) : DateTime.now(),
      professor: json['PROFESSOR'] ?? '',
      presence: BoolHelper.parse(json['STUDENT_PRESENCE']),
      absence: BoolHelper.parse(json['STUDENT_ABSENCE']),
    );
  }

  fromJson(Map<String, dynamic> json) {
    id = json['ID'] ?? '';
    name = json['NAME'] ?? '';
    start =
        json['START'] != null ? DateTime.parse(json['START']) : DateTime.now();
    end = json['END'] != null ? DateTime.parse(json['END']) : DateTime.now();
    professor = json['PROFESSOR'] ?? '';
    presence = BoolHelper.parse(json['STUDENT_PRESENCE']);
    absence = BoolHelper.parse(json['STUDENT_ABSENCE']);
  }

  void update() {
    notifyListeners();
  }

  void updateFrom(Course couse) {
    id = couse.id.isEmpty ? id : couse.id;
    name = couse.name.isEmpty ? name : couse.name;
    start = couse.start;
    end = couse.end;
    professor = couse.professor.isEmpty ? professor : couse.professor;
    presence = couse.presence;
    absence = couse.absence;
    notifyListeners();
  }
}
