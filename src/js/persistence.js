import { expand } from "./dayRuns";

// Local storage
const key = "running-app";

export const getRunsData = () => {
    let history = JSON.parse(localStorage.getItem(key)) || [];
    history.map(run => {
        run.start = new Date(run.start);
        run.end = new Date(run.end);
        run.waypoints = expandWPs(run.waypoints);
        return run;
    });
    return history;
};

export const addLatestRun = run => {
    let runs = getRunsData();
    let newRuns = [run, ...runs].map(run => {
        run.waypoints = contractWPs(run.waypoints);
        return run;
    });
    console.log("About to persist", newRuns);
    localStorage.setItem(key, JSON.stringify(newRuns));
    return newRuns;
};

function expandWPs(waypoints) {
    return waypoints.map(wp => {
        wp.coords = { latitude: wp.coords[0], longitude: wp.coords[1] };
        return wp;
    });
}

function contractWPs(waypoints) {
    return waypoints.map(wp => {
        wp.coords = [wp.coords.latitude, wp.coords.longitude];
        return wp;
    });
}
