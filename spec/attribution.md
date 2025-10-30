# Attribution Display Specification

## Overview
The application must display attribution information for all data sources used, particularly the recipe dataset licensed under CC BY-SA 3.0.

## Requirements

### 1. Display Location
- Attribution information must be accessible to users in the application UI
- Primary location: Settings or About screen within the app
- Secondary: App footer or info drawer

### 2. Content
- Display attribution text referencing the recipe dataset source
- Include link to original Epicurious source
- Include CC BY-SA 3.0 license information with link to license text
- Credit Joseph Martinez for the recipe-dataset project

### 3. Implementation Details
- Attribution text should be concise yet complete
- Links should be clickable and open in browser/external app
- Attribution should be displayed on first app load or in an About section
- No user dismissal of attribution information is permitted

### 4. Widget/Screen
- Create an `AttributionScreen` or `AttributionWidget` in `lib/screens/` or `lib/widgets/`
- Show formatted attribution with clickable links
- Display in a scrollable container if content exceeds screen size

### 5. Navigation
- Add link to attribution screen from app settings or info menu
- Ensure attribution is discoverable from main app navigation
