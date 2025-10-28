# Requirement: Training Calendar – Week Sections, Day Rows, and Meal Cards

This requirement defines the UI and behavior for the Training calendar screen shown in the provided reference image. It specifies an implementable Flutter layout and interactions using the libraries already in this repository’s demos (flutter_riverpod, intl, collection, animated_reorderable_list).

Status: draft

## Visual Design

- App bar
  - Leading: back chevron button
  - Title: "Training calendar"
  - Trailing: `Save` text button (enabled only when there are unsaved changes)

- Content: vertically scrolling list of weeks with day rows
  - Each week renders as a section with a sticky-style header (header stays visually grouped with the days below but does not have to pin).

- Week header (top-to-bottom, left-aligned)
  - Line 1: Date range, e.g., `13 Oct – 19 Oct`
  - Inline pill to the right of the range: `WEEK N` (rounded black capsule, white text)
  - Right-aligned `Reset` button with a circular refresh icon
  - Line 2: Subtext `Total: 7.6 km` (secondary color)
  - Container background: subtle surface (`Color(0xFFF6F7F9)`)
  - Padding: horizontal 16, vertical 12

- Day row
  - Left rail (56 px):
    - Day-of-week label (e.g., MON) in small caps style
    - Date circle beneath (28 px). If the day is “today”, the circle is filled (primary color) and the label color shifts to primary. Otherwise, an outlined style or muted text.
  - Main area: horizontal list of cards followed by a `+ Add` affordance
    - Default height: 100 px
    - When no cards, still show `+ Add` button in light/ghost style
  - Tapping empty area selects the day (left border highlight). Long-pressing on an empty day opens the add-meal flow.

- Meal card
  - Size: width 160, height fits content, corner radius 12
  - Background: light surface (`Colors.white` or very light grey) with soft shadow (8 px blur @ 8% black)
  - Left gradient stripe 4 px wide using the meal color (top: color, bottom: color @ 60%)
  - Title line: activity icon (colored) + bold title
  - Subtext: secondary metric (e.g., `3.5 km`, `45 min`)
  - Long-press on the card opens the context sheet/actions. A tiny lightning icon (hint) in the top-right may also trigger the same action.

## Flutter Architecture (using existing libraries)

- State: flutter_riverpod
  - `mealControllerProvider` drives selected day, generated weeks, add/move/remove operations
  - Derived providers expose the current list of `CalendarWeek` and aggregates (e.g., per-week totals)

- Date formatting: intl
  - `DateFormat('d MMM')` for the week range
  - `DateFormat('EEE').toUpperCase()` for day labels

- Collections & totals: collection
  - Use `groupBy` and fold to compute totals (e.g., distance) per week if needed

- Drag & reorder: animated_reorderable_list
  - Use within a day’s horizontal list for reordering cards within the same day
  - Cross-day moves are implemented as drag origin detection + drop target resolution (gesture + controller update), followed by removal from source list and insert into destination list

## Implementation Blueprint

- Scaffold
  - AppBar with `BackButton()`, `Text('Training calendar')`, and a `TextButton('Save')` bound to a Riverpod `dirty` flag

- Body: `CustomScrollView`
  - `SliverList` of week sections
  - Each week section composed of:
    - Week header container (see Visual Design)
    - Column of 7 `DayRow` widgets
    - Divider after the week

- Week header widget
  - Left: `Text(range)` where `range = '${d1} – ${d2}'`
  - Pill: `Chip` or `Container` with `BoxDecoration` (black background, 16 px radius, horizontal padding 10, vertical 4) => `WEEK N`
  - Right: `OutlinedButton.icon(icon: Icons.refresh, label: Text('Reset'))`
  - Subtext: `Text('Total: X km')` below the top line
  - Keys for testing
    - `Key('week-${week.start.toIso8601String()}')`
    - `Key('week-reset-${week.start.toIso8601String()}')`

- DayRow (structure)
  - GestureDetector root with `Key('day-${yyyy-MM-dd}')`
  - Left rail: column with weekday label and date circle. If `day.isToday`, fill the circle and change label color
  - Main area: horizontal list
    - For in-day reordering: `AnimatedReorderableList`
      - itemBuilder returns a `MealCard`
      - trailing `AddMealCard` with `Key('add-${yyyy-MM-dd}')`
    - When moving a card between days, use a long-press on `MealCard` to start a cross-day drag (gesture), compute target under pointer on pointer-up, then call `controller.moveMeal(from: day, to: targetDay)`
  - Visual selection: if this is the `selectedDay`, apply `Border(left: BorderSide(color: theme.primary, width: 4))` and light container tint

- MealCard
  - Root `GestureDetector` with `Key('meal-card-${meal.id}')`
  - 4 px left gradient bar using `LinearGradient(colors: [meal.color, meal.color.withOpacity(0.6)])`
  - Content padding 12; title row with icon + bold text; subtext with smaller, grey text
  - Tiny lightning hint `Icon(Icons.flash_on, size: 16, color: Colors.grey.withOpacity(0.3))` at top-right

## Pseudocode Snippets (excerpts)

```dart
// Week header – date range + pill + reset + total
class WeekHeader extends ConsumerWidget {
  const WeekHeader({super.key, required this.week});
  final CalendarWeek week;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final fmt = DateFormat('d MMM');
    final range = '${fmt.format(week.start)} – ${fmt.format(week.end)}';
    final totalKm = ref.watch(weekTotalKmProvider(week));

    return Container(
      key: Key('week-${week.start.toIso8601String()}'),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      color: const Color(0xFFF6F7F9),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Wrap(
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    Text(range, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(16)),
                      child: Text('WEEK ${week.weekNumber}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700)),
                    ),
                  ],
                ),
              ),
              OutlinedButton.icon(
                key: Key('week-reset-${week.start.toIso8601String()}'),
                onPressed: () => ref.read(mealControllerProvider.notifier).resetWeek(week),
                icon: const Icon(Icons.refresh, size: 18),
                label: const Text('Reset'),
              ),
            ],
          ),
          const SizedBox(height: 2),
          Text('Total: ${totalKm.toStringAsFixed(1)} km', style: TextStyle(fontSize: 12, color: Colors.grey[700])),
        ],
      ),
    );
  }
}
```

```dart
// Day row showing weekday, date bubble and horizontal meal list
class DayRow extends ConsumerWidget {
  const DayRow({super.key, required this.day});
  final CalendarDay day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ctrl = ref.read(mealControllerProvider.notifier);
    final isSelected = ref.watch(mealControllerProvider.select((s) => s.isSelected(day.date)));
    final label = DateFormat('EEE').format(day.date).toUpperCase();

    return GestureDetector(
      key: Key('day-${DateFormat('yyyy-MM-dd').format(day.date)}'),
      onTap: () => ctrl.setSelectedDay(day.date),
      onLongPress: () => ctrl.quickAddTo(day.date),
      child: Container(
        decoration: isSelected
            ? BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withOpacity(0.3),
                border: Border(left: BorderSide(color: Theme.of(context).colorScheme.primary, width: 4)),
              )
            : null,
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Row(
          children: [
            SizedBox(
              width: 56,
              child: Column(
                children: [
                  Text(label, style: TextStyle(fontSize: 11, fontWeight: day.isToday ? FontWeight.bold : FontWeight.w500, color: day.isToday ? Theme.of(context).colorScheme.primary : Colors.grey[700])),
                  const SizedBox(height: 4),
                  _DateBubble(isToday: day.isToday, text: DateFormat('d').format(day.date)),
                ],
              ),
            ),
            Expanded(
              child: SizedBox(
                height: 100,
                child: AnimatedReorderableList(
                  key: Key('meal-list-${DateFormat('yyyy-MM-dd').format(day.date)}'),
                  scrollDirection: Axis.horizontal,
                  items: day.meals,
                  onReorder: (from, to) => ctrl.reorderWithinDay(day.date, from, to),
                  itemBuilder: (context, item, handle) => MealCard(meal: item, onLongPress: () => ctrl.beginCrossDayDrag(item, day.date), key: Key('meal-card-${item.id}')),
                  trailing: Padding(padding: const EdgeInsets.only(left: 8), child: AddMealCard(onTap: () => ctrl.quickAddTo(day.date), key: Key('add-${DateFormat('yyyy-MM-dd').format(day.date)}'))),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Interaction Rules

- Save button
  - Disabled by default; enabled when the controller indicates pending changes
  - Pressing Save flushes pending changes and disables the button again

- Reset (per week)
  - Restores the week to its generated/default state via controller, without affecting other weeks

- Add
  - `+ Add` always visible at the end of the horizontal list for a day
  - Long-press on an empty day triggers the same add flow

- Drag & drop
  - Long-press on a Meal card starts a drag
  - Reordering within the same day uses `animated_reorderable_list`
  - Moving between days: on drop, detect the day under the pointer; controller removes from source day and inserts into the target day

## Accessibility & Testability

- Provide stable keys:
  - Weeks: `week-<ISO-start>`, `week-reset-<ISO-start>`
  - Days: `day-<yyyy-MM-dd>`, `meal-list-<yyyy-MM-dd>`, `add-<yyyy-MM-dd>`
  - Cards: `meal-card-<id>`
- Ensure all interactive elements are reachable by semantics and expose labels (e.g., `Reset week N`, `Add meal for <date>`, `Save changes`)

## Acceptance Criteria

1) Week headers match layout (range + WEEK N pill + total + Reset button), spacing and colors close to screenshot
2) Day rows render weekday and date circle correctly; today displays highlighted
3) Horizontal meal card list appears per day with `+ Add` affordance always visible
4) Cards show left gradient stripe, icon+title, and secondary metric
5) Reordering within a day animates smoothly; cross-day moves update underlying state
6) `Save` enables only when there are unsaved changes and disables after saving
7) `Reset` only affects its week; totals recompute accordingly

