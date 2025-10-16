# User Discussion Notes: 004-orc-llm-add-recipe

**Date**: 2025-10-15
**Topic**: AI-Powered Recipe Onboarding (OCR + LLM)
**Context**: Additional requirements and architectural decisions from user discussion

## Workspace Database Architecture

### Core Concept
- **Workspace Database**: Separate storage for work-in-progress recipes, distinct from main completed recipe database
- **Main Database**: Contains only "Complete" recipes that are searchable and available for general use
- **Metadata Endpoint**: Workspace recipes visible only through dedicated endpoint, not main API
- **Title Uniqueness Check**: System checks against both main database AND workspace-database when creating new recipes

### Recipe Status Workflow
- Recipes start with minimal data (title + status) when user begins adding
- Status transitions through workflow stages until reaching "Complete"
- Only "Complete" status recipes appear in main database/search results
- UUID allocation happens immediately upon recipe creation (time-ordered)
- No blocking on title warnings - user can proceed despite conflicts

## AI Service Integration Details

### Offline/MistralAI Unavailable Handling
- **Fallback Strategy**: Collect photos and extracted text locally when MistralAI unavailable
- **Chat UI Interface**: WhatsApp-style messaging with "typing" indicators during AI processing
- **Deferred Processing**: Store photos + text in workspace-database, retry when service returns
- **Multiple Photos**: Encourage users to take additional photos during outages
- **User Experience**: "Do you want to add more images? y/n" prompt after 10s timeout

### AI Response Validation
- **JTD Schema Validation**: All AI responses validated against JTD recipe schema
- **Error Recovery**: Send lint errors back to MistralAI for fixes (maximum 2 retry cycles)
- **Placeholder Strategy**: AI must provide sentinel values for missing data to maintain schema compliance
- **Fallback**: Manual data entry form if validation fails after retries

### AI Best Guess Implementation
- **New Request**: Selecting "AI Best Guess" triggers fresh MistralAI request with missing field context
- **No Caching**: Each request is independent, not using cached/local inference

## User Interface Design

### Chat Interface Pattern
- **WhatsApp Style**: Conversational UI with menu choices/buttons
- **System Messages**: Auto-generated bubbles showing extracted text (expandable for power users)
- **Typing Indicators**: Show "MistralAI is typing..." during processing
- **Menu Choices**: Quick action buttons for user decisions

### Photo Capture Flow
- **Native Experience**: Use standard iOS camera patterns, no custom implementation
- **Permission Handling**: Follow Apple's Human Interface Guidelines exactly
- **Use/Retake**: Standard "use photo" or "retake" flow after capture

## Technical Implementation Notes

### Timeout Strategy
- **Dynamic Timeout**: Based on extracted text word count (formula TBD)
- **Word Count Constant**: Timeout = word_count * constant (constant value to be determined)

### Data Storage Strategy
- **Local Storage**: All recipe data stored locally in JTD-compliant format
- **Workspace Separation**: Clear boundary between work-in-progress and completed recipes
- **Photo Association**: Photos linked to workspace recipes for future reference/journal functionality

### Future Extensibility
- **Shopping List Integration**: Workspace database will support user-specific ingredient mapping
- **Database Shipping**: Potential for bulk complete recipe distribution (separate from user workspace)
- **Journal Feature**: Photo collection against recipes for meal tracking

## Error Handling Scenarios

### Service Failures
- **MistralAI Down**: Graceful fallback to local collection mode
- **Network Issues**: Queue requests, retry automatically when connectivity returns
- **Validation Failures**: Up to 2 retry attempts before manual fallback

### User Edge Cases
- **Poor Photo Quality**: System continues with available text, prompts for additional photos
- **Permission Denied**: Follow Apple guidelines exactly (no custom handling)
- **Storage Full**: Standard iOS storage error handling

## Prompt Engineering Strategy

### System Prompt Requirements
- Must instruct AI to provide placeholder/sentinel values for incomplete data
- Should guide AI to ask clarifying questions when data is ambiguous
- Include JTD schema compliance requirements
- Specify fallback to sentinel values rather than leaving fields empty

### Testing Approach
- **Promptfoo Testing**: Extensive prompt testing to minimize validation errors
- **Error Rate Monitoring**: Track frequency of validation failures requiring retries
- **User Feedback Loop**: Monitor success rates of "AI Best Guess" functionality

---

**Next Steps**: These architectural decisions should be incorporated into the implementation plan and task breakdown for the 004-orc-llm-add-recipe feature.

---

## 2025-10-28 Update – Storage & iOS Constraints

- **Safari IndexedDB risk**: The 2024 “History of Safari Showstoppers” recap highlights two blocking defects still affecting iOS 17—(1) the *Connection Lost* regression that randomly severs IndexedDB transactions in long-lived WKWebView contexts and (2) aggressive storage eviction that purges databases without warning when PWA storage pressure spikes. Together they make Safari IndexedDB an unacceptable primary store for MealPlanner.
- **Platform pivot**: Adopt a storage abstraction with identical APIs across implementations. Default adapter = IndexedDB (prototype/web) for fast iteration; production iOS adapter = Swift bridge backed by CloudKit private database; future Android adapter = bridge to Google’s syncable store (TBD). Same TypeScript surface prevents UI rewrites.
- **Bridge contract**: Expose a Promise-based CRUD + query interface to WKWebView via `window.mealplannerStorage`. Native implementations must guarantee: idempotent `putRecipe`, soft-deletes via tombstones, ordered change feeds, and eventual consistency when reconnecting.
- **Collections**: 
  - `recipes_v1`: canonical recipe documents keyed by optional time-ordered UUID (`uuid` field) with snake_case payload from JTD schema. Same identifier doubles as primary key in CloudKit (`CKRecord.ID`) and in IndexedDB.
  - `days_v1`: per-day log collection keyed by ISO date string. Each entry stores an append-only array of events (`$ts-add-$uuid` / `$ts-del-$uuid`). UI materialises the day view by replaying the log in timestamp order, enabling merge-friendly sync and offline tombstones.
- **Search strategy**: With ≤512 recipes, initial implementation can run linear scans in adapters while leaving hooks for indexed search backends later. Documented fallback avoids premature optimisation.
- **Sync posture**: Treat CloudKit as authoritative; adapters should queue events offline and reconcile using last-seen change tokens. Tombstones ensure deletions survive multi-device merges without conflict.
