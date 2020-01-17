"use strict";

require("./styles.css");

import {
    runs,
    say,
    startGeolocation,
    enableSound,
    requestWakeLock,
    releaseWakeLock,
    synthesise
} from "./lib";

// Check that service workers are supported
if ("serviceWorker" in navigator) {
    // Use the window load event to keep the page load performant
    window.addEventListener("load", () => {
        navigator.serviceWorker.register("/service-worker.js");
    });
}

const { Elm } = require("./Main");
var app = Elm.Main.init({ flags: runs });

app.ports.toJs.subscribe(data => {
    console.log(data);
    switch (data.tag) {
        case "announce":
            say(data.payload);
            break;
        case "ready":
            startGeolocation(app.ports.fromJs.send);
            enableSound();
            requestWakeLock(app.ports.fromJs.send);
            break;
        case "speak":
            synthesise(data.payload);
            break;
        case "finish":
            releaseWakeLock();
            break;
        default:
            console.error(data.tag);
    }
});
