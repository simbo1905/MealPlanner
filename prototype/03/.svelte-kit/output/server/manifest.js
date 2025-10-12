export const manifest = (() => {
function __memo(fn) {
	let value;
	return () => value ??= (value = fn());
}

return {
	appDir: "_app",
	appPath: "_app",
	assets: new Set(["favicon.png","fonts/overpass-latin-300.woff2","fonts/overpass-latin-600.woff2","svelte-logo.svg","svelte-vtuber.png"]),
	mimeTypes: {".png":"image/png",".woff2":"font/woff2",".svg":"image/svg+xml"},
	_: {
		client: {start:"_app/immutable/entry/start.DZK0j-Zn.js",app:"_app/immutable/entry/app.DzEA9-8d.js",imports:["_app/immutable/entry/start.DZK0j-Zn.js","_app/immutable/chunks/DXFKh6Rt.js","_app/immutable/chunks/0wlRkrDj.js","_app/immutable/chunks/BTTHlGxR.js","_app/immutable/entry/app.DzEA9-8d.js","_app/immutable/chunks/BTTHlGxR.js","_app/immutable/chunks/0wlRkrDj.js","_app/immutable/chunks/CWj6FrbW.js","_app/immutable/chunks/CW6n_GIl.js"],stylesheets:[],fonts:[],uses_env_dynamic_public:false},
		nodes: [
			__memo(() => import('./nodes/0.js')),
			__memo(() => import('./nodes/1.js')),
			__memo(() => import('./nodes/2.js'))
		],
		remotes: {
			
		},
		routes: [
			{
				id: "/",
				pattern: /^\/$/,
				params: [],
				page: { layouts: [0,], errors: [1,], leaf: 2 },
				endpoint: null
			},
			{
				id: "/api/data",
				pattern: /^\/api\/data\/?$/,
				params: [],
				page: null,
				endpoint: __memo(() => import('./entries/endpoints/api/data/_server.ts.js'))
			}
		],
		prerendered_routes: new Set([]),
		matchers: async () => {
			
			return {  };
		},
		server_assets: {}
	}
}
})();
