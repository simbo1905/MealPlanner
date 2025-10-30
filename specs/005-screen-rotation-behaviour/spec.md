# Feature Specification: Rotation-Aware Calendar Experience

**Feature Branch**: `005-screen-rotation-behaviour`  
**Created**: 2025-10-30  
**Status**: Draft  
**Input**: GitHub Issue #8 - "create spec for screen rotation behaviour that works with rotation lock"

---

## User Scenarios & Testing *(mandatory)*

### Primary User Story
As a MealPlanner user who switches between portrait and landscape use on my phone or tablet, I want the app to present the best calendar layout for each orientation while still letting me access both layouts when rotation lock prevents auto-rotation, so that I never lose track of my weekly plan.

### Acceptance Scenarios
1. **Given** I open MealPlanner on a device with rotation lock disabled while viewing the portrait `InfiniteCalendarScreen`, **When** I rotate the device into landscape, **Then** the experience transitions to the landscape `WeekCalendarScreen` without losing my selected date, scroll position, or in-progress actions.
2. **Given** rotation lock is enabled and I remain in portrait orientation, **When** I tap the new layout toggle in the app bar, **Then** the app opens the `WeekCalendarScreen` in landscape layout while respecting the system lock (no forced device rotation) and carrying over the same calendar state.
3. **Given** I manually switch to `WeekCalendarScreen` while rotation lock is enabled, **When** I exit back to portrait mode via the layout toggle, **Then** I return to the `InfiniteCalendarScreen` with the calendar positioned on the same week/day that I was reviewing in the grid view.
4. **Given** I set the layout preference to "Follow Device Orientation", **When** I disable rotation lock and physically rotate, **Then** the preferred layout updates automatically on the next orientation change event and the preference persists across sessions.
5. **Given** I am using multi-window mode on a tablet, **When** the window is resized below the minimum width for the landscape grid layout, **Then** the spec-defined fallback keeps me on the portrait `InfiniteCalendarScreen` and shows messaging that grid view requires a wider layout.

### Edge Cases
- Device orientation events firing while a modal (e.g., `AddMealBottomSheet`) is onscreen
- Bluetooth keyboard or stand accessories that trigger landscape metrics without physical rotation
- Rapid rotation back and forth causing multiple layout swaps inside two seconds
- Persistent toast or snackbar messages when switching between screens
- Memory-constrained devices resuming the app from background after an orientation change

---

## Requirements *(mandatory)*

### Functional Requirements
- **FR-001**: System MUST present `InfiniteCalendarScreen` by default when the app loads in portrait orientation.
- **FR-002**: System MUST respect the device rotation lock setting and MUST NOT force-rotate the OS when lock is enabled.
- **FR-003**: System MUST provide a persistent layout toggle in the primary app bar that offers three options: `Follow Device Orientation`, `Portrait Infinite Scroll (InfiniteCalendarScreen)`, and `Landscape Week Grid (WeekCalendarScreen)`.
- **FR-004**: When `Follow Device Orientation` is active and rotation lock is disabled, the layout MUST switch automatically between `InfiniteCalendarScreen` and `WeekCalendarScreen` based on the current orientation breakpoint.
- **FR-005**: Manual layout selections (portrait or landscape) MUST override auto-rotation, persist across sessions, and display a subtle banner reminding the user that rotation lock is active.
- **FR-006**: Switching between layouts MUST preserve shared state: selected date, visible week range, staged meal edits, and pending bottom sheets.
- **FR-007**: When a blocking modal or bottom sheet is open, layout changes MUST be deferred until the modal is dismissed, then applied with preserved selections.
- **FR-008**: System MUST adapt to multi-window or resize events by evaluating the active layout against minimum width/height thresholds and surfacing guidance when a layout is unavailable.
- **FR-009**: Accessibility settings (larger text, reduced motion) MUST be respected during layout transitions, providing fade or cross-fade alternatives if motion reduction is enabled.

### Non-Functional Requirements
- **NFR-001**: Layout transition animation MUST complete within 250ms on modern devices and degrade gracefully (no animation) on lower capability hardware.
- **NFR-002**: Orientation detection MUST react within 150ms of receiving an orientation change callback when auto mode is enabled.
- **NFR-003**: User preference storage MUST survive app restarts, upgrades, and offline usage.
- **NFR-004**: All rotation-related state updates MUST be logged with `SCREEN_ROTATION` action tags for QA traceability.

### Key Entities *(include if feature involves data)*
- **LayoutPreference**: Stores user-selected mode (`follow_device`, `portrait_only`, `landscape_only`), timestamp, and last applied orientation.
- **CalendarViewportState**: Captures selected date, visible week index, and scroll offsets shared between `InfiniteCalendarScreen` and `WeekCalendarScreen`.
- **OrientationCapability**: Captures detected device capabilities (supports landscape grid, minimum width, rotation lock status snapshot).

---

## Experience Notes

- The layout toggle appears to the left of the Save/Reset controls on `InfiniteCalendarScreen` and mirrors in `WeekCalendarScreen` so the control is always available.
- A brief onboarding tip highlights the toggle the first time rotation lock is detected while in portrait to teach users how to access `WeekCalendarScreen`.
- Snackbars spawned before a layout switch should remain visible and anchored to the new layout to avoid losing user confirmation cues.
- QA matrix must cover iOS, Android, tablets, foldables, and web browsers with responsive breakpoints equivalent to mobile portrait and landscape widths.

---

## Review & Acceptance Checklist

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] markers remain
- [x] Requirements are testable and unambiguous  
- [x] Success criteria are measurable
- [x] Scope is clearly bounded
- [x] Dependencies and assumptions identified

---

## Execution Status

- [x] User description parsed
- [x] Key concepts extracted
- [x] Ambiguities marked
- [x] User scenarios defined
- [x] Requirements generated
- [x] Entities identified
- [ ] Review checklist passed

---
