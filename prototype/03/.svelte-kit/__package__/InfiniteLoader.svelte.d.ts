import { type Snippet } from "svelte";
import { LoaderState } from "./loaderState.svelte";
declare const InfiniteLoader: import("svelte").Component<{
    triggerLoad: () => Promise<void>;
    loopTimeout?: number;
    loopDetectionTimeout?: number;
    loopMaxCalls?: number;
    intersectionOptions?: Partial<IntersectionObserver>;
    loaderState: LoaderState;
    children: Snippet;
    loading?: Snippet;
    noResults?: Snippet;
    noData?: Snippet;
    coolingOff?: Snippet;
    error?: Snippet<[() => Promise<void>]>;
}, {}, "">;
type InfiniteLoader = ReturnType<typeof InfiniteLoader>;
export default InfiniteLoader;
