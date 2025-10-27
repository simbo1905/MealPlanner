import type { Recipe } from '@mealplanner/recipe-types'

export interface TimeOrderedUuid {
  uuid: string
  issuedAtEpochMs: number
}

export interface StoredRecipe extends Recipe {
  uuid?: string
  createdAtEpochMs: number
  updatedAtEpochMs: number
}

export type DayEventOperation = 'add' | 'del'

export interface DayEvent {
  id: string
  isoDate: string
  op: DayEventOperation
  recipeUuid: string
  occurredAtEpochMs: number
  snapshot?: {
    title: string
    image_url: string
    total_time: number
  }
}

export interface DayLog {
  isoDate: string
  events: DayEvent[]
  lastIndexedChangeToken?: string
}

export interface RecipeSearchQuery {
  query?: string
  maxTime?: number
  ingredients?: string[]
  excludeAllergens?: string[]
  limit?: number
  sortBy?: 'title' | 'total_time' | 'relevance'
}

export interface StorageChange {
  type: 'recipe' | 'day'
  key: string
  payload?: unknown
  changeToken?: string
}

export interface StorageAdapter {
  initialise(): Promise<void>
  putRecipe(recipe: StoredRecipe): Promise<StoredRecipe>
  getRecipe(uuid: string): Promise<StoredRecipe | null>
  listRecipes(): Promise<StoredRecipe[]>
  searchRecipes(query: RecipeSearchQuery): Promise<StoredRecipe[]>
  appendDayEvents(isoDate: string, events: DayEvent[]): Promise<DayLog>
  readDayLog(isoDate: string): Promise<DayLog | null>
  compactDayLog?(isoDate: string): Promise<void>
  streamChanges?(sinceToken?: string): AsyncIterable<StorageChange>
}
