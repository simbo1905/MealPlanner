# Dart Collections & Event-Sourced Storage Architecture

**Date**: 2025-10-16  
**Topic**: Flutter meal planner with event-sourced data model and multi-platform storage

---

## Overview

This document consolidates the data architecture for the Flutter meal planner, porting the event-sourced storage model from TypeScript prototypes to Dart with platform-specific adapters.

---

## JDT Recipe Schema

### Recipe Model (from `packages/recipe-types/schema/recipe.jtd.json`)

```dart
class Recipe {
  String? uuid;                    // Time-ordered UUID (optional on create, required at rest)
  String title;                    // Recipe name (unique identifier for user)
  String imageUrl;                 // URI to recipe image
  String description;              // Max 250 chars
  String notes;                    // Chef notes
  List<String> preReqs;            // Prerequisite steps
  double totalTime;                // Total time in minutes
  List<Ingredient> ingredients;    // Min 1 ingredient
  List<String> steps;              // Min 1 cooking step
  String? mealType;                // breakfast|brunch|lunch|dinner|snack|dessert
}
```

### Ingredient Model

```dart
class Ingredient {
  String name;
  UcumUnit ucumUnit;              // cup_us|cup_m|cup_imp|tbsp_us|tbsp_m|tbsp_imp|tsp_us|tsp_m|tsp_imp
  double ucumAmount;              // Multiple of 0.1
  MetricUnit metricUnit;          // ml|g
  double metricAmount;
  String notes;
  AllergenCode? allergenCode;     // Optional: GLUTEN|CRUSTACEAN|EGG|FISH|PEANUT|SOY|MILK|NUT|CELERY|MUSTARD|SESAME|SULPHITE|LUPIN|MOLLUSC|SHELLFISH|TREENUT|WHEAT
}
```

**Key Constraints**:
- Recipe title uniquely identifies recipe in user's personal storage
- All recipes have at least 1 ingredient and 1 step
- UCUM units for volumetric measurements, metric for weight/volume
- Allergen codes follow EU regulation 1169/2011

---

## Calendar Behavior (from `specs/002-calendar-view-prototype/spec.md`)

### User Interaction Model

1. **Vertical Infinite Scroll**: Calendar displays days in vertical list, loads more as user scrolls
2. **Day Selection**: 
   - Always one selected day (default: today)
   - Tap day → select day
   - Current day highlighted with visual indicator
3. **Adding Meals**:
   - Tap "+ Add" on day → show recipe selector modal
   - Select recipe → meal auto-added to selected day
4. **Moving Meals**:
   - Drag meal card to different day (using `infinite_calendar_view` DnD)
   - On drop: removes from source day, adds to target day
5. **Removing Meals**:
   - Tap meal card → show recipe banner
   - Tap "Remove" → meal deleted from day

### Calendar Requirements
- **FR-001**: Vertical scrolling calendar with infinite loading
- **FR-002**: Visual day selection with current day highlight
- **FR-003**: Drag-and-drop between days
- **FR-004**: Multiple meals per day (horizontal scroll if >3 cards)
- **FR-005**: Meal cards show: title, thumbnail, total time

---

## Event-Sourced Storage Model

### Conceptual Architecture (from `prototype/04/IDB_NATIVE.md`)

The storage layer uses an **append-only event log** for meal planning with eventual consistency across devices.

#### Collections

1. **`recipes_v1`**: Recipe templates
   - Indexed by time-ordered UUID
   - Immutable once created (updates create new version with new UUID)
   - Contains full recipe data

2. **`days_v1`**: Sparse collection of meal events by ISO date
   - Key: ISO date string (YYYY-MM-DD)
   - Value: Array of `DayEvent` objects
   - Append-only (no updates, only appends)

#### Event Model

**Format**: `$timestamp-$verb-$uuid[-$data]`

```dart
class DayEvent {
  String id;                    // Format: "1730150405123-add-0afc..." or "1730150405123-del-0afc..."
  String isoDate;               // "2025-10-16"
  DayEventOperation op;         // add | del
  String recipeUuid;            // References recipe in recipes_v1
  int occurredAtEpochMs;        // Unix timestamp
  RecipeSnapshot? snapshot;     // For 'add' events: {title, imageUrl, totalTime}
}

class DayLog {
  String isoDate;
  List<DayEvent> events;
  String? lastChangeToken;      // For CloudKit/sync bookkeeping
}
```

**Event Semantics**:
- `add` event: Creates meal instance from recipe, includes snapshot for UI rendering
- `del` event: Tombstone for removal (no data payload, just UUID reference)

#### Conflict Resolution & Idempotency

**Critical Properties** (from user requirements):
1. **Delete without add = no-op**: If we see a `del` event for UUID that was never added, ignore it
2. **Duplicate add = overwrite**: If we see multiple `add` events for same UUID, last one wins (map insertion)
3. **Time-ordered replay**: Sort events by `occurredAtEpochMs`, apply in order
4. **No errors on inconsistency**: Replay is fault-tolerant and idempotent

**Rebuilding Day State**:
```dart
// Pseudo-code from prototype/04/src/lib/storage/dayEventRebuilder.ts
Map<String, MealEntry> rebuildDayMeals(List<DayEvent> events) {
  final sorted = events.sortedBy((e) => e.occurredAtEpochMs);
  final map = <String, MealEntry>{};
  
  for (final event in sorted) {
    if (event.op == 'add') {
      map[event.recipeUuid] = MealEntry.fromEvent(event);
    } else if (event.op == 'del') {
      map.remove(event.recipeUuid);  // No error if key doesn't exist
    }
  }
  
  return map;  // Deduped, time-ordered final state
}
```

---

## Time-Ordered UUID Generation

### Port from Java Implementation (user-provided)

Original Java implementation (`com.github.simbo1905.nfp.srs.UUIDGenerator`):

```java
// Most significant 64 bits: (epoch_ms << 20) | (counter & 0xFFFFF)
// Least significant 64 bits: random long
static long epochTimeThenCounterMsb() {
  long currentMillis = System.currentTimeMillis();
  long counter20bits = sequence.incrementAndGet() & 0xFFFFF;  // 20-bit counter
  return (currentMillis << 20) | counter20bits;
}
```

**Dart Implementation** (implemented in `uuid_generator.dart`):

```dart
class UUIDGenerator {
  static int _sequence = 0;
  static int _lastEpochMs = 0;
  
  static String generateUUID() {
    final now = DateTime.now().millisecondsSinceEpoch;
    
    // Sub-millisecond ordering via 20-bit counter
    if (now == _lastEpochMs) {
      _sequence = (_sequence + 1) & 0xFFFFF;
    } else {
      _sequence = 0;
      _lastEpochMs = now;
    }
    
    // Web-safe BigInt operations (avoid 64-bit int issues on JS)
    final msb = (BigInt.from(now) << 20) | BigInt.from(_sequence);  // Time + counter
    final lsb = _randomBigInt();                                      // Random 64 bits
    
    return _formatUUID(msb, lsb);  // Format: xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx
  }
  
  static int dissect(String uuid) {
    // Extract epoch milliseconds from UUID
    final hex = uuid.replaceAll('-', '');
    final msbHex = hex.substring(0, 16);
    final msb = BigInt.parse(msbHex, radix: 16);
    return (msb >> 20).toInt();  // Extract timestamp
  }
  
  static ({int timestampMs, int sequence}) dissectFull(String uuid) {
    // Extract both timestamp and sequence counter for debugging
    final hex = uuid.replaceAll('-', '');
    final msbHex = hex.substring(0, 16);
    final msb = BigInt.parse(msbHex, radix: 16);
    final timestampMs = (msb >> 20).toInt();
    final sequence = (msb & BigInt.from(0xFFFFF)).toInt();
    return (timestampMs: timestampMs, sequence: sequence);
  }
}
```

**Properties**:
- MSB (first 16 hex chars): time (44 bits) + counter (20 bits) = 64 bits
- LSB (last 16 hex chars): random 64 bits for global uniqueness
- Within a single isolate: perfect time ordering with sub-millisecond resolution (1M UUIDs/ms via 20-bit counter)
- Across devices: ordering subject to clock drift, but random LSB ensures global uniqueness
- Web-safe: Uses BigInt to avoid JavaScript's 53-bit integer precision limits
- Format: `xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx` (32 hex chars + 4 hyphens)

---

## Storage Abstraction

### Adapter Interface

```dart
abstract class StorageAdapter {
  Future<void> initialize();
  
  // Recipe CRUD
  Future<Recipe> putRecipe(Recipe recipe);          // Auto-assigns UUID if missing
  Future<Recipe?> getRecipe(String uuid);
  Future<List<Recipe>> listRecipes();
  Future<List<Recipe>> searchRecipes(RecipeSearchQuery query);
  
  // Day event log
  Future<DayLog> appendDayEvents(String isoDate, List<DayEvent> events);
  Future<DayLog?> readDayLog(String isoDate);
  Future<void> compactDayLog(String isoDate);  // Prune obsolete tombstones (optional)
}
```

### Platform Implementations

#### 1. Memory Adapter (Testing)
- In-memory `Map<String, Recipe>` and `Map<String, DayLog>`
- No persistence, perfect for unit tests
- Fast, synchronous internally (wrapped in Future for API compliance)

#### 2. IndexedDB Adapter (Web)
- Database: `meal_planner_v1`
- Object Stores:
  - `recipes_v1`: keyPath `uuid`, indexes on `title`, `titleLower`
  - `days_v1`: keyPath `isoDate`, index on `isoDate`
- Uses `indexed_db` Dart package
- Transactions for all writes
- Persistence across browser sessions

#### 3. CloudKit Adapter (iOS)
- Delegates to `cloud_kit` package (already in pubspec)
- Private database, custom zone: `MealPlanner`
- Record types: `Recipe`, `DayLog`
- Change tokens for sync
- **MVP**: Stub implementation (returns UnimplementedError)
- **Future**: Full CKModifyRecordsOperation, change streams

#### 4. Factory Pattern
```dart
StorageAdapter createStorageAdapter() {
  if (kIsWeb) return IndexedDbAdapter();
  if (Platform.isIOS) return CloudKitAdapter();  // Stub for now
  return MemoryAdapter();  // Fallback
}
```

---

## Search Implementation

### Recipe Search Query

```dart
class RecipeSearchQuery {
  String? query;                   // Free-text search (title, description, ingredients)
  int? maxTime;                    // Max total_time in minutes
  List<String>? ingredients;       // Must contain these ingredient names
  List<String>? excludeAllergens;  // Exclude these allergen codes
  int? limit;                      // Max results
  String? sortBy;                  // title | total_time | relevance
}
```

### Search Strategy

**Initial Implementation** (per `prototype/04/IDB_NATIVE.md`):
- Linear scan for ≤512 recipes (acceptable performance)
- Case-insensitive substring matching on: `title`, `description`, `ingredient.name`
- Filters applied after text match: `totalTime <= maxTime`, `allergen not in excludeAllergens`
- Relevance scoring: title match (3 pts) > description (2 pts) > ingredient (1 pt)
- Sort by: relevance score (desc), then title (asc)

**Future Enhancement**:
- IndexedDB: materialized indexes on `titleLower`, `ingredientNames[]`
- CloudKit: secondary queryable fields
- Full-text search with stemming/fuzzy matching

---

## EventsList Widget Configuration

### Using `infinite_calendar_view` Package

```dart
EventsList(
  controller: EventsController(),
  initialDate: DateTime.now(),
  maxPreviousDays: 365,   // 1 year back
  maxNextDays: 365,       // 1 year forward
  
  // UK standard: week starts Monday
  firstDayOfWeek: 1,
  
  verticalScrollPhysics: BouncingScrollPhysics(),
  
  dayHeaderBuilder: (DateTime day, bool isToday) {
    // "15 OCT – WEDNESDAY" format
    // Bold/colored if isToday
  },
  
  dayEventsBuilder: (DateTime day, List<Event> events) {
    // If events.isEmpty: return TextButton.icon(icon: Icons.add, label: "Add")
    // Else: return Column of MealCard widgets
  },
)
```

### Data Loading Flow

1. **Controller Setup**:
   - Create `EventsController` instance
   - Load initial day logs from storage (today ± 7 days)
   - Convert `DayLog` → `Event` objects for controller

2. **Day Rendering**:
   - `dayHeaderBuilder` called for each visible day
   - `dayEventsBuilder` fetches `DayLog` from storage, rebuilds meals, renders cards

3. **Lazy Loading**:
   - Package handles infinite scroll automatically
   - On scroll: fetch additional `DayLog` entries from storage
   - Update controller with new events

4. **User Actions**:
   - Add meal: Create `add` event, append to `DayLog`, update controller
   - Remove meal: Create `del` event, append to `DayLog`, update controller
   - Drag meal: Create `del` (source) + `add` (target) events, update both day logs

---

## Testing Strategy

### Unit Tests (TDD)

1. **Models**: `recipe_test.dart`, `ingredient_test.dart`, `day_event_test.dart`
   - JSON serialization round-trip
   - Equality/hashCode
   - Validation (required fields, constraints)

2. **UUID Generator**: `uuid_generator_test.dart`
   - Ordering: 1000 sequential UUIDs have ascending timestamps
   - Uniqueness: 10k UUIDs all unique
   - Dissection: `dissect(generateUUID())` returns current epoch ms (±10ms tolerance)

3. **Storage Adapters**: `memory_adapter_test.dart`, `indexed_db_adapter_test.dart`
   - CRUD operations
   - Event append/replay
   - Search with filters
   - Persistence (for IndexedDB: close/reopen DB)

4. **Event Rebuilder**: `day_event_rebuilder_test.dart`
   - Empty events → empty result
   - Single add → meal present
   - Add then del → empty result
   - Del without add → no error, empty result
   - Duplicate add → last one wins
   - Interleaved add/del → correct final state

### Widget Tests

- `calendar_screen_test.dart`: EventsList rendering, day selection, scroll
- `meal_card_test.dart`: Card display, tap handling, bottom sheet
- `recipe_selector_test.dart`: Search, filtering, selection

### Integration Tests

- `calendar_integration_test.dart`: Full user flow (add → drag → remove → persist)

---

## Platform-Specific Considerations

### Web (Chrome)
- IndexedDB quota: ~10MB for origin (sufficient for 1000+ recipes)
- Testing: Chrome DevTools → Application → IndexedDB → `meal_planner_v1`
- Verify object stores: `recipes_v1`, `days_v1`
- Inspect event structure, tombstones

### iOS
- CloudKit private database (user-scoped)
- Stub implementation for MVP (no network calls)
- Future: `CKModifyRecordsOperation` for batched writes, change tokens for sync
- Testing: iOS simulator, verify no crashes, memory usage

### Android (Future)
- Potential adapters: Room + DataStore, or SQLite + WorkManager
- Must implement same `StorageAdapter` interface
- Event log table: `days_v1(iso_date PRIMARY KEY, events_json TEXT)`

---

## Data Migration & Versioning

### Schema Evolution
- Object stores named `recipes_v1`, `days_v1` for future versioning
- Add fields: optional properties (backward compatible)
- Remove fields: deprecated but retained in schema (mark as unused)
- Breaking changes: create `recipes_v2`, migrate data, drop old store

### Event Log Compaction
- Tombstones (`del` events) never removed automatically
- `compactDayLog()` method (optional):
  - Merge contiguous add/del pairs for same UUID
  - Remove obsolete snapshots
  - Keep newest surviving entry
- Run manually or on schedule (e.g., compact days >30 days old)

---

## Open Questions & Future Work

### Sync & Conflict Resolution
- CloudKit change tokens: how to track last-synced state per device?
- Multi-device merge: time-ordered events handle most cases, but clock drift may cause issues
- Solution: attach device ID to events, use hybrid logical clocks (HLC) for causality

### Offline Queue
- Queue events locally when offline
- Flush to CloudKit when connection restored
- Retry logic with exponential backoff

### Advanced Search
- Fuzzy matching: "chiken" → "chicken"
- Stemming: "running" → "run"
- Ingredient substitutions: "butter" → "margarine"

### UI Enhancements
- Week summaries: total meals, cooking time
- Meal type filters: breakfast, lunch, dinner
- Recipe favorites: flag frequently used recipes
- Batch operations: copy week, clear week

---

## References

- `packages/recipe-types/schema/recipe.jtd.json` - JDT schema definition
- `specs/002-calendar-view-prototype/spec.md` - Calendar UX requirements
- `prototype/04/IDB_NATIVE.md` - Event-sourced storage design
- `prototype/04/src/lib/storage/uuidGenerator.ts` - TypeScript UUID implementation
- `prototype/04/src/lib/storage/dayEventRebuilder.ts` - Event replay logic
- User-provided Java UUID generator - Original time-ordered UUID algorithm

---

## Summary

This architecture provides:
1. **Platform-agnostic storage**: Same API for web (IndexedDB), iOS (CloudKit), tests (memory)
2. **Eventual consistency**: Event log with idempotent replay handles offline/multi-device scenarios
3. **Type safety**: JDT-aligned Dart models with strict validation
4. **Infinite scroll**: `EventsList` widget with lazy loading
5. **TDD approach**: Tests written before implementation, ensuring correctness

Implementation follows the approved plan with TDD throughout, starting with models and progressing to UI components.
