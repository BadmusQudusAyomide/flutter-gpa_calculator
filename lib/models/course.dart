class Course {
  String name;
  int credits;
  String grade;

  Course({required this.name, required this.credits, required this.grade});

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'credits': credits,
      'grade': grade,
    };
  }

  factory Course.fromMap(Map<String, dynamic> map) {
    return Course(
      name: map['name'],
      credits: map['credits'],
      grade: map['grade'],
    );
  }

  double get gradePoint {
    switch (grade) {
      case 'A':
        return 5.0;
      case 'B':
        return 4.0;
      case 'C':
        return 3.0;
      case 'D':
        return 2.0;
      case 'E':
        return 1.0;
      case 'F':
      default:
        return 0.0;
    }
  }
}
