import 'package:flutter/material.dart';
import 'GradesModel.dart';
import 'Grade.dart';

class GradeForm extends StatefulWidget {
  final Grade? grade;

  const GradeForm({super.key, required this.grade});

  @override
  GradeFormState createState() => GradeFormState();
}

class GradeFormState extends State<GradeForm> {
  final _sidController = TextEditingController();
  final _gradeController = TextEditingController();
  GradesModel gradesModel = GradesModel();

  @override
  void initState() {
    super.initState();
    if (widget.grade != null) {
      _sidController.text = widget.grade!.sid;
      _gradeController.text = widget.grade!.grade;
    }
  }

  void _saveGrade() {
    if (widget.grade != null) {
      Grade updatedGrade = Grade(
        id: widget.grade!.id,
        sid: _sidController.text,
        grade: _gradeController.text.toUpperCase(),
      );
      gradesModel.updateGrade(updatedGrade);
    } else {
      Grade newGrade = Grade(
        id: null,
        sid: _sidController.text,
        grade: _gradeController.text.toUpperCase(),
      );
      gradesModel.insertGrade(newGrade);
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Grade Form'),
      ),
      body: Column(
        children: [
          TextField(
            controller: _sidController,
            decoration: const InputDecoration(hintText: '\t\t\tStudent ID'),
          ),
          TextField(
            controller: _gradeController,
            decoration: const InputDecoration(hintText: '\t\t\tGrade'),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _saveGrade,
        child: const Icon(Icons.save),
      ),
    );
  }
}