import type {
  StorageAdapter,
  StoredRecipe,
  RecipeSearchQuery,
  DayEvent,
  DayLog,
  StorageChange
} from './types'

interface BridgeRequest {
  op: string
  payload?: unknown
}

function postBridgeMessage(message: BridgeRequest): Promise<unknown> {
  if (typeof window === 'undefined' || !window.webkit?.messageHandlers?.storage) {
    return Promise.reject(new Error('CloudKit bridge unavailable'))
  }

  return new Promise((resolve, reject) => {
    const callbackId = `storage-${Date.now()}-${Math.random()}`
    const handler = (event: MessageEvent) => {
      if (event.data?.callbackId !== callbackId) return
      window.removeEventListener('message', handler)
      if (event.data?.status === 'ok') {
        resolve(event.data.payload)
      } else {
        reject(new Error(event.data?.message ?? 'Unknown bridge error'))
      }
    }
    window.addEventListener('message', handler)
    window.webkit.messageHandlers.storage.postMessage({ ...message, callbackId })
  })
}

export class CloudKitAdapter implements StorageAdapter {
  async initialise(): Promise<void> {
    await postBridgeMessage({ op: 'initialise' })
  }

  async putRecipe(recipe: StoredRecipe): Promise<StoredRecipe> {
    const payload = await postBridgeMessage({ op: 'putRecipe', payload: recipe })
    return payload as StoredRecipe
  }

  async getRecipe(uuid: string): Promise<StoredRecipe | null> {
    const payload = await postBridgeMessage({ op: 'getRecipe', payload: { uuid } })
    return (payload as StoredRecipe) ?? null
  }

  async listRecipes(): Promise<StoredRecipe[]> {
    const payload = await postBridgeMessage({ op: 'listRecipes' })
    return (payload as StoredRecipe[]) ?? []
  }

  async searchRecipes(query: RecipeSearchQuery): Promise<StoredRecipe[]> {
    const payload = await postBridgeMessage({ op: 'searchRecipes', payload: query })
    return (payload as StoredRecipe[]) ?? []
  }

  async appendDayEvents(isoDate: string, events: DayEvent[]): Promise<DayLog> {
    const payload = await postBridgeMessage({ op: 'appendDayEvents', payload: { isoDate, events } })
    return payload as DayLog
  }

  async readDayLog(isoDate: string): Promise<DayLog | null> {
    const payload = await postBridgeMessage({ op: 'readDayLog', payload: { isoDate } })
    return (payload as DayLog) ?? null
  }

  async compactDayLog(isoDate: string): Promise<void> {
    await postBridgeMessage({ op: 'compactDayLog', payload: { isoDate } })
  }

  async *streamChanges(sinceToken?: string): AsyncIterable<StorageChange> {
    const payload = await postBridgeMessage({ op: 'streamChanges', payload: { sinceToken } })
    if (Array.isArray(payload)) {
      for (const item of payload) {
        yield item as StorageChange
      }
    }
  }
}
