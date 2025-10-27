/**
 * Generator for time-based UUIDs with sub-millisecond ordering.
 *
 * The most significant 64 bits encode epoch milliseconds and a 20-bit counter.
 * The least significant 64 bits are random for global uniqueness.
 */
export class UUIDGenerator {
  private static sequence = 0n
  private static lastEpochMs = 0n

  private static epochTimeThenCounterMsb(): bigint {
    const now = BigInt(Date.now())

    if (now === this.lastEpochMs) {
      this.sequence = (this.sequence + 1n) & 0xFFFFFn
    } else {
      this.sequence = 0n
      this.lastEpochMs = now
    }

    return (now << 20n) | this.sequence
  }

  private static randomLong(): bigint {
    const buffer = new Uint8Array(8)
    crypto.getRandomValues(buffer)

    let result = 0n
    for (let i = 0; i < buffer.length; i++) {
      result = (result << 8n) | BigInt(buffer[i])
    }
    return result
  }

  private static toHex64(value: bigint): string {
    return value.toString(16).padStart(16, '0')
  }

  public static generateUUID(): string {
    const msb = this.epochTimeThenCounterMsb()
    const lsb = this.randomLong()

    const msbHex = this.toHex64(msb)
    const lsbHex = this.toHex64(lsb)

    return `${msbHex.slice(0, 8)}-${msbHex.slice(8, 12)}-${msbHex.slice(12, 16)}-${lsbHex.slice(0, 4)}-${lsbHex.slice(4, 16)}`
  }

  public static dissect(uuid: string): { issuedAtEpochMs: number } {
    const hex = uuid.replace(/-/g, '')
    const msbHex = hex.slice(0, 16)
    const msb = BigInt(`0x${msbHex}`)
    const epochMs = Number(msb >> 20n)
    return { issuedAtEpochMs: epochMs }
  }
}
