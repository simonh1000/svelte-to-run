import { initBackButton } from "./js/popstate";

// Check that service workers are supported
if ("serviceWorker" in navigator && window.location.hostname !== "localhost") {
    // Use the window load event to keep the page load performant
    window.addEventListener("load", () => {
        navigator.serviceWorker.register("/service-worker.js");
    });
}

// pushes to history to support blocking later
initBackButton();

// Material design
import "./App.scss";
// Tailwind
import "./styles.css";
import App from "./App.svelte";

const app = new App({
    target: document.body,
    props: {}
});

export default app;
