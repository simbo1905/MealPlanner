import type {
  StorageAdapter,
  StoredRecipe,
  RecipeSearchQuery,
  DayEvent,
  DayLog,
  StorageChange
} from './types'

export class MemoryAdapter implements StorageAdapter {
  private recipes = new Map<string, StoredRecipe>()
  private dayLogs = new Map<string, DayLog>()

  async initialise(): Promise<void> {
    // no-op
  }

  async putRecipe(recipe: StoredRecipe): Promise<StoredRecipe> {
    if (!recipe.uuid) {
      throw new Error('MemoryAdapter requires uuid on StoredRecipe')
    }
    this.recipes.set(recipe.uuid, recipe)
    return recipe
  }

  async getRecipe(uuid: string): Promise<StoredRecipe | null> {
    return this.recipes.get(uuid) ?? null
  }

  async listRecipes(): Promise<StoredRecipe[]> {
    return Array.from(this.recipes.values())
  }

  async searchRecipes(_query: RecipeSearchQuery): Promise<StoredRecipe[]> {
    return Array.from(this.recipes.values())
  }

  async appendDayEvents(isoDate: string, events: DayEvent[]): Promise<DayLog> {
    const existing = this.dayLogs.get(isoDate) ?? { isoDate, events: [] }
    const merged = { ...existing, events: [...existing.events, ...events] }
    this.dayLogs.set(isoDate, merged)
    return merged
  }

  async readDayLog(isoDate: string): Promise<DayLog | null> {
    return this.dayLogs.get(isoDate) ?? null
  }

  async *streamChanges(): AsyncIterable<StorageChange> {
    for (const recipe of this.recipes.values()) {
      yield { type: 'recipe', key: recipe.uuid ?? '', payload: recipe }
    }
    for (const log of this.dayLogs.values()) {
      yield { type: 'day', key: log.isoDate, payload: log }
    }
  }
}
