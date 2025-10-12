import * as server from '../entries/pages/_page.server.ts.js';

export const index = 2;
let component_cache;
export const component = async () => component_cache ??= (await import('../entries/pages/_page.svelte.js')).default;
export { server };
export const server_id = "src/routes/+page.server.ts";
export const imports = ["_app/immutable/nodes/2.CAe6dqSA.js","_app/immutable/chunks/CWj6FrbW.js","_app/immutable/chunks/BTTHlGxR.js","_app/immutable/chunks/CW6n_GIl.js","_app/immutable/chunks/0wlRkrDj.js"];
export const stylesheets = ["_app/immutable/assets/2.C59Pef3X.css"];
export const fonts = [];
