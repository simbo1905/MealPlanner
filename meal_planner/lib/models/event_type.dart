enum EventType {
  create,
  update,
  delete,
}

extension EventTypeExt on EventType {
  String toJson() => switch (this) {
        EventType.create => 'CREATE',
        EventType.update => 'UPDATE',
        EventType.delete => 'DELETE',
      };

  static EventType fromJson(String value) => switch (value.toUpperCase()) {
        'CREATE' => EventType.create,
        'UPDATE' => EventType.update,
        'DELETE' => EventType.delete,
        _ => throw FormatException('Invalid EventType: $value'),
      };
}
