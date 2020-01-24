var watchId;

export const startGeolocation = function(cb) {
    console.log("Starting geolocation");
    watchId = navigator.geolocation.watchPosition(
        pos => {
            cb({
                tag: "waypoint",
                payload: {
                    timestamp: pos.timestamp,
                    coords: {
                        latitude: pos.coords.latitude,
                        longitude: pos.coords.longitude
                    }
                }
            });
        },
        err => {
            console.error("nav", err);
            cb({
                tag: "error",
                payload: JSON.stringify(err, Object.getOwnPropertyNames(err))
            });
        }
    );
};

export const stopGeolocation = function() {
    navigator.geolocation.clearWatch(watchId);
};
