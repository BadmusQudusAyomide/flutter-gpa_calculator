class Course {
  final String name;
  final double units;
  final double grade;

  Course(this.name, this.units, this.grade);

  @override
  String toString() {
    return '$name,$units,$grade';
  }

  static Course fromString(String courseString) {
    final parts = courseString.split(',');
    return Course(parts[0], double.parse(parts[1]), double.parse(parts[2]));
  }
}
