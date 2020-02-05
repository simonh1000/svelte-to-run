import { dayRuns, summarise } from "./dayRuns";

// Local storage
const key = "running-app";

export const getRunsData = () => {
    let data = JSON.parse(localStorage.getItem(key)) || [];

    let history;
    if (needsMigration(data)) {
        history = migrate(data);
        // save as soon as migrated
        setRunsData(history);
    } else {
        history = data;
    }

    console.log("history", history);
    return history.map(run => {
        run.start = new Date(run.start);
        run.end = new Date(run.end);
        run.waypoints = expandWPs(run.waypoints);
        return run;
    });
};

export const addLatestRun = run => {
    let runs = getRunsData();
    let newRuns = [run, ...runs].map(run => {
        run.waypoints = contractWPs(run.waypoints);
        return run;
    });
    setRunsData(newRuns);
    return newRuns;
};

const setRunsData = newRuns => {
    console.log("About to persist", newRuns);
    localStorage.setItem(key, JSON.stringify(newRuns));
};

// Helpers

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

//  Migration

function needsMigration(data) {
    return window.location.pathname == "/migrate";
}

function migrate(data) {
    console.log("before migration", data);
    const tmp = data.map(run => {
        run.title = run.title + 1;
        return run;
    });
    return tmp;
}
