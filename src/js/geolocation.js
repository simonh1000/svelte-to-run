var watchId;
const options = {
    enableHighAccuracy: true
};

export const startGeolocation = function(cb) {
    // console.log("Starting geolocation");
    watchId = navigator.geolocation.watchPosition(
        pos => {
            cb({
                tag: "waypoint",
                payload: pos
            });
        },
        err => {
            console.error("nav", err);
            cb({
                tag: "error",
                payload: JSON.stringify(err, Object.getOwnPropertyNames(err))
            });
        },
        options
    );
};

export const stopGeolocation = function() {
    // console.log("Stopping geolocation");
    navigator.geolocation.clearWatch(watchId);
};
