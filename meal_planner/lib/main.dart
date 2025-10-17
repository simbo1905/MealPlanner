
import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/calendar_controller.dart' as controller;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const TrainingCalendarScreen(),
    );
  }
}

class TrainingCalendarScreen extends StatefulWidget {
  const TrainingCalendarScreen({Key? key}) : super(key: key);

  @override
  _TrainingCalendarScreenState createState() => _TrainingCalendarScreenState();
}

class _TrainingCalendarScreenState extends State<TrainingCalendarScreen> {
  final EventsController _controller = EventsController();
  final controller.CalendarController _calendarController = controller.CalendarController();

  @override
  void initState() {
    super.initState();
    _controller.updateCalendarData((data) {
      data.addEvents([
        Event(
          startTime: DateTime.now(),
          endTime: DateTime.now().add(const Duration(hours: 1)),
          title: 'Spaghetti Bolognese',
        ),
        Event(
          startTime: DateTime.now().add(const Duration(days: 1)),
          endTime: DateTime.now().add(const Duration(days: 1, hours: 1)),
          title: 'Chicken Stir-Fry',
        ),
      ]);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Training calendar'),
        actions: [
          TextButton(
            onPressed: () {},
            child: const Text('Save', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: EventsList(
        controller: _controller,
        initialDate: DateTime.now(),
        maxPreviousDays: 365,
        maxNextDays: 365,
        verticalScrollPhysics: const BouncingScrollPhysics(),
        dayHeaderBuilder: (DateTime day, bool isToday, List<Event>? events) {
          return Container(
            padding: const EdgeInsets.all(8.0),
            alignment: Alignment.centerLeft,
            child: Text(
              DateFormat('d MMM – EEEE').format(day).toUpperCase(),
              style: TextStyle(
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                color: isToday ? Colors.blue : Colors.black,
              ),
            ),
          );
        },
        dayEventsBuilder: (DateTime day, List<Event>? events) {
          if (events == null || events.isEmpty) {
            return Center(
              child: TextButton.icon(
                onPressed: () {
                  _calendarController.addEvent(controller.Event(title: 'New Meal', distance: 0));
                },
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            );
          }
          return ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: events.length,
            itemBuilder: (context, index) {
              final event = events[index];
              return Container(
                margin: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 8.0),
                padding: const EdgeInsets.all(12.0),
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(8.0),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.restaurant_menu),
                    const SizedBox(width: 12.0),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(event.title ?? '', style: const TextStyle(fontWeight: FontWeight.bold)),
                        if (event.endTime != null && event.startTime != null)
                          Text('${event.endTime!.difference(event.startTime!).inMinutes} min'),
                      ],
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
