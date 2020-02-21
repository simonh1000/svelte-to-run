export const ppTime = time => {
    let min = Math.floor(time / 60);
    let secs = (time % 60).toString();
    return min + ":" + secs.padStart(2, "0");
};

// [{"timestamp":1579892595364,"coords":{"latitude":50.8528808,"longitude":4.4971837},"watchId":1},
// {"timestamp":1579892595364,"coords":{"latitude":50.8628808,"longitude":4.4971837},"watchId":1}]

export const pathDistance = path => {
    // console.log("pathtodist", path);
    if (path.length > 1) {
        let res = path.slice(1).reduce(
            (acc, pt) => {
                const pt_ = toLatLng(pt.coords);
                return {
                    dst: acc.dst + L.CRS.Earth.distance(pt_, acc.lastPt),
                    lastPt: pt_
                };
            },
            { dst: 0, lastPt: toLatLng(path[0].coords) }
        );
        return (res.dst / 1000).toFixed(2);
    }
    // if no waypoints, distance is 0
    return 0;
};

function toLatLng(coords) {
    return L.latLng(coords.latitude, coords.longitude);
}

const months = [
    "Jan",
    "Feb",
    "Mar",
    "Apr",
    "May",
    "Jun",
    "Jul",
    "Aug",
    "Sep",
    "Oct",
    "Nov",
    "Decr"
];
export const dateFormat = (date, fstr, utc) => {
    utc = utc ? "getUTC" : "get";
    return fstr.replace(/%[YmdHMS]/g, function(m) {
        switch (m) {
            case "%Y":
                return date[utc + "FullYear"](); // no leading zeros required
            case "%m":
                m = 1 + date[utc + "Month"]();
                break;
            case "%d":
                m = date[utc + "Date"]();
                break;
            case "%H":
                m = date[utc + "Hours"]();
                break;
            case "%M":
                m = date[utc + "Minutes"]();
                break;
            case "%S":
                m = date[utc + "Seconds"]();
                break;
            default:
                return m.slice(1); // unknown code, remove %
        }
        // add leading zero if required
        return ("0" + m).slice(-2);
    });
};
