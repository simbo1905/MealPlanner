# Comprehensive Drag-and-Drop Test Suite

**Date**: 2025-10-17  
**Purpose**: Full integration testing of calendar drag-and-drop, add/remove, scroll, and state management

---

## Pre-Test Setup

### Initial State Verification
1. Start app with default meals:
   - **Day +2** (2 days from today): "Chicken Stir-Fry" (30 min)
   - **Day +4** (4 days from today): "Roast Chicken" (90 min)
2. Take screenshot: `test_start_state.png`
3. Verify header shows correct week range and week number
4. Verify "Total: 2 activities"

---

## Test Suite 1: Basic Add/Remove Operations

### Test 1.1: Add Meal to Empty Day
**Steps:**
1. Find empty day (today or day +1)
2. Click "+ Add" button
3. Verify new "New Meal" card appears with:
   - Title: "New Meal"
   - Duration: "30 min"
   - Lightning bolt icon (quick meal ≤45 min)
   - Delete button (✖)
   - "+ Add" button
4. Verify "Total: 3 activities"

**Expected Result:** Card appears on correct day, activity count increments

**Screenshot:** `test_1_1_add_meal.png`

---

### Test 1.2: Remove Meal with Delete Button
**Steps:**
1. Find meal card with ✖ button
2. Click ✖ button
3. Verify card disappears
4. Verify day shows "+ Add" button
5. Verify activity count decrements

**Expected Result:** Meal removed, UI updates correctly

**Screenshot:** `test_1_2_remove_meal.png`

---

### Test 1.3: Reset All Meals
**Steps:**
1. Add multiple meals across several days
2. Note total activity count (e.g., "Total: 5 activities")
3. Click "Reset" button
4. Verify all meal cards disappear
5. Verify all days show "+ Add" button
6. Verify "Total: 0 activities"

**Expected Result:** Complete calendar reset

**Screenshot:** `test_1_3_reset_all.png`

---

## Test Suite 2: Drag-and-Drop Between Adjacent Days

### Test 2.1: Drag from Day with Event to Empty Day
**Setup:**
1. Reset calendar
2. Add "Meal A" to Day X
3. Ensure Day X+1 is empty

**Steps:**
1. Click and hold "Meal A" card
2. Verify dragging feedback:
   - Elevated shadow on drag feedback
   - Source card opacity reduces to 30%
3. Drag over Day X+1
4. Verify drop zone highlights with blue border
5. Release mouse
6. Verify "Meal A" now appears on Day X+1
7. Verify Day X shows "+ Add" button
8. Verify "Total: 1 activities" (no change)

**Expected Result:** Meal moves to target day

**Screenshot Before:** `test_2_1_before_drag.png`  
**Screenshot During:** `test_2_1_dragging.png`  
**Screenshot After:** `test_2_1_after_drop.png`

---

### Test 2.2: Drag from Day with Event to Day with Event (Combine)
**Setup:**
1. Reset calendar
2. Add "Meal A" to Day X (30 min)
3. Add "Meal B" to Day X+1 (30 min)

**Steps:**
1. Drag "Meal A" from Day X to Day X+1
2. Verify Day X+1 now shows TWO cards:
   - "Meal B" (30 min)
   - "Meal A" (30 min)
3. Verify Day X shows "+ Add" button
4. Verify "Total: 2 activities"

**Expected Result:** Both meals appear on Day X+1

**Screenshot Before:** `test_2_2_before_combine.png`  
**Screenshot After:** `test_2_2_after_combine.png`

---

### Test 2.3: Drag Multiple Meals from Combined Day to Empty Day
**Setup:**
1. Ensure Day X has TWO meals: "Meal A" and "Meal B"
2. Ensure Day X+1 is empty

**Steps:**
1. Drag "Meal A" from Day X to Day X+1
2. Verify "Meal A" moves, "Meal B" remains on Day X
3. Drag "Meal B" from Day X to Day X+1
4. Verify both meals now on Day X+1:
   - "Meal A" (30 min)
   - "Meal B" (30 min)
5. Verify Day X shows "+ Add" button
6. Verify "Total: 2 activities"

**Expected Result:** Both meals successfully moved one-by-one

**Screenshot After First Drag:** `test_2_3_after_first.png`  
**Screenshot After Second Drag:** `test_2_3_after_second.png`

---

## Test Suite 3: Empty Day Drop Zone Validation

### Test 3.1: Empty Day is Valid Drop Target
**Setup:**
1. Add meal to Day X
2. Ensure Days X-1, X+1, X+2 are all empty

**Steps:**
1. For each empty day (X-1, X+1, X+2):
   - Drag meal over the day area (including "+ Add" button region)
   - Verify entire day area highlights with blue border
   - Verify "+ Add" button remains visible during hover
2. Drop on Day X+1
3. Verify meal appears on Day X+1

**Expected Result:** Any empty day accepts drops across entire day region

**Screenshot Hover State:** `test_3_1_empty_hover.png`

---

### Test 3.2: Drop on Empty Day Below Visible Area
**Setup:**
1. Add meal to Day X (near top of screen)
2. Scroll down to reveal Day X+7 (empty day far below)

**Steps:**
1. Scroll back up to Day X
2. Drag meal from Day X
3. While dragging, scroll down with mouse/trackpad
4. Drop on Day X+7
5. Verify meal appears on Day X+7
6. Verify Day X shows "+ Add" button

**Expected Result:** Can drag-scroll and drop on off-screen days

**Screenshot:** `test_3_2_scroll_drop.png`

---

## Test Suite 4: Week Number and Scroll Synchronization

### Test 4.1: Week Number Updates on Scroll Down
**Setup:**
1. Note current week number (e.g., "WEEK 42")
2. Note current week range (e.g., "Oct 13 - Oct 19 2025")

**Steps:**
1. Scroll down 7 days (one full week)
2. Verify week badge updates to "WEEK 43"
3. Verify week range updates to next week (e.g., "Oct 20 - Oct 26 2025")
4. Verify activity count remains accurate

**Expected Result:** Week info updates in sync with scroll position

**Screenshot Before:** `test_4_1_week_42.png`  
**Screenshot After:** `test_4_1_week_43.png`

---

### Test 4.2: Week Number Updates on Scroll Up
**Steps:**
1. Scroll up 7 days (back one week)
2. Verify week badge decrements to "WEEK 42"
3. Verify week range matches previous week

**Expected Result:** Week info decrements correctly

**Screenshot:** `test_4_2_week_back.png`

---

### Test 4.3: Week Number Accuracy with Meal Assignments
**Steps:**
1. Scroll to Week 43
2. Add meal to Monday of Week 43
3. Scroll to Week 44
4. Verify week badge shows "WEEK 44"
5. Scroll back to Week 43
6. Verify meal still appears on correct day
7. Verify week badge shows "WEEK 43"

**Expected Result:** Meals stay anchored to correct days regardless of scroll

**Screenshot:** `test_4_3_meal_persistence.png`

---

## Test Suite 5: Complex Multi-Day Scenarios

### Test 5.1: Create Meal Plan for Entire Week
**Steps:**
1. Reset calendar
2. For each day Monday-Sunday of current week:
   - Add one meal
3. Verify "Total: 7 activities"
4. Take screenshot showing full week
5. Scroll to next week (Week +1)
6. Verify week badge increments
7. Verify "Total: 7 activities" (unchanged)
8. Scroll back to current week
9. Verify all 7 meals still present

**Expected Result:** Full week plan persists across scrolling

**Screenshot Full Week:** `test_5_1_full_week.png`

---

### Test 5.2: Reorganize Week by Dragging
**Setup:**
1. Create Week 42 plan:
   - Monday: "Chicken Stir-Fry"
   - Wednesday: "Roast Chicken"
   - Friday: "New Meal"

**Steps:**
1. Drag "Chicken Stir-Fry" from Monday to Tuesday
2. Drag "Roast Chicken" from Wednesday to Monday
3. Drag "New Meal" from Friday to Wednesday
4. Verify final state:
   - Monday: "Roast Chicken"
   - Tuesday: "Chicken Stir-Fry"
   - Wednesday: "New Meal"
   - Thursday-Sunday: empty
5. Verify "Total: 3 activities"

**Expected Result:** All meals moved correctly

**Screenshot Before:** `test_5_2_before_reorg.png`  
**Screenshot After:** `test_5_2_after_reorg.png`

---

### Test 5.3: Drag Same Meal Multiple Times
**Steps:**
1. Add "Meal X" to Monday
2. Drag "Meal X" to Tuesday
3. Drag "Meal X" from Tuesday to Wednesday
4. Drag "Meal X" from Wednesday to Thursday
5. Verify "Meal X" only appears on Thursday
6. Verify Monday, Tuesday, Wednesday all empty
7. Verify "Total: 1 activities"

**Expected Result:** Meal moves without duplication

**Screenshot:** `test_5_3_multi_drag.png`

---

## Test Suite 6: Edge Cases and Error Handling

### Test 6.1: Drag to Same Day (No-Op)
**Steps:**
1. Add meal to Day X
2. Drag meal from Day X
3. Drop back on Day X
4. Verify meal remains on Day X
5. Verify no duplicate created
6. Verify "Total: 1 activities"

**Expected Result:** No state change, no errors

**Screenshot:** `test_6_1_same_day_drop.png`

---

### Test 6.2: Rapid Add/Remove Operations
**Steps:**
1. Click "+ Add" 5 times rapidly on Day X
2. Verify 5 meal cards appear
3. Verify "Total: 5 activities"
4. Click ✖ on all 5 cards rapidly
5. Verify all cards removed
6. Verify "Total: 0 activities"

**Expected Result:** No race conditions, accurate count

**Screenshot With 5 Meals:** `test_6_2_rapid_add.png`

---

### Test 6.3: Drag During Scroll
**Steps:**
1. Add meal to Day X
2. Start dragging meal
3. While dragging, scroll with other hand/trackpad
4. Verify drag feedback follows cursor
5. Drop on visible target day
6. Verify meal appears on target

**Expected Result:** Drag state maintained during scroll

**Screenshot:** `test_6_3_drag_scroll.png`

---

## Test Suite 7: Visual Feedback Validation

### Test 7.1: Drag Feedback Visual Check
**Steps:**
1. Drag meal card
2. Verify drag feedback shows:
   - Elevated shadow (4px)
   - Same card design (green left border, gray background)
   - Only meal title visible (no buttons)
   - Rounded corners (12px radius)
3. Verify source card:
   - Opacity reduced to 30%
   - Remains in original position

**Expected Result:** Clear visual distinction between feedback and source

**Screenshot:** `test_7_1_drag_feedback.png`

---

### Test 7.2: Drop Zone Highlight Validation
**Steps:**
1. Drag meal over various days
2. For each day, verify:
   - Blue border appears (2px solid)
   - Blue background tint (10% opacity)
   - Entire day area is highlighted (not just card region)
3. Verify highlight disappears when drag exits day

**Expected Result:** Consistent, clear drop zone indicators

**Screenshot:** `test_7_2_drop_highlight.png`

---

### Test 7.3: Quick Meal Lightning Icon
**Steps:**
1. Add meal with 30 min duration
2. Verify lightning bolt icon appears
3. Add meal with 90 min duration  
4. Verify NO lightning bolt icon
5. Edit boundary: add meal with 45 min
6. Verify lightning bolt appears (≤45 min threshold)

**Expected Result:** Icon appears only for meals ≤45 min

**Screenshot:** `test_7_3_lightning_icons.png`

---

## Test Suite 8: State Persistence and Reset

### Test 8.1: State Survives Multiple Operations
**Steps:**
1. Create complex state:
   - Day 1: 2 meals
   - Day 2: 0 meals
   - Day 3: 3 meals
   - Day 4: 1 meal
2. Verify "Total: 6 activities"
3. Scroll to Week +1
4. Scroll back to Week 0
5. Verify all meals in correct positions
6. Drag meal from Day 1 to Day 2
7. Verify new state:
   - Day 1: 1 meal
   - Day 2: 1 meal
   - Day 3: 3 meals
   - Day 4: 1 meal
8. Verify "Total: 6 activities" (unchanged)

**Expected Result:** State remains consistent through operations

**Screenshot:** `test_8_1_state_persistence.png`

---

### Test 8.2: Reset Clears All State
**Steps:**
1. Create complex state with meals across 10 different days
2. Note activity count (e.g., "Total: 15 activities")
3. Click "Reset"
4. Verify:
   - All meal cards removed
   - All days show "+ Add" button
   - "Total: 0 activities"
   - Week number unchanged
5. Add new meal to Day X
6. Verify "Total: 1 activities"

**Expected Result:** Complete state reset, fresh start

**Screenshot Before:** `test_8_2_before_reset.png`  
**Screenshot After:** `test_8_2_after_reset.png`

---

## Test Suite 9: Alignment and Layout Validation

### Test 9.1: Day Header and Card Alignment
**Steps:**
1. Take screenshot of calendar with meals on multiple days
2. Verify alignment:
   - Day number circles align vertically (left edge)
   - Meal cards align vertically (left edge of card content)
   - Day numbers and meal cards are visually grouped
   - No excessive horizontal gap between day number and cards
3. Measure with ruler tool:
   - Day number left edge: X pixels from left
   - Card left border: Y pixels from left
   - Verify Y - X is reasonable (e.g., 60-90px, not 200px+)

**Expected Result:** Visual coherence, clear day grouping

**Screenshot:** `test_9_1_alignment.png`

---

### Test 9.2: Empty Day Layout
**Steps:**
1. Find empty day
2. Verify "+ Add" button position:
   - Aligned with meal cards on other days
   - Visually associated with day number
   - Not floating in center of screen

**Expected Result:** Consistent layout for empty and filled days

**Screenshot:** `test_9_2_empty_layout.png`

---

## Test Suite 10: Integration Test (End-to-End)

### Test 10.1: Complete User Workflow
**Scenario:** User plans meals for upcoming week

**Steps:**
1. **Monday 9am**: User opens app
   - Screenshot: `e2e_1_open.png`
   
2. **Plan Week 42**:
   - Add "Chicken Stir-Fry" to Monday
   - Add "Roast Chicken" to Wednesday
   - Add "New Meal" to Friday
   - Screenshot: `e2e_2_initial_plan.png`
   - Verify "Total: 3 activities"

3. **Tuesday 2pm**: User changes mind
   - Drag "Chicken Stir-Fry" from Monday to Thursday
   - Drag "New Meal" from Friday to Monday
   - Screenshot: `e2e_3_rearranged.png`
   - Verify "Total: 3 activities"

4. **Wednesday 6pm**: User adds more meals
   - Add "New Meal" to Tuesday
   - Add "New Meal" to Saturday
   - Screenshot: `e2e_4_added_more.png`
   - Verify "Total: 5 activities"

5. **Thursday noon**: User removes unused meals
   - Delete meal from Tuesday
   - Screenshot: `e2e_5_removed.png`
   - Verify "Total: 4 activities"

6. **Friday morning**: User scrolls to next week (Week 43)
   - Scroll down 7 days
   - Verify "WEEK 43"
   - Add "New Meal" to next Monday
   - Screenshot: `e2e_6_week_43.png`
   - Verify "Total: 5 activities"

7. **Saturday**: User reviews full plan
   - Scroll back to Week 42
   - Verify all 4 meals present
   - Scroll to Week 43
   - Verify 1 meal present
   - Screenshot: `e2e_7_review.png`

8. **Sunday reset**: User starts fresh for next planning cycle
   - Click "Reset"
   - Verify "Total: 0 activities"
   - Screenshot: `e2e_8_reset.png`

**Expected Result:** Complete workflow executes without errors, state remains consistent

---

## Test Execution Checklist

### Pre-Flight
- [ ] Clear browser cache
- [ ] Ensure chromedriver is running
- [ ] Create screenshots directory: `./test_screenshots/`
- [ ] Set screen resolution: 1280x720 (consistent screenshots)

### Execution Order
1. Run Test Suite 1 (Add/Remove)
2. Run Test Suite 2 (Adjacent Day DnD)
3. Run Test Suite 3 (Empty Day Drop Zones)
4. Run Test Suite 4 (Week Number Scroll)
5. Run Test Suite 5 (Multi-Day Scenarios)
6. Run Test Suite 6 (Edge Cases)
7. Run Test Suite 7 (Visual Feedback)
8. Run Test Suite 8 (State Persistence)
9. Run Test Suite 9 (Alignment)
10. Run Test Suite 10 (End-to-End)

### Post-Flight
- [ ] Review all screenshots for visual regression
- [ ] Verify no console errors in browser DevTools
- [ ] Check memory usage (should be <50MB)
- [ ] Confirm all tests passed
- [ ] Generate test report: `DND_TEST_REPORT.md`

---

## Automated Test Implementation

### Playwright Test Structure

```dart
// integration_test/dnd_comprehensive_test.dart

testWidgets('Suite 2.2: Drag to combine meals on same day', (tester) async {
  // Setup
  await _resetCalendar(tester);
  final dayX = _getDate(0);
  final dayX1 = _getDate(1);
  
  await _addMeal(tester, dayX, 'Meal A');
  await _addMeal(tester, dayX1, 'Meal B');
  await _takeScreenshot(tester, 'test_2_2_before_combine.png');
  
  // Action: Drag Meal A to Day X+1
  final mealA = find.byKey(Key('meal-Meal A-${_dateKey(dayX)}'));
  final dayX1Target = find.byKey(Key('drag-target-${_dateKey(dayX1)}'));
  
  await tester.drag(mealA, Offset(0, 150)); // Drag down to next day
  await tester.pumpAndSettle();
  await _takeScreenshot(tester, 'test_2_2_after_combine.png');
  
  // Verify
  expect(find.text('Meal A'), findsOneWidget);
  expect(find.text('Meal B'), findsOneWidget);
  expect(_getMealsOnDay(dayX1).length, equals(2));
  expect(_getMealsOnDay(dayX).length, equals(0));
  expect(find.text('Total: 2 activities'), findsOneWidget);
});
```

---

## Success Criteria

All tests must pass with:
- ✅ No runtime errors
- ✅ All screenshots captured
- ✅ Visual alignment correct in screenshots
- ✅ Activity counts accurate
- ✅ Drag feedback visible and correct
- ✅ Drop zones highlight properly
- ✅ Week numbers update on scroll
- ✅ State persists across operations
- ✅ Reset clears all state

**Test Duration Target:** <10 minutes for full suite  
**Pass Rate Target:** 100% (60/60 test cases)
