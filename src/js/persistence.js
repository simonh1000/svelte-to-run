// Local storage
const STORAGE_KEY = "running-app";
const BACKUP = "run-backup";

export const getRunsData = () => {
    let data = JSON.parse(localStorage.getItem(STORAGE_KEY)) || [];

    let history;
    if (needsMigration(data)) {
        history = migrate(data);
        // save as soon as migrated
        // setRunsData(history);
    } else {
        history = data;
    }

    // console.log("history", history);
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

export const saveRunHistory = history => {
    let newRuns = history.map(run => {
        run.waypoints = contractWPs(run.waypoints);
        return run;
    });
    setRunsData(newRuns);
    clearBackup();
};

const setRunsData = newRuns => {
    console.log("About to persist", newRuns);
    localStorage.setItem(STORAGE_KEY, JSON.stringify(newRuns));
};

export const backupRun = run => {
    console.log("About to backup", run);
    localStorage.setItem(BACKUP, JSON.stringify(run));
};

export const getBackup = () => {
    let run = localStorage.getItem(BACKUP);
    console.log("getBackup", run);
    return run;
};

const clearBackup = () => {
    console.log("Removing backup");
    localStorage.removeItem(BACKUP);
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

function needsMigration(history) {
    // return window.location.pathname == "/migrate";
    let res = typeof history[0].completed;
    console.log("needs migration?", res === "undefined");
    return res === "undefined";
    // return window.location.pathname == "/migrate";
}

function migrate(history) {
    console.log("before migration", history);
    return history.map(run => {
        return { ...run, completed: true };
    });
}
