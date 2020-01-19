import svelte from "rollup-plugin-svelte-hot";
import livereload from "rollup-plugin-livereload";
import { terser } from "rollup-plugin-terser";
import hmr, { autoCreate } from "rollup-plugin-hot";

import resolve from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";
import postcss from "rollup-plugin-postcss";

const spa = false;
const nollup = !!process.env.NOLLUP;
const watch = !!process.env.ROLLUP_WATCH;
const useLiveReload = !!process.env.LIVERELOAD;

const dev = watch || useLiveReload;
const production = !dev;

const hot = watch && !useLiveReload;

module.exports = {
    input: "src/main.js",
    output: {
        sourcemap: true,
        format: "iife",
        name: "app",
        file: "public/build/bundle.js"
    },
    plugins: [
        svelte({
            // enable run-time checks when not in production
            dev: !production,
            // we'll extract any component CSS out into
            // a separate file — better for performance
            ...(!hot && {
                css: css => {
                    css.write("public/build/bundle.css");
                }
            }),
            hot: hot && {
                // optimistic will try to recover from runtime
                // errors during component init
                optimistic: true,
                // turn on to disable preservation of local component
                // state -- i.e. non exported `let` variables
                noPreserveState: false
            }
        }),
        resolve({
            browser: true,
            dedupe: importee =>
                importee === "svelte" || importee.startsWith("svelte/")
        }),
        commonjs(),
        postcss({
            extract: true,
            minimize: true,
            use: [
                [
                    "sass",
                    {
                        includePaths: [
                            "./src",
                            "./src/styles",
                            "./node_modules"
                        ]
                    }
                ]
            ]
        }),
        // In dev mode, call `npm run start:dev` once
        // the bundle has been generated
        dev && !nollup && serve(),

        // Watch the `public` directory and refresh the
        // browser on changes when not in production
        useLiveReload && livereload("public"),

        // If we're building for production (npm run build
        // instead of npm run dev), minify
        production && terser(),

        // Automatically create missing imported files. This helps keeping
        // the HMR server alive, because Rollup watch tends to crash and
        // hang indefinitely after you've tried to import a missing file.
        hot &&
            autoCreate({
                include: "src/**/*",
                // Set false to prevent recreating a file that has just been
                // deleted (Rollup watch will crash when you do that though).
                recreate: true
            })

        // this conflicts with Material Design
        // hmr({
        //     public: "public",
        //     inMemory: true,
        //     // This is needed, otherwise Terser (in npm run build) chokes
        //     // on import.meta. With this option, the plugin will replace
        //     // import.meta.hot in your code with module.hot, and will do
        //     // nothing else.
        //     compatModuleHot: !hot
        // })
    ],
    watch: {
        clearScreen: false
    }
};

function serve() {
    let started = false;
    return {
        name: "svelte/template:serve",
        writeBundle() {
            if (!started) {
                started = true;
                const flags = ["run", "start", "--", "--dev"];
                if (spa) {
                    flags.push("--single");
                }
                require("child_process").spawn("npm", flags, {
                    stdio: ["ignore", "inherit", "inherit"],
                    shell: true
                });
            }
        }
    };
}
