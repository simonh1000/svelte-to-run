import App from "./App.svelte";
import { expand } from "./helpers";
import { runs } from "../../elm/src/lib.js";

const app = new App({
    target: document.body,
    props: {
        dayRuns: runs.map(expand)
    }
});

export default app;
