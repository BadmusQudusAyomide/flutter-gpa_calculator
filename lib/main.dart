import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'models/course.dart';

void main() {
  runApp(GPACalculatorApp());
}

class GPACalculatorApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: GPACalculator(),
    );
  }
}

class GPACalculator extends StatefulWidget {
  @override
  _GPACalculatorState createState() => _GPACalculatorState();
}

class _GPACalculatorState extends State<GPACalculator> {
  List<Course> courses = [];
  TextEditingController nameController = TextEditingController();
  TextEditingController creditsController = TextEditingController();
  String selectedGrade = 'A';
  String selectedSortOption = 'Name';

  @override
  void initState() {
    super.initState();
    loadCourses();
  }

  void saveCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> coursesString =
        courses.map((course) => json.encode(course.toMap())).toList();
    prefs.setStringList('courses', coursesString);
  }

  void loadCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? coursesString = prefs.getStringList('courses');
    if (coursesString != null) {
      setState(() {
        courses = coursesString
            .map((courseStr) => Course.fromMap(json.decode(courseStr)))
            .toList();
      });
    }
  }

  void addCourse() {
    if (nameController.text.isEmpty ||
        creditsController.text.isEmpty ||
        !['A', 'B', 'C', 'D', 'E', 'F'].contains(selectedGrade)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please fill all fields with valid data.')),
      );
      return;
    }

    setState(() {
      courses.add(Course(
        name: nameController.text,
        credits: int.parse(creditsController.text),
        grade: selectedGrade,
      ));
      nameController.clear();
      creditsController.clear();
      saveCourses();
    });
  }

  void editCourse(int index) {
    Course course = courses[index];
    nameController.text = course.name;
    creditsController.text = course.credits.toString();
    selectedGrade = course.grade;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Edit Course'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Course Name'),
              ),
              TextField(
                controller: creditsController,
                decoration: InputDecoration(labelText: 'Credits'),
                keyboardType: TextInputType.number,
              ),
              DropdownButton<String>(
                value: selectedGrade,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGrade = newValue!;
                  });
                },
                items: <String>['A', 'B', 'C', 'D', 'E', 'F']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                setState(() {
                  courses[index] = Course(
                    name: nameController.text,
                    credits: int.parse(creditsController.text),
                    grade: selectedGrade,
                  );
                  saveCourses();
                });
                Navigator.of(context).pop();
              },
              child: Text('Save'),
            ),
          ],
        );
      },
    );
  }

  void deleteCourse(int index) {
    setState(() {
      courses.removeAt(index);
      saveCourses();
    });
  }

  void sortCourses() {
    setState(() {
      if (selectedSortOption == 'Name') {
        courses.sort((a, b) => a.name.compareTo(b.name));
      } else if (selectedSortOption == 'Credits') {
        courses.sort((a, b) => a.credits.compareTo(b.credits));
      } else if (selectedSortOption == 'Grade') {
        courses.sort((a, b) => a.grade.compareTo(b.grade));
      }
    });
  }

  double calculateGPA() {
    double totalPoints = 0;
    int totalCredits = 0;
    for (var course in courses) {
      totalPoints += course.gradePoint * course.credits;
      totalCredits += course.credits;
    }
    return totalCredits == 0 ? 0 : totalPoints / totalCredits;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('GPA Calculator'),
        actions: [
          DropdownButton<String>(
            value: selectedSortOption,
            onChanged: (String? newValue) {
              setState(() {
                selectedSortOption = newValue!;
                sortCourses();
              });
            },
            items: <String>['Name', 'Credits', 'Grade']
                .map<DropdownMenuItem<String>>((String value) {
              return DropdownMenuItem<String>(
                value: value,
                child: Text(value),
              );
            }).toList(),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              children: [
                TextField(
                  controller: nameController,
                  decoration: InputDecoration(labelText: 'Course Name'),
                ),
                TextField(
                  controller: creditsController,
                  decoration: InputDecoration(labelText: 'Credits'),
                  keyboardType: TextInputType.number,
                ),
                DropdownButton<String>(
                  value: selectedGrade,
                  onChanged: (String? newValue) {
                    setState(() {
                      selectedGrade = newValue!;
                    });
                  },
                  items: <String>['A', 'B', 'C', 'D', 'E', 'F']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(value),
                    );
                  }).toList(),
                ),
                SizedBox(height: 10),
                ElevatedButton(
                  onPressed: addCourse,
                  child: Text('Add Course'),
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                return ListTile(
                  title: Text(
                      '${courses[index].name} - ${courses[index].credits} credits'),
                  subtitle: Text('Grade: ${courses[index].grade}'),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.edit),
                        onPressed: () => editCourse(index),
                      ),
                      IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () => deleteCourse(index),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Text('GPA: ${calculateGPA().toStringAsFixed(2)}'),
          ),
        ],
      ),
    );
  }
}
