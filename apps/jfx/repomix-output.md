This file is a merged representation of a subset of the codebase, containing specifically included files, combined into a single document by Repomix.

# File Summary

## Purpose
This file contains a packed representation of a subset of the repository's contents that is considered the most important context.
It is designed to be easily consumable by AI systems for analysis, code review,
or other automated processes.

## File Format
The content is organized as follows:
1. This summary section
2. Repository information
3. Directory structure
4. Repository files (if enabled)
5. Multiple file entries, each consisting of:
  a. A header with the file path (## File: path/to/file)
  b. The full contents of the file in a code block

## Usage Guidelines
- This file should be treated as read-only. Any changes should be made to the
  original repository files, not this packed version.
- When processing this file, use the file path to distinguish
  between different files in the repository.
- Be aware that this file may contain sensitive information. Handle it with
  the same level of security as you would the original repository.

## Notes
- Some files may have been excluded based on .gitignore rules and Repomix's configuration
- Binary files are not included in this packed representation. Please refer to the Repository Structure section for a complete list of file paths, including binary files
- Only files matching these patterns are included: **/*.java, **/*.gradle, **/*.md, **/*.ts, **/package.json, **/*.html
- Files matching patterns in .gitignore are excluded
- Files matching default ignore patterns are excluded
- Files are sorted by Git change count (files with more changes are at the bottom)

# Directory Structure
```
demo/
  helloworld/
    src/
      lib/
        index.ts
      routes/
        +layout.ts
      app.d.ts
      app.html
    package.json
    README.md
    vite.config.ts
src/
  main/
    java/
      mealplanner/
        jfx/
          HelloSvelteApp.java
build.gradle
settings.gradle
```

# Files

## File: demo/helloworld/src/lib/index.ts
````typescript
// place files you want to import through the `$lib` alias in this folder.
````

## File: demo/helloworld/src/routes/+layout.ts
````typescript
export const prerender = true;
````

## File: demo/helloworld/src/app.d.ts
````typescript
// See https://svelte.dev/docs/kit/types#app.d.ts
// for information about these interfaces
declare global {
	namespace App {
		// interface Error {}
		// interface Locals {}
		// interface PageData {}
		// interface PageState {}
		// interface Platform {}
	}
}

export {};
````

## File: demo/helloworld/src/app.html
````html
<!doctype html>
<html lang="en">
	<head>
		<meta charset="utf-8" />
		<meta name="viewport" content="width=device-width, initial-scale=1" />
		%sveltekit.head%
	</head>
	<body data-sveltekit-preload-data="hover">
		<div style="display: contents">%sveltekit.body%</div>
	</body>
</html>
````

## File: demo/helloworld/package.json
````json
{
	"name": "helloworld",
	"private": true,
	"version": "0.0.1",
	"type": "module",
	"scripts": {
		"dev": "vite dev",
		"build": "vite build",
		"preview": "vite preview",
		"prepare": "svelte-kit sync || echo ''",
		"check": "svelte-kit sync && svelte-check --tsconfig ./tsconfig.json",
		"check:watch": "svelte-kit sync && svelte-check --tsconfig ./tsconfig.json --watch"
	},
	"devDependencies": {
		"@sveltejs/adapter-auto": "^6.1.0",
		"@sveltejs/adapter-static": "^3.0.10",
		"@sveltejs/kit": "^2.43.2",
		"@sveltejs/vite-plugin-svelte": "^6.2.0",
		"svelte": "^5.39.5",
		"svelte-check": "^4.3.2",
		"typescript": "^5.9.2",
		"vite": "^7.1.7"
	}
}
````

## File: demo/helloworld/README.md
````markdown
# sv

Everything you need to build a Svelte project, powered by [`sv`](https://github.com/sveltejs/cli).

## Creating a project

If you're seeing this, you've probably already done this step. Congrats!

```sh
# create a new project in the current directory
npx sv create

# create a new project in my-app
npx sv create my-app
```

## Developing

Once you've created a project and installed dependencies with `npm install` (or `pnpm install` or `yarn`), start a development server:

```sh
npm run dev

# or start the server and open the app in a new browser tab
npm run dev -- --open
```

## Building

To create a production version of your app:

```sh
npm run build
```

You can preview the production build with `npm run preview`.

> To deploy your app, you may need to install an [adapter](https://svelte.dev/docs/kit/adapters) for your target environment.
````

## File: demo/helloworld/vite.config.ts
````typescript
import { sveltekit } from '@sveltejs/kit/vite';
import { defineConfig } from 'vite';

export default defineConfig({
	plugins: [sveltekit()]
});
````

## File: src/main/java/mealplanner/jfx/HelloSvelteApp.java
````java
package mealplanner.jfx;

import javafx.application.Application;
import javafx.scene.Scene;
import javafx.scene.web.WebView;
import javafx.stage.Stage;

import java.nio.file.Paths;

public class HelloSvelteApp extends Application {

    @Override
    public void start(Stage primaryStage) {
        WebView webView = new WebView();
        
        String indexPath = Paths.get("demo/helloworld/build/index.html")
            .toAbsolutePath()
            .toUri()
            .toString();
        
        webView.getEngine().load(indexPath);
        
        Scene scene = new Scene(webView, 800, 600);
        primaryStage.setTitle("Hello Svelte");
        primaryStage.setScene(scene);
        primaryStage.show();
    }

    public static void main(String[] args) {
        launch(args);
    }
}
````

## File: build.gradle
````
plugins {
    id 'application'
    id 'org.openjfx.javafxplugin' version '0.1.0'
}

group = 'mealplanner'
version = '1.0-SNAPSHOT'

repositories {
    mavenCentral()
}

javafx {
    version = "25"
    modules = ['javafx.controls', 'javafx.web']
}

application {
    mainClass = 'mealplanner.jfx.HelloSvelteApp'
}

java {
    toolchain {
        languageVersion = JavaLanguageVersion.of(25)
    }
}
````

## File: settings.gradle
````
rootProject.name = 'mealplanner-jfx'
````
