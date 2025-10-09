// Type definitions for browser environment - minimal Storage interface without full DOM lib

export interface Storage {
  readonly length: number
  clear(): void
  getItem(key: string): string | null
  key(index: number): string | null
  removeItem(key: string): void
  setItem(key: string, value: string): void
}

declare global {
  const window:
    | {
        readonly localStorage: Storage
      }
    | undefined
}
