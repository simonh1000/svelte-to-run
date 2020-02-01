// Set the name of the hidden property and the change event for visibility
var hidden, visibilityChange;
if (typeof document.hidden !== "undefined") {
    // Opera 12.10 and Firefox 18 and later support
    hidden = "hidden";
    visibilityChange = "visibilitychange";
} else if (typeof document.msHidden !== "undefined") {
    hidden = "msHidden";
    visibilityChange = "msvisibilitychange";
} else if (typeof document.webkitHidden !== "undefined") {
    hidden = "webkitHidden";
    visibilityChange = "webkitvisibilitychange";
}

export const monitorVisibility = cb => {
    const handler = () => {
        if (document[hidden]) {
            cb({
                tag: "visible",
                payload: false
            });
        } else {
            // console.log("page visible again");
            cb({
                tag: "visible",
                payload: true
            });
        }
    };
    document.addEventListener(visibilityChange, handler, false);
};

//  wake lock

// The wake lock sentinel.
let wakeLock = null;

// Function that attempts to request a wake lock.
export const requestWakeLock = async cb => {
    try {
        wakeLock = await navigator.wakeLock.request("screen");
        wakeLock.addEventListener("release", () => {
            cb({
                tag: "wakelock",
                payload: "released"
            });
        });
        cb({
            tag: "wakelock",
            payload: "activated"
        });
    } catch (err) {
        console.error(`${err.name}, ${err.message}`);
        cb({
            tag: "error",
            payload: "wakeLock not supported"
        });
    }
};

// Function that attempts to release the wake lock.
export const releaseWakeLock = async () => {
    if (!wakeLock) {
        return;
    }
    try {
        await wakeLock.release();
        wakeLock = null;
    } catch (err) {
        console.error(`${err.name}, ${err.message}`);
    }
};
