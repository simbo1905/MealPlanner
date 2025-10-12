export declare const STATUS: {
    readonly READY: "READY";
    readonly LOADING: "LOADING";
    readonly COMPLETE: "COMPLETE";
    readonly ERROR: "ERROR";
};
export declare class LoaderState {
    isFirstLoad: boolean;
    status: "READY" | "LOADING" | "COMPLETE" | "ERROR";
    mounted: boolean;
    loaded: () => void;
    complete: () => void;
    reset: () => void;
    error: () => void;
}
