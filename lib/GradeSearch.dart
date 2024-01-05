import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import 'Grade.dart';

// this is the extra feature class for the search by student id method.
class GradeSearchDelegate extends SearchDelegate<String> {
  final List<Grade> grades;
  final Function(String) onSearch;

  GradeSearchDelegate(this.grades, this.onSearch);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
          onSearch('');
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, '');
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    List<Grade> searchResults = grades.where((grade) {
      return grade.sid.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: searchResults.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchResults[index].sid),
          subtitle: Text(searchResults[index].grade),
          onTap: () {
            // Handle the onTap action here
          },
        );
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    List<Grade> searchSuggestions = grades.where((grade) {
      return grade.sid.toLowerCase().contains(query.toLowerCase());
    }).toList();

    return ListView.builder(
      itemCount: searchSuggestions.length,
      itemBuilder: (context, index) {
        return ListTile(
          title: Text(searchSuggestions[index].sid),
          subtitle: Text(searchSuggestions[index].grade),
          onTap: () {
            // Handle the onTap action here
          },
        );
      },
    );
  }
}