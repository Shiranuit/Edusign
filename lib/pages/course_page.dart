import 'package:edusign_v2/pages/login_page.dart';
import 'package:edusign_v2/pages/signature_page.dart';
import 'package:edusign_v2/services/storage_service.dart';
import 'package:edusign_v2/widgets/acrylic_appbar.dart';
import 'package:edusign_v2/widgets/course_tile_widget.dart';
import 'package:flutter/material.dart';

import '../models/course_model.dart';
import '../services/edusign_service.dart';
import 'course_scanner_page.dart';

class CoursePage extends StatefulWidget {
  CoursePage({Key? key}) : super(key: key);

  @override
  State<CoursePage> createState() => _CoursePageState();
}

class _CoursePageState extends State<CoursePage> {
  Future<List<Course>>? _coursesFuture;
  List<Course> _courses = [];
  List<Course> _filteredCourses = [];
  final ValueNotifier<bool> _showFutureCourses = ValueNotifier(false);

  @override
  void initState() {
    _coursesFuture =
        EdusignService.getCourses(EdusignService.user!).then((value) {
      _courses = value;

      var now = DateTime.now();
      var startDay = DateTime(now.year, now.month, now.day);
      var endDay = DateTime(now.year, now.month, now.day)
          .add(const Duration(hours: 23, minutes: 59, seconds: 59));

      _filteredCourses = _courses
          .where((course) =>
              startDay.isBefore(course.start) && endDay.isAfter(course.end))
          .toList();
      return value;
    });
    super.initState();
  }

  void _onTileTap(Course course) {
    if (course.presence || course.absence) {
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => CourseScannerPage(course: course),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context) {
    return Drawer(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const Text('Show Future Courses'),
              Switch(
                value: _showFutureCourses.value,
                onChanged: (value) {
                  setState(() {
                    _showFutureCourses.value = value;
                  });
                },
              ),
            ],
          ),
          Card(
            child: ListTile(
              title: const Center(child: Text('Change Signature')),
              onTap: () async {
                String? signature = await Navigator.push(context,
                    MaterialPageRoute(builder: (context) {
                  return SignaturePage();
                }));

                if (signature != null) {
                  StorageService.write(key: 'signature', value: signature);
                }
              },
            ),
          ),
          Card(
            child: ListTile(
              title: const Center(child: Text('Logout')),
              onTap: () {
                EdusignService.user = null;
                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (context) => LoginPage(title: 'Fluttersign'),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF2C3E50),
            Color(0xFF4CA1AF),
          ],
        ),
      ),
      child: Scaffold(
        drawer: _buildDrawer(context),
        body: SafeArea(
          child: DecoratedBox(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Color(0xFF2C3E50),
                  Color(0xFF4CA1AF),
                ],
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AcrylicAppbar(
                  title: Text(
                    'Courses',
                    style: Theme.of(context).textTheme.titleLarge!,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  child: FutureBuilder<List<Course>>(
                    future: _coursesFuture,
                    builder: (context, snapshot) {
                      if (snapshot.hasData) {
                        return ValueListenableBuilder(
                            valueListenable: _showFutureCourses,
                            builder: (context, value, child) {
                              List<Course> courses =
                                  value ? _courses : _filteredCourses;
                              return ListView.builder(
                                itemCount: courses.length,
                                itemBuilder: (context, index) {
                                  return CourseTile(
                                    course: courses[index],
                                    onTap: _onTileTap,
                                  );
                                },
                              );
                            });
                      } else if (snapshot.hasError) {
                        return Container(
                          color: Colors.red,
                          child: Center(
                            child: Text('${snapshot.error}'),
                          ),
                        );
                      }
                      return const Center(
                        child: CircularProgressIndicator(),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
