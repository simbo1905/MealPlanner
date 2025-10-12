export const STATUS = {
  READY: 'READY',
  LOADING: 'LOADING',
  ERROR: 'ERROR',
  COMPLETE: 'COMPLETE'
} as const;

export type Status = typeof STATUS[keyof typeof STATUS];

export class LoaderState {
  #status: Status = STATUS.READY;
  #isFirstLoad: boolean = true;
  #mounted: boolean = false;

  get status() {
    return this.#status;
  }

  set status(value: Status) {
    this.#status = value;
  }

  get isFirstLoad() {
    return this.#isFirstLoad;
  }

  set isFirstLoad(value: boolean) {
    this.#isFirstLoad = value;
  }

  get mounted() {
    return this.#mounted;
  }

  set mounted(value: boolean) {
    this.#mounted = value;
  }

  loaded() {
    this.#status = STATUS.READY;
    this.#isFirstLoad = false;
  }

  complete() {
    this.#status = STATUS.COMPLETE;
  }

  error() {
    this.#status = STATUS.ERROR;
  }

  reset() {
    this.#status = STATUS.READY;
    this.#isFirstLoad = true;
    this.#mounted = false;
  }
}