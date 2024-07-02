import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'models/course.dart'; // Importing the Course class

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'GPA Calculator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<Course> courses = [];
  double gpa = 0.0;

  @override
  void initState() {
    super.initState();
    _loadCourses();
  }

  void _loadCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      courses = (prefs.getStringList('courses') ?? [])
          .map((course) => Course.fromString(course))
          .toList();
      _calculateGPA();
    });
  }

  void _saveCourses() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setStringList('courses', courses.map((course) => course.toString()).toList());
  }

  void _calculateGPA() {
    if (courses.isEmpty) {
      setState(() {
        gpa = 0.0;
      });
      return;
    }

    double totalPoints = 0.0;
    double totalUnits = 0.0;
    for (var course in courses) {
      totalPoints += course.grade * course.units;
      totalUnits += course.units;
    }

    setState(() {
      gpa = totalPoints / totalUnits;
    });
  }

  void _addCourse() {
    showDialog(
      context: context,
      builder: (context) {
        return AddCourseDialog(
          onAdd: (course) {
            setState(() {
              courses.add(course);
              _calculateGPA();
              _saveCourses();
            });
          },
        );
      },
    );
  }

  void _deleteCourse(int index) {
    setState(() {
      courses.removeAt(index);
      _calculateGPA();
      _saveCourses();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GPA Calculator'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Current GPA: ${gpa.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: courses.length,
              itemBuilder: (context, index) {
                final course = courses[index];
                return ListTile(
                  title: Text('${course.name} (${course.units} units)'),
                  subtitle: Text('Grade: ${course.grade}'),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () => _deleteCourse(index),
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: ElevatedButton(
              onPressed: _addCourse,
              child: const Text('Add Course'),
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Made by Badmus Qudus Ayomide',
            style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class AddCourseDialog extends StatefulWidget {
  final void Function(Course) onAdd;

  const AddCourseDialog({Key? key, required this.onAdd}) : super(key: key);

  @override
  _AddCourseDialogState createState() => _AddCourseDialogState();
}

class _AddCourseDialogState extends State<AddCourseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _unitsController = TextEditingController();
  String? _selectedGrade;

  final Map<String, double> _grades = {
    'A': 5.0,
    'B': 4.0,
    'C': 3.0,
    'D': 2.0,
    'E': 1.0,
    'F': 0.0,
  };

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add Course'),
      content: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextFormField(
              controller: _nameController,
              decoration: const InputDecoration(labelText: 'Course Name'),
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter a course name';
                }
                return null;
              },
            ),
            TextFormField(
              controller: _unitsController,
              decoration: const InputDecoration(labelText: 'Units'),
              keyboardType: TextInputType.number,
              validator: (value) {
                if (value == null || value.isEmpty) {
                  return 'Please enter the number of units';
                }
                if (double.tryParse(value) == null) {
                  return 'Please enter a valid number';
                }
                return null;
              },
            ),
            DropdownButtonFormField<String>(
              value: _selectedGrade,
              decoration: const InputDecoration(labelText: 'Grade'),
              items: _grades.keys
                  .map((grade) => DropdownMenuItem(
                value: grade,
                child: Text(grade),
              ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  _selectedGrade = value;
                });
              },
              validator: (value) {
                if (value == null) {
                  return 'Please select a grade';
                }
                return null;
              },
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              final name = _nameController.text;
              final units = double.parse(_unitsController.text);
              final grade = _grades[_selectedGrade]!;
              final course = Course(name, units, grade);
              widget.onAdd(course);
              Navigator.of(context).pop();
            }
          },
          child: const Text('Add'),
        ),
      ],
    );
  }
}
