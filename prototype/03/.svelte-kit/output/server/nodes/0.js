

export const index = 0;
let component_cache;
export const component = async () => component_cache ??= (await import('../entries/pages/_layout.svelte.js')).default;
export const imports = ["_app/immutable/nodes/0.B4i3Zqrd.js","_app/immutable/chunks/CWj6FrbW.js","_app/immutable/chunks/BTTHlGxR.js"];
export const stylesheets = ["_app/immutable/assets/0.BxwqF633.css"];
export const fonts = [];
