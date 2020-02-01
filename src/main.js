// Check that service workers are supported
if ("serviceWorker" in navigator) {
    // Use the window load event to keep the page load performant
    window.addEventListener("load", () => {
        navigator.serviceWorker.register("/service-worker.js");
    });
}

import "./App.scss";
import "./styles.css";
import App from "./App.svelte";

const app = new App({
    target: document.body,
    props: {}
});

export default app;
