{
  "extends": "@mealplanner/typescript-config/base.json",
  "compilerOptions": {
    "target": "ES2022",
    "lib": ["ES2022", "DOM", "DOM.Iterable"],
    "module": "ESNext",
    "moduleResolution": "Bundler",
    "resolveJsonModule": true,
    "baseUrl": ".",
    "paths": {
      "$lib/*": ["./src/lib/*"]
    },
    "types": ["svelte", "vite/client"],
    "allowImportingTsExtensions": true,
    "noEmit": true
  },
  "include": [
    "src/**/*.ts",
    "src/**/*.svelte",
    "vite.config.ts",
    "svelte.config.js"
  ],
  "exclude": [
    "node_modules",
    "dist"
  ]
}
