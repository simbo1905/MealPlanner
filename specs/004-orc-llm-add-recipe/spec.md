# Feature Specification: AI-Powered Recipe Onboarding

**Created**: 2025-10-15  
**Status**: Draft  
**Input**: User description: "we would like an easy way for users of MealPlanner to onboard their existing recipes. LLM/AI can help with this. if the user can photo any existing recipe that they have on the phone then text extraction can get the infomation and post it to MistralAI with a prompt for it to convert the infomation into the necessary json format to save in the local database. it will often be the case that the first phone, or the total set of photos, will not be sufficient to fully populate the required data. one example may be that a total preperation time may not be available in the original materials. in which case MistalAI prompt should tell the AI to ask the user what they wish to do. the options should be "AI Best Guess", or "User Input" yet that can be a single thing where-by for missing data the user has the option to add a new photo with the data, or enter type something themselves, or hit an "AI" magicwand button for the LLM to make a guess. this should be super simple and we could even use a chat screen for this. so the user wants to add a recipe, they are prompted for "manual data entry" or "use camera and AI chat". if they do manual data entry it is a classic web form that lets them enter the data that is compliant with the JDT definition of our recipes. we can code that first to ensure we can input data. yet the timesaver is to use the camera+ai model. that will then open up the phone 'take photo' which of course the user will have approve use of using standard phone pattern. then they take a photo. the app asks if they want to "use or retake" this ideally should be the phone native experiecne so that we do not need to code/invent this. they may retake when they "use" then it extracts the text with Vision OCR, posts it to MistralAI with a prompt to return MealPlanner JSON, and pre-populates the recipe form. Any missing fields show three quick actions: "AI Best Guess," "User Input," or "Add Photo." The user taps Save; the JSON is stored locally."

---

## Storage & Platform Notes (2025-10-28)

- **Unified storage abstraction**: The recipe onboarding flow must persist data via a pluggable storage layer with identical TypeScript APIs. Default adapter = IndexedDB (prototype/web); production iOS adapter = WKWebView bridge to CloudKit; future Android adapter = equivalent native bridge.
- **Recipe identity**: All completed recipes carry an optional time-ordered UUID (`uuid`). When absent in inbound payloads the storage layer assigns one before persistence. The identifier is used for cross-device reconciliation, day logs, and future sync.
- **Day meal logs**: Assigning or removing recipes on the calendar writes to a per-day append-only log. Each entry encodes `$timestamp-op-uuid` (add/del) plus minimal recipe snapshot for UI display. Replaying the log reconstructs the day's meals and supports eventual consistency.
- **Tombstones**: Deletions are represented as `del` events. No hard deletes; compaction is a future optimisation. This enables conflict-free merges across CloudKit, IndexedDB, and future sync stores.
- **Search posture**: With <512 recipes, adapters may satisfy search requirements through linear scans while keeping hooks for indexed backends. UX expectations remain unchanged.

## Execution Flow (main)
```
1. Parse user description from Input
   → Identified comprehensive recipe onboarding feature with dual input methods
2. Extract key concepts from description
   → Actors: MealPlanner users
   → Actions: add recipes, take photos, review/edit data, save recipes
   → Data: recipe text from photos, structured recipe data, missing field handling
   → Constraints: must comply with JTD recipe schema, local storage only
3. For each unclear aspect:
   → [NEEDS CLARIFICATION: Camera permission handling details]
   → [NEEDS CLARIFICATION: Offline functionality requirements]
   → [NEEDS CLARIFICATION: Photo quality/format requirements]
4. Fill User Scenarios & Testing section
   → Clear user flows for both manual and AI-assisted recipe entry
5. Generate Functional Requirements
   → 12 testable requirements covering both input methods
6. Identify Key Entities
   → Recipe, RecipePhoto, MissingField entities identified
7. Run Review Checklist
   → WARN "Spec has uncertainties around camera integration details"
8. Return: SUCCESS (spec ready for planning with clarifications needed)
```

---

## ⚡ Quick Guidelines
- ✅ Focus on WHAT users need and WHY
- ❌ Avoid HOW to implement (no tech stack, APIs, code structure)
- 👥 Written for business stakeholders, not developers

---

## Clarifications

### Session 2025-10-15
- Q: When the MistralAI service is unavailable (network issues, service outage), what should happen to the Camera + AI workflow? → A: Fall back to collecting photos and text locally, store in workspace-database with chat UI, allow multiple photos, retry when service returns
- Q: When camera permissions are denied by the user, what should the app behavior be? → A: Follow Apple's guidance
- Q: What should happen when AI returns recipe data that doesn't match the expected JTD schema format? → A: Run JTD validation, send lint errors back to model for fixes (max 2 retry cycles), fall back to manual entry if still invalid
- Q: How long should the system wait for MistralAI response before showing the timeout options to the user? → A: TBD
- Q: When a user selects "AI Best Guess" for missing recipe fields, should this trigger a new MistralAI request or use cached/local AI inference? → A: New MistralAI request with missing field context

---

## User Scenarios & Testing

### Primary User Story
As a MealPlanner user, I want to quickly add my existing recipes to the app by either manually entering recipe details or taking photos of recipe cards/books and having AI extract and structure the information, so that I can digitize my recipe collection without tedious manual data entry.

### Acceptance Scenarios
1. **Given** user wants to add a new recipe, **When** they select "Add Recipe", **Then** they see options for "Manual Entry" and "Camera + AI"
2. **Given** user selects "Manual Entry", **When** they complete the form, **Then** the recipe is saved to local storage in JTD-compliant format
3. **Given** user selects "Camera + AI", **When** they take a photo of a recipe, **Then** text is extracted and sent to MistralAI for structuring
4. **Given** AI returns structured recipe data, **When** the form is pre-populated, **Then** user can review and edit all fields
5. **Given** some recipe fields are missing after AI processing, **When** user sees missing field indicators, **Then** they can choose "AI Best Guess", "User Input", or "Add Photo" for each missing field
6. **Given** user completes recipe review, **When** they tap "Save", **Then** the recipe is stored locally in the correct format

### Edge Cases
- What happens when photo quality is too poor for text extraction?
- How does system handle when MistralAI service is unavailable?
- What occurs if camera permissions are denied?
- How does the app behave when storage is full?
- What happens if AI returns malformed or incomplete recipe data?

## Requirements

### Functional Requirements
- **FR-001**: System MUST provide two recipe input methods: "Manual Entry" and "Camera + AI"
- **FR-002**: System MUST present a form for manual recipe data entry that complies with JTD recipe schema
- **FR-003**: System MUST integrate with device camera using native photo capture experience
- **FR-004**: System MUST extract text from recipe photos using OCR capability
- **FR-005**: System MUST send extracted text to MistralAI with structured prompts for recipe conversion
- **FR-006**: System MUST pre-populate recipe form with AI-returned structured data
- **FR-007**: System MUST identify and highlight missing or incomplete recipe fields after AI processing
- **FR-008**: System MUST provide three options for handling missing fields: "AI Best Guess", "User Input", and "Add Photo"
- **FR-009**: System MUST allow users to take additional photos to capture missing recipe information
- **FR-010**: System MUST store completed recipes in local storage in JTD-compliant format
- **FR-011**: System MUST handle camera permissions following Apple's Human Interface Guidelines and platform patterns
- **FR-012**: System MUST cache photos and extracted text locally when MistralAI unavailable, using workspace-database with chat UI for deferred processing
- **FR-013**: System MUST support workspace-database for work-in-progress recipes separate from main completed recipe database
- **FR-014**: System MUST check title uniqueness against both main database and workspace-database when creating new recipes
- **FR-015**: System MUST provide chat-style interface for AI interaction with WhatsApp-like menu choices and "typing" indicators
- **FR-016**: System MUST validate AI responses against JTD schema and retry with lint errors up to 2 times before falling back to manual entry
- **FR-017**: System MUST require AI to provide placeholder sentinel values for missing data to maintain JTD schema compliance
- **FR-018**: System MUST implement dynamic timeout for MistralAI responses based on extracted text word count [NEEDS CLARIFICATION: timeout constant/formula TBD]
- **FR-019**: System MUST send new MistralAI request with missing field context when user selects "AI Best Guess" option
- **FR-020**: System MUST persist recipes and day assignments through the storage abstraction described above, ensuring optional UUID assignment, append-only day logs, and adapter interchangeability across web, iOS (CloudKit bridge), and future Android implementations.

### Key Entities
- **Recipe**: Contains structured recipe data (name, ingredients, instructions, timing, etc.) conforming to JTD schema
- **WorkspaceRecipe**: Work-in-progress recipe with status metadata, stored separately from completed recipes
- **RecipePhoto**: Represents captured images of recipe sources with extracted text content
- **MissingField**: Tracks incomplete recipe data fields requiring user attention or AI assistance
- **DayEventLog**: Per-day sequence of add/del events referencing recipe UUIDs used to reconstruct daily meal plans across devices

---

## Review & Acceptance Checklist

### Content Quality
- [x] No implementation details (languages, frameworks, APIs)
- [x] Focused on user value and business needs
- [x] Written for non-technical stakeholders
- [x] All mandatory sections completed

### Requirement Completeness
- [ ] No [NEEDS CLARIFICATION] markers remain (1 timeout formula TBD deferred to planning)
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
- [ ] Review checklist passed (pending clarifications)

---
