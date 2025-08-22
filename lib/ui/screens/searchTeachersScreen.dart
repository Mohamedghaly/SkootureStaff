import 'package:flutter/material.dart';

class SearchTeachersScreen extends StatefulWidget {
  const SearchTeachersScreen({super.key});

  static Widget getRouteInstance() {
    //final arguments = Get.arguments as Map<String,dynamic>;
    return const SearchTeachersScreen();
  }

  static Map<String, dynamic> buildArguments() {
    return {};
  }

  @override
  State<SearchTeachersScreen> createState() => _SearchTeachersScreenState();
}

class _SearchTeachersScreenState extends State<SearchTeachersScreen> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: SizedBox());
  }
}
