import type {
  StorageAdapter,
  StoredRecipe,
  RecipeSearchQuery,
  DayEvent,
  DayLog,
  StorageChange
} from './types'

export class IndexedDbAdapter implements StorageAdapter {
  async initialise(): Promise<void> {
    // TODO: create object stores (recipes_v1, days_v1) via idb openDB
  }

  async putRecipe(recipe: StoredRecipe): Promise<StoredRecipe> {
    throw new Error('IndexedDbAdapter.putRecipe not implemented')
  }

  async getRecipe(uuid: string): Promise<StoredRecipe | null> {
    throw new Error('IndexedDbAdapter.getRecipe not implemented')
  }

  async listRecipes(): Promise<StoredRecipe[]> {
    throw new Error('IndexedDbAdapter.listRecipes not implemented')
  }

  async searchRecipes(query: RecipeSearchQuery): Promise<StoredRecipe[]> {
    throw new Error('IndexedDbAdapter.searchRecipes not implemented')
  }

  async appendDayEvents(isoDate: string, events: DayEvent[]): Promise<DayLog> {
    throw new Error('IndexedDbAdapter.appendDayEvents not implemented')
  }

  async readDayLog(isoDate: string): Promise<DayLog | null> {
    throw new Error('IndexedDbAdapter.readDayLog not implemented')
  }

  async compactDayLog(_isoDate: string): Promise<void> {
    // optional future optimisation
  }

  async *streamChanges(_sinceToken?: string): AsyncIterable<StorageChange> {
    // optional future implementation
    if (false) {
      yield { type: 'recipe', key: '', payload: null }
    }
  }
}
