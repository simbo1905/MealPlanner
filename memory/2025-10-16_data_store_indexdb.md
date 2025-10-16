# Storage Architecture Notes – IndexedDB vs Native Bridges

**Date**: 2025-10-16  
**Topic**: data-store-indexdb  

## Context
- Prototype `/prototype/04` currently uses browser-local storage; Safari’s IndexedDB instability on iOS makes it unreliable for production.
- Requirement from `specs/004-orc-llm-add-recipe/spec.md` and user discussion: unify storage so the same TypeScript API works for web, iOS (CloudKit), and future Android backends.
- Logging upgrades (WeekSection) already highlight the need for better observability around storage mutations (meal names, dates, before/after state).

## Safari IndexedDB Risk Summary
- 2024 “History of Safari Showstoppers” report captures two active iOS 17 bugs:
  - **Connection Lost regression**: long-lived WKWebView sessions lose IndexedDB transactions without warning; manifests as missing writes.
  - **Aggressive storage eviction**: PWA storage pressure can silently purge IndexedDB data, even for active apps.
- Impact: IndexedDB cannot be trusted as the authoritative store on iOS; prototype usage is acceptable, but production clients need a native-backed solution.

## Storage Pivot – Key Decisions
1. **Pluggable adapters**  
   - Define a Promise-based `StorageAdapter` surface (CRUD + day-event logging) used by Svelte screens and shared packages.  
   - Default adapters: `IndexedDbAdapter` (prototype/web), `CloudKitAdapter` (iOS bridge), `MemoryAdapter` (tests). Future Android adapter must implement the same interface.

2. **Time-ordered UUIDs**  
   - Recipes gain optional `uuid` field using the time-based generator (64-bit epoch + counter + 64-bit random).  
   - Storage layer assigns UUID when absent to support ordering, dedupe, and cross-device reconciliation.

3. **Event-sourced day logs**  
   - `days_v1` collection records append-only events (`$timestamp-op-uuid`).  
   - `add` and `del` events retain minimal recipe snapshot for UI.  
   - Replay events to reconstruct a day’s meal list; tombstones (del events) remain to keep merges conflict-free.

4. **Search posture**  
   - With expected <512 recipes, adapters may use linear scans initially; hooks exist for future indexes (IndexedDB indexes, CloudKit query fields).

5. **Sync & eventual consistency**  
   - CloudKit is treated as authoritative; adapters queue offline changes and reconcile using change tokens.  
   - Tombstones avoid data loss during multi-device merges; compaction can be a deferred optimisation.

## Implementation Worklist (as captured in `prototype/04/IDB_NATIVE.md`)
- Update JTD schemas (`recipe.jtd.json` + new `day-log.jtd.json`) to reflect optional UUID and day events; regenerate TS types.  
- Add storage adapters under `prototype/04/src/lib/storage/` and export from the package entry point.  
- Implement `UUIDGenerator`, `dayEventRebuilder`, and adapter skeletons (IndexedDB/CloudKit/Memory).  
- Create Vitest suites for UUID ordering, day-event replay, and adapter contract compliance (currently `test.todo`).  
- Document storage behaviour in spec (`FR-020`) and memory logs (this file + 2025-10-15 update).  
- CloudKit bridge plan: WKScriptMessageHandler `storage` channel, `CKModifyRecordsOperation` for batched writes, change streams for sync.

## Outstanding Tasks
- Flesh out IndexedDB adapter using `idb` helper library; ensure transactions wrap writes and maintain ordering.  
- Define Swift bridge implementation (`StorageBridge`, `CloudKitRepository`) and message protocol.  
- Expand tests with `fake-indexeddb` under Bun to validate adapter semantics.  
- Update UI flows (manual entry + AI chat) to consume the new adapter once implementations land.  
- Research Android storage equivalent (likely Room/Jetpack with web bridge) for future parity.  

## References
- `memory/2025-10-15-004-orc-llm-add-recipe-user-discussion.md` – updated 2025-10-28 with Safari IndexedDB risks and CloudKit pivot.  
- `specs/004-orc-llm-add-recipe/spec.md` – storage notes and requirement FR-020.  
- `prototype/04/IDB_NATIVE.md` – detailed adapter design, diagrams, test plan, and UI implications.
