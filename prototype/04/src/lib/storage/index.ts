import { CloudKitAdapter } from './cloudKitAdapter'
import { IndexedDbAdapter } from './indexedDbAdapter'
import { MemoryAdapter } from './memoryAdapter'
import type { StorageAdapter } from './types'

export function createStorageAdapter(): StorageAdapter {
  if (typeof window !== 'undefined' && window.webkit?.messageHandlers?.storage) {
    return new CloudKitAdapter()
  }

  if (typeof indexedDB !== 'undefined') {
    return new IndexedDbAdapter()
  }

  return new MemoryAdapter()
}

export * from './types'
export * from './uuidGenerator'
export * from './dayEventRebuilder'
