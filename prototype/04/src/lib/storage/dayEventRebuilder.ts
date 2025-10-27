import type { DayEvent } from './types'

export interface DayMealEntry {
  recipeUuid: string
  occurredAtEpochMs: number
  snapshot?: {
    title: string
    image_url: string
    total_time: number
  }
}

export function rebuildDayMeals(events: DayEvent[]): DayMealEntry[] {
  const sorted = [...events].sort((a, b) => a.occurredAtEpochMs - b.occurredAtEpochMs)
  const map = new Map<string, DayMealEntry>()

  for (const event of sorted) {
    if (event.op === 'add') {
      map.set(event.recipeUuid, {
        recipeUuid: event.recipeUuid,
        occurredAtEpochMs: event.occurredAtEpochMs,
        snapshot: event.snapshot
      })
    } else if (event.op === 'del') {
      map.delete(event.recipeUuid)
    }
  }

  return Array.from(map.values()).sort((a, b) => a.occurredAtEpochMs - b.occurredAtEpochMs)
}
