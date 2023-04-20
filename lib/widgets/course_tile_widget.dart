import 'package:edusign_v2/widgets/acrylic.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/course_model.dart';

typedef CourseTileCallback = void Function(Course course);

class CourseTile extends StatefulWidget {
  Course course;
  CourseTileCallback? onTap;

  CourseTile({
    Key? key,
    required this.course,
    this.onTap,
  }) : super(key: key);

  @override
  State<CourseTile> createState() => _CourseTileState();
}

class _CourseTileState extends State<CourseTile> {
  void _showCourseDetails() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text(widget.course.name),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Name: ${widget.course.name}'),
              Text(
                  'Start Date: ${DateFormat.yMMMMd().format(widget.course.start)}'),
              Text(
                  'End Date: ${DateFormat.yMMMMd().format(widget.course.end)}'),
              Text('Teacher: ${widget.course.professor}'),
              Text('ID: ${widget.course.id}'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: widget.course,
      builder: (context, child) {
        Icon presenceIcon;

        if (widget.course.presence) {
          presenceIcon = const Icon(
            Icons.check,
            color: Colors.green,
          );
        } else if (widget.course.absence) {
          presenceIcon = const Icon(
            Icons.close,
            color: Colors.red,
          );
        } else {
          presenceIcon = const Icon(
            Icons.schedule,
            color: Colors.grey,
          );
        }

        return Tooltip(
          message: widget.course.presence
              ? 'Present'
              : widget.course.absence
                  ? 'Absent'
                  : 'Not Scanned',
          child: GestureDetector(
            onTap: () {
              widget.onTap?.call(widget.course);
            },
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 100),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Acrylic(
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey.shade600),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          FractionallySizedBox(
                            heightFactor: 0.6,
                            child: AspectRatio(
                              aspectRatio: 1,
                              child: FittedBox(
                                child: presenceIcon,
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                  DateFormat('yMMMMd')
                                      .format(widget.course.start.toLocal()),
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  )),
                              Text(
                                '${DateFormat('Hm').format(widget.course.start.toLocal())} - ${DateFormat('Hm').format(widget.course.end.toLocal())}',
                                style: const TextStyle(
                                    fontSize: 18, color: Colors.orange),
                              ),
                              Text(
                                widget.course.name,
                                style: const TextStyle(fontSize: 14),
                              ),
                            ],
                          ),
                          Expanded(child: Container()),
                          Tooltip(
                            message: 'Course Details',
                            child: IconButton(
                              onPressed: _showCourseDetails,
                              icon: const Icon(Icons.info_outline_rounded),
                              iconSize: 26,
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
