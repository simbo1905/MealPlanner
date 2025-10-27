import 'package:flutter/material.dart';
import 'package:infinite_calendar_view/infinite_calendar_view.dart';
import 'package:intl/intl.dart';
import 'package:meal_planner/calendar_controller.dart' as controller;
import 'package:meal_planner/services/local_buffer.dart';
import 'package:meal_planner/services/sync_isolate.dart';
import 'package:meal_planner/services/pocketbase_service.dart';
import 'screens/experimental_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize event-sourced store infrastructure
  final buffer = LocalBuffer();
  final syncIsolate = await SyncIsolate.spawn();
  final pb = PocketBaseService();

  try {
    await pb.initialize();
  } catch (e) {
    // PocketBase not available; will run offline
  }

  runApp(MyApp(
    buffer: buffer,
    syncIsolate: syncIsolate,
  ));
}

class MyApp extends StatelessWidget {
  final LocalBuffer buffer;
  final SyncIsolate syncIsolate;

  const MyApp({
    Key? key,
    required this.buffer,
    required this.syncIsolate,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Meal Planner',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        scaffoldBackgroundColor: Colors.white,
      ),
      home: const TrainingCalendarScreen(),
    );
  }
}

class TrainingCalendarScreen extends StatefulWidget {
  const TrainingCalendarScreen({Key? key}) : super(key: key);

  @override
  State<TrainingCalendarScreen> createState() => _TrainingCalendarScreenState();
}

class _TrainingCalendarScreenState extends State<TrainingCalendarScreen> {
  final EventsController _eventsController = EventsController();
  final controller.CalendarController _calendarController = controller.CalendarController();
  final ScrollController _scrollController = ScrollController();
  DateTime _selectedDate = DateTime.now();
  DateTime _visibleWeekStart = DateTime.now();
  final Map<String, List<Event>> _mealsByDay = {};

  @override
  void initState() {
    super.initState();
    _visibleWeekStart = _getWeekStart(_selectedDate);
    _initializeCalendar();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    final offset = _scrollController.offset;
    final dayHeight = 120.0;
    final scrolledDays = (offset / dayHeight).floor();
    final newVisibleDate = DateTime.now().add(Duration(days: scrolledDays - 2));
    final newWeekStart = _getWeekStart(newVisibleDate);
    
    if (_visibleWeekStart != newWeekStart) {
      setState(() {
        _visibleWeekStart = newWeekStart;
      });
    }
  }

  void _initializeCalendar() {
    final now = DateTime.now();
    final events = [
      Event(
        startTime: now.add(const Duration(days: 2)),
        endTime: now.add(const Duration(days: 2, minutes: 30)),
        title: 'Chicken Stir-Fry',
      ),
      Event(
        startTime: now.add(const Duration(days: 4)),
        endTime: now.add(const Duration(days: 4, minutes: 90)),
        title: 'Roast Chicken',
      ),
    ];

    for (final event in events) {
      final key = _dateKey(event.startTime!);
      _mealsByDay[key] = [...(_mealsByDay[key] ?? []), event];
    }

    _eventsController.updateCalendarData((data) {
      data.addEvents(events);
    });
  }

  String _dateKey(DateTime date) {
    return DateFormat('yyyy-MM-dd').format(date);
  }

  int _getWeekNumber(DateTime date) {
    final startOfYear = DateTime(date.year, 1, 1);
    final firstMonday = startOfYear.add(Duration(days: (8 - startOfYear.weekday) % 7));
    if (date.isBefore(firstMonday)) {
      return 1;
    }
    final daysSinceFirstMonday = date.difference(firstMonday).inDays;
    return (daysSinceFirstMonday / 7).floor() + 1;
  }

  DateTime _getWeekStart(DateTime date) {
    return date.subtract(Duration(days: (date.weekday - 1) % 7));
  }

  DateTime _getWeekEnd(DateTime weekStart) {
    return weekStart.add(const Duration(days: 6));
  }

  int _getTotalActivities() {
    return _mealsByDay.values.fold(0, (sum, events) => sum + events.length);
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDate = day;
    });
  }

  void _addMeal(DateTime day) {
    final newEvent = Event(
      startTime: day,
      endTime: day.add(const Duration(minutes: 30)),
      title: 'New Meal',
    );

    setState(() {
      final key = _dateKey(day);
      _mealsByDay[key] = [...(_mealsByDay[key] ?? []), newEvent];
      _eventsController.updateCalendarData((data) {
        data.addEvents([newEvent]);
      });
    });
  }

  void _removeMeal(Event event) {
    setState(() {
      final key = _dateKey(event.startTime!);
      _mealsByDay[key]?.removeWhere((e) => 
        e.startTime == event.startTime && e.title == event.title);
      if (_mealsByDay[key]?.isEmpty ?? false) {
        _mealsByDay.remove(key);
      }
      _eventsController.updateCalendarData((data) {
        data.removeEvent(event);
      });
    });
  }

  void _moveMeal(Event event, DateTime fromDay, DateTime toDay) {
    if (_dateKey(fromDay) == _dateKey(toDay)) return;

    setState(() {
      final fromKey = _dateKey(fromDay);
      final toKey = _dateKey(toDay);
      
      _mealsByDay[fromKey]?.removeWhere((e) => 
        e.startTime == event.startTime && e.title == event.title);
      if (_mealsByDay[fromKey]?.isEmpty ?? false) {
        _mealsByDay.remove(fromKey);
      }
      
      final movedEvent = Event(
        startTime: toDay,
        endTime: toDay.add(event.endTime!.difference(event.startTime!)),
        title: event.title,
      );
      
      _mealsByDay[toKey] = [...(_mealsByDay[toKey] ?? []), movedEvent];
      
      _eventsController.updateCalendarData((data) {
        data.removeEvent(event);
        data.addEvents([movedEvent]);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final weekStart = _visibleWeekStart;
    final weekEnd = _getWeekEnd(weekStart);
    final weekNumber = _getWeekNumber(weekStart);
    final totalActivities = _getTotalActivities();

    return Scaffold(
      key: const Key('calendar-scaffold'),
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            key: const Key('experimental-icon'),
            icon: const Icon(Icons.science_outlined, color: Colors.black54),
            tooltip: 'Experimental Features',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ExperimentalScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 32, 24, 16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          '${DateFormat('MMM d').format(weekStart)} - ${DateFormat('MMM d yyyy').format(weekEnd)}',
                          key: const Key('week-range'),
                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w600,
                            color: Colors.black,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Container(
                          key: const Key('week-badge'),
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                          decoration: BoxDecoration(
                            color: Colors.black,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            'WEEK $weekNumber',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    TextButton.icon(
                      key: const Key('reset-button'),
                      onPressed: () {
                        setState(() {
                          final allEvents = _mealsByDay.values.expand((e) => e).toList();
                          _mealsByDay.clear();
                          _eventsController.updateCalendarData((data) {
                            for (final event in allEvents) {
                              data.removeEvent(event);
                            }
                          });
                        });
                      },
                      icon: const Icon(Icons.refresh, size: 20, color: Colors.black54),
                      label: const Text(
                        'Reset',
                        style: TextStyle(
                          color: Colors.black54,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  'Total: $totalActivities activities',
                  key: const Key('total-activities'),
                  style: const TextStyle(
                    fontSize: 16,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFE5E5E5)),
          Expanded(
            child: EventsList(
              controller: _eventsController,
              initialDate: DateTime.now(),
              maxPreviousDays: 365,
              maxNextDays: 365,
              verticalScrollPhysics: const BouncingScrollPhysics(),
              dayHeaderBuilder: (DateTime day, bool isToday, List<Event>? events) {
                final isSelected = _selectedDate.year == day.year &&
                    _selectedDate.month == day.month &&
                    _selectedDate.day == day.day;

                return GestureDetector(
                  key: Key('day-header-${_dateKey(day)}'),
                  onTap: () => _selectDay(day),
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(24, 16, 24, 8),
                    child: Row(
                      children: [
                        Column(
                          children: [
                            Text(
                              DateFormat('EEE').format(day),
                              style: TextStyle(
                                fontSize: 14,
                                color: isToday ? Colors.black : Colors.black45,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              key: isToday ? const Key('today-circle') : null,
                              width: 52,
                              height: 52,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isToday ? Colors.black : Colors.transparent,
                              ),
                              alignment: Alignment.center,
                              child: Text(
                                DateFormat('d').format(day),
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w600,
                                  color: isToday ? Colors.white : Colors.black,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
              dayEventsBuilder: (DateTime day, List<Event>? events) {
                final dayKey = _dateKey(day);
                final dayEvents = _mealsByDay[dayKey] ?? [];

                return DragTarget<Map<String, dynamic>>(
                  key: Key('drag-target-$dayKey'),
                  onAccept: (data) {
                    final event = data['event'] as Event;
                    final fromDay = data['fromDay'] as DateTime;
                    _moveMeal(event, fromDay, day);
                  },
                  builder: (context, candidateData, rejectedData) {
                    final isHovering = candidateData.isNotEmpty;
                    
                    return Container(
                      constraints: const BoxConstraints(minHeight: 80),
                      decoration: BoxDecoration(
                        color: isHovering ? Colors.blue.withOpacity(0.1) : Colors.transparent,
                        border: isHovering ? Border.all(color: Colors.blue, width: 2) : null,
                        borderRadius: isHovering ? BorderRadius.circular(8) : null,
                      ),
                      padding: const EdgeInsets.only(left: 85, right: 24, top: 8, bottom: 24),
                      child: dayEvents.isEmpty
                          ? Align(
                              alignment: Alignment.centerLeft,
                              child: TextButton.icon(
                                key: Key('add-meal-$dayKey'),
                                onPressed: () => _addMeal(day),
                                icon: const Icon(Icons.add, size: 18, color: Colors.black54),
                                label: const Text(
                                  'Add',
                                  style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: 16,
                                  ),
                                ),
                                style: TextButton.styleFrom(
                                  padding: EdgeInsets.zero,
                                  minimumSize: const Size(0, 0),
                                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                ),
                              ),
                            )
                          : ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: dayEvents.length,
                              itemBuilder: (context, index) {
                                final event = dayEvents[index];
                                final duration = event.endTime != null && event.startTime != null
                                    ? event.endTime!.difference(event.startTime!).inMinutes
                                    : 30;
                                final isQuick = duration <= 45;

                                return Draggable<Map<String, dynamic>>(
                                  data: {'event': event, 'fromDay': day},
                                  feedback: Material(
                                    elevation: 4,
                                    borderRadius: BorderRadius.circular(12),
                                    child: Container(
                                      width: 250,
                                      padding: const EdgeInsets.all(16.0),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFF5F5F5),
                                        borderRadius: BorderRadius.circular(12.0),
                                        border: const Border(
                                          left: BorderSide(
                                            color: Color(0xFF34C759),
                                            width: 4,
                                          ),
                                        ),
                                      ),
                                      child: Text(
                                        event.title ?? '',
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w600,
                                          fontSize: 17,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ),
                                  childWhenDragging: Opacity(
                                    opacity: 0.3,
                                    child: _buildMealCard(event, day, dayKey, index, duration, isQuick),
                                  ),
                                  child: _buildMealCard(event, day, dayKey, index, duration, isQuick),
                                );
                              },
                            ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMealCard(Event event, DateTime day, String dayKey, int index, int duration, bool isQuick) {
    return Container(
      key: Key('meal-${event.title}-$dayKey'),
      margin: const EdgeInsets.only(bottom: 12.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(12.0),
        border: const Border(
          left: BorderSide(
            color: Color(0xFF34C759),
            width: 4,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            event.title?.contains('Stir') == true
                ? Icons.restaurant
                : Icons.soup_kitchen,
            color: Colors.black87,
            size: 24,
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  event.title ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 17,
                    color: Colors.black,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$duration min',
                  style: const TextStyle(
                    fontSize: 15,
                    color: Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          if (isQuick)
            const Padding(
              padding: EdgeInsets.only(right: 12.0),
              child: Icon(
                Icons.bolt,
                color: Colors.black54,
                size: 20,
              ),
            ),
          IconButton(
            key: Key('delete-meal-$dayKey-$index'),
            icon: const Icon(Icons.close, size: 20, color: Colors.black54),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _removeMeal(event),
          ),
          const SizedBox(width: 8),
          TextButton.icon(
            key: Key('add-another-$dayKey-$index'),
            onPressed: () => _addMeal(day),
            icon: const Icon(Icons.add, size: 18, color: Colors.black54),
            label: const Text(
              'Add',
              style: TextStyle(
                color: Colors.black54,
                fontSize: 15,
              ),
            ),
            style: TextButton.styleFrom(
              padding: EdgeInsets.zero,
              minimumSize: const Size(0, 0),
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
        ],
      ),
    );
  }
}
