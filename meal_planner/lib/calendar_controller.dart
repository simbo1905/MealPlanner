class Event {
  final String title;
  final double distance;

  Event({required this.title, required this.distance});
}

class CalendarController {
  Future<bool> addEvent(Event event) async {
    // In a real app, you would persist the event here.
    return true;
  }

  Future<bool> deleteEvent(String title) async {
    // In a real app, you would delete the event here.
    return true;
  }

  Future<bool> reorderEvent(int oldIndex, int newIndex) async {
    // In a real app, you would reorder the events here.
    return true;
  }
}