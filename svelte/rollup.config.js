import svelte from "rollup-plugin-svelte";
import resolve from "@rollup/plugin-node-resolve";
import commonjs from "@rollup/plugin-commonjs";
import postcss from "rollup-plugin-postcss";

const spa = false;
const nollup = !!process.env.NOLLUP;
const watch = !!process.env.ROLLUP_WATCH;
const useLiveReload = !!process.env.LIVERELOAD;

const dev = watch || useLiveReload;
const production = !dev;

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
            emitCss: true
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
        serve()
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
