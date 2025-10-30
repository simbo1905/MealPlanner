import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/meal.freezed_model.dart';
import '../../providers/meal_providers.dart';
import '../../providers/text_recognition_provider.dart';
import '../../screens/ocr/ocr_result_screen.dart';
import '../../widgets/calendar/week_header.dart';
import '../../widgets/calendar/day_row.dart';
import '../../widgets/calendar/landscape_week_grid.dart';
import '../../widgets/calendar/planned_meals_counter.dart';
import 'add_meal_bottom_sheet.dart';
import '../../providers/auth_providers.dart';

class InfiniteCalendarScreen extends ConsumerStatefulWidget {
  const InfiniteCalendarScreen({super.key});

  @override
  ConsumerState<InfiniteCalendarScreen> createState() => _InfiniteCalendarScreenState();
}

class _InfiniteCalendarScreenState extends ConsumerState<InfiniteCalendarScreen> {
  final ScrollController _scrollController = ScrollController();
  int _weeksAround = 4;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    debugPrint('[INFO] SCREEN_LOAD - Infinite calendar loaded');
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 500) {
      setState(() {
        _weeksAround += 2;
      });
    }
    
    if (_scrollController.position.pixels <= 500) {
      setState(() {
        _weeksAround += 2;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final weekSectionsAsync = ref.watch(weekSectionsProvider(weeksAround: _weeksAround));
    final selectedDate = ref.watch(selectedDateProvider);
    final isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;
    
    // Calculate current week number for badge
    final weekNumber = _getWeekNumber(selectedDate);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Meal Planner'),
        actions: [
          // OCR Scan button
          IconButton(
            icon: const Icon(Icons.camera_alt_outlined),
            tooltip: 'Scan text from image',
            onPressed: () => _onOpenOcr(context),
          ),
          
          // Week badge (required key: week-badge)
          Container(
            key: const Key('week-badge'),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            margin: const EdgeInsets.only(right: 8),
            decoration: BoxDecoration(
              color: Colors.blue[700],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              'WEEK $weekNumber',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          
          // Save button
          TextButton.icon(
            onPressed: _onSave,
            icon: const Icon(Icons.save_outlined, size: 18),
            label: const Text('Save'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.blue,
            ),
          ),
          
          // Reset button (required key: reset-button)
          TextButton.icon(
            key: const Key('reset-button'),
            onPressed: _onReset,
            icon: const Icon(Icons.refresh, size: 18),
            label: const Text('Reset'),
            style: TextButton.styleFrom(
              foregroundColor: Colors.orange,
            ),
          ),
          
          // Planned meals counter
          const PlannedMealsCounter(),
          
          const SizedBox(width: 8),
        ],
      ),
      body: weekSectionsAsync.when(
        data: (weekSections) => CustomScrollView(
          key: const Key('infinite_calendar_scroll'),
          controller: _scrollController,
          slivers: [
            SliverList(
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  if (index >= weekSections.length) return null;

                  final weekSection = weekSections[index];

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      WeekHeader(
                        weekStart: weekSection.weekStart,
                        weekEnd: weekSection.weekEnd,
                        weekNumber: weekSection.weekNumber,
                        totalMeals: weekSection.totalMeals,
                        totalPrepTime: weekSection.totalPrepTime,
                      ),
                      if (isLandscape)
                        LandscapeWeekGrid(
                          weekSection: weekSection,
                          onSelectDay: _onSelectDay,
                          onAddMeal: _onAddMeal,
                          onSwapMeals: _onSwapMeals,
                        )
                      else
                        ...weekSection.days.map(
                          (day) => DayRow(
                            date: day.date,
                            isToday: day.isToday,
                            isSelected: day.isSelected,
                            meals: day.meals,
                            onTap: () => _onSelectDay(day.date),
                            onAddMeal: () => _onAddMeal(day.date),
                          ),
                        ),
                      if (index < weekSections.length - 1)
                        Divider(
                          height: 8,
                          thickness: 4,
                          color: Colors.grey[200],
                        ),
                    ],
                  );
                },
                childCount: weekSections.length,
              ),
            ),
          ],
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Unable to load calendar: $error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }

  void _onSelectDay(DateTime date) {
    ref.read(selectedDateProvider.notifier).select(date);
    debugPrint('[INFO] SELECT_DAY - ${date.toIso8601String()}');
  }

  void _onAddMeal(DateTime date) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: AddMealBottomSheet(date: date),
      ),
    );
  }

  Future<void> _onSwapMeals(String firstMealId, String secondMealId) async {
    final userId = ref.read(currentUserIdProvider);
    if (userId == null) return;
    await ref.read(mealRepositoryProvider).swapMeals(
          userId: userId,
          firstMealId: firstMealId,
          secondMealId: secondMealId,
        );
  }

  Future<void> _onSave() async {
    final repository = ref.read(mealRepositoryProvider);
    
    // Get current working state (simplified - would need proper implementation)
    final now = DateTime.now();
    final start = now.subtract(const Duration(days: 365));
    final end = now.add(const Duration(days: 365));
    final meals = repository.getMealsForDateRange(start, end);
    
    // Group by date
    final stateMap = <String, List<Meal>>{};
    for (final meal in meals) {
      final key = _dateToKey(meal.date);
      stateMap.putIfAbsent(key, () => []).add(meal);
    }
    
    await repository.saveState(stateMap);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Meal plan saved'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _onReset() {
    final repository = ref.read(mealRepositoryProvider);
    repository.resetToPersistedState();
    
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Reset to saved state'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  String _dateToKey(DateTime date) {
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  int _getWeekNumber(DateTime date) {
    final firstDayOfYear = DateTime(date.year, 1, 1);
    final daysSinceFirstDay = date.difference(firstDayOfYear).inDays;
    return ((daysSinceFirstDay + firstDayOfYear.weekday) / 7).ceil();
  }

  Future<void> _onOpenOcr(BuildContext context) async {
    try {
      final picker = ImagePicker();
      final image = await picker.pickImage(source: ImageSource.gallery);

      if (image == null) return;

      if (!context.mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Processing...'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: const [
              CircularProgressIndicator(),
              SizedBox(height: 16),
              Text('Recognizing text from image...'),
            ],
          ),
        ),
      );

      final recognizedText = await ref.read(
        recognizeTextProvider(image.path).future,
      );

      if (!context.mounted) return;
      Navigator.of(context).pop();

      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => OcrResultScreen(
            extractedText: recognizedText,
          ),
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.of(context).pop();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }
}
