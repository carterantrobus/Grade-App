import 'package:charts_flutter_new/flutter.dart' as charts;
import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:io';
import 'package:csv/csv.dart';
import 'package:file_picker/file_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'Grade.dart';
import 'GradeSearch.dart';
import 'GradesModel.dart';
import 'GradeForm.dart';

class ListGrades extends StatefulWidget {
  const ListGrades({super.key});

  @override
  ListGradesState createState() => ListGradesState();
}

enum SortOption { increasingSid, decreasingSid, increasingGrade, decreasingGrade }

class ListGradesState extends State<ListGrades> {
  dynamic _selectedIndex;
  List<Grade> grades = [];
  List<Grade> filteredGrades = [];
  late SortOption _selectedOption = SortOption.increasingSid;

  GradesModel gradesModel = GradesModel();

  @override
  void initState() {
    super.initState();
    refreshList();
  }

  void refreshList() async {
    List<Grade> temp = await gradesModel.getAllGrades();
    setState(() {
      grades = temp;
      filteredGrades = temp;
    });
  }

  void _editGrade(Grade grade) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GradeForm(grade: grade),
      ),
    ).then((value) {
      refreshList();
    });
  }

  void _deleteGrade(int id) {
    gradesModel.deleteGradeById(id);
    refreshList();
  }

  void _addGrade() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const GradeForm(grade: null),
      ),
    ).then((value) {
      refreshList();
    });
  }
  
  void _sortList(SortOption option) {
    setState(() {
      _selectedOption = option;
      switch (option) {
        case SortOption.increasingSid:
          grades.sort((a, b) => a.sid.compareTo(b.sid));
          break;
        case SortOption.decreasingSid:
          grades.sort((a, b) => b.sid.compareTo(a.sid));
          break;  
        case SortOption.increasingGrade:
          grades.sort((a, b) => a.grade.compareTo(b.grade));
          break;
        case SortOption.decreasingGrade:
          grades.sort((a, b) => b.grade.compareTo(a.grade));
          break;
      }
    });
  }

  List<charts.Series<Grade, String>> _createChartData() {
    List<Grade> data = List.from(grades);
    data.sort((a, b) => a.grade.compareTo(b.grade));
    var gradeCounts = <String, int>{};
    for (var grade in data) {
      if (gradeCounts.containsKey(grade.grade)) {
        gradeCounts[grade.grade] = gradeCounts[grade.grade]! + 1;
      } else {
        gradeCounts[grade.grade] = 1;
      }
    }
    List<Grade> chartData = [];
    gradeCounts.forEach((key, value) {
      chartData.add(Grade(sid: key, grade: value.toString()));
    });

    return [
      charts.Series<Grade, String> (
        id: 'Grades',
        domainFn: (Grade grade, _) => grade.sid,
        measureFn: (Grade grade, _) => int.parse(grade.grade),
        data: chartData,
      )
    ];
  }

  void _importCSV() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv'],
    );

    if (result != null && result.files.isNotEmpty) {
      try {
        File file = File(result.files.single.path!);
        String csvString = await file.readAsString();
        List<List<dynamic>> csvData = const CsvToListConverter().convert(csvString);

        for (var row in csvData) {
          if (row.length == 2) {
            Grade newGrade = Grade(sid: row[0].toString(), grade: row[1].toString());
            gradesModel.insertGrade(newGrade);
          } else {
            print("Invalid data format in CSV: $row");
          }
        }
        refreshList();
      } catch (e) {
        print("Error importing CSV: $e");
      }
    } else {
      print("No file selected or empty file list.");
    }
  }

  // this is one of the extra features I added, it allows the user to download the list of grades in a csv file onto their device.
  void _exportCSV() async {
    List<List<dynamic>> csvData = [];
    for (var grade in grades) {
      csvData.add([grade.sid, grade.grade]);
    }
    String csv = const ListToCsvConverter().convert(csvData);
    try {
      final directory = await getExternalStorageDirectory();
      if (directory == null) {
        print('Unable to access external storage directory.');
        return;
      }
      final path = directory.path;
      final file = File('$path/grades.csv');
      await file.writeAsString(csv);
      print('CSV file successfully exported to $path/grades.csv');
    } catch (e) {
      print('Error exporting CSV file: $e');
    }
  }

  // And this is the second extra feature I made which allows the user to search any grade by student id.
  void _searchGradeBySid(String query) {
    List<Grade> searchResult = grades.where((grade) {
      return grade.sid.toLowerCase().contains(query.toLowerCase());
    }).toList();
    setState(() {
      filteredGrades = searchResult;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('List of Grades'),
        actions: [
          IconButton(
              onPressed: () {
                showSearch(
                    context: context,
                    delegate: GradeSearchDelegate(filteredGrades, _searchGradeBySid),
                );
              },
              icon: const Icon(Icons.search),
          ),
          IconButton(
              onPressed: () {
                _importCSV();
              },
              icon: const Icon(Icons.upload)
          ),
          IconButton(
              onPressed: () {
                _exportCSV();
              },
              icon: const Icon(Icons.download),
          ),
          IconButton(
            onPressed: () {
              showDialog(
                  context: context,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      content: SizedBox(
                        width: 300,
                        height: 300,
                        child: charts.BarChart(
                          _createChartData(),
                          animate: true,
                        ),
                      ),
                    );
                  });
              },
              icon: const Icon(Icons.bar_chart),
          ),
          PopupMenuButton<SortOption>(
            onSelected: _sortList,
            itemBuilder: (BuildContext context) => <PopupMenuEntry<SortOption>>[
              const PopupMenuItem<SortOption>(
                value: SortOption.increasingSid,
                child: Text('Increasing SID'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.decreasingSid,
                child: Text('Decreasing SID'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.increasingGrade,
                child: Text('Increasing Grade'),
              ),
              const PopupMenuItem<SortOption>(
                value: SortOption.decreasingGrade,
                child: Text('Decreasing Grade'),
              ),
            ],
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addGrade,
        child: const Icon(Icons.add),
      ),
      body: ListView.builder(
        itemCount: grades.length,
        itemBuilder: (context, index) {
          return Dismissible(
            key: Key(grades[index].id.toString()),
            onDismissed: (direction) {
              setState(() {
                _deleteGrade(grades[index].id!);
                grades.removeAt(index);
              });
            },
            background: Container(color: Colors.red),
            child: ListTile(
              title: Text(grades[index].sid),
              subtitle: Text(grades[index].grade),
              onLongPress: () {
                _editGrade(grades[index]);
              },
            ),
          );
        },
      ),
    );
  }
}