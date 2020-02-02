import { dayRuns, summarise } from "./dayRuns";

// Local storage
const key = "running-app";

export const getRunsData = () => {
    let data = JSON.parse(localStorage.getItem(key)) || [];

    let history;
    if (needsMigration(data)) {
        history = migrate(data);
        // save as soon as migrated
        // setRunsData(history);
    } else {
        history = data;
    }

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
    console.log("About to persist", newRuns);
    setRunsData(newRuns);
    return newRuns;
};

const setRunsData = newRuns => {
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
    const ret =
        data.length > 0 &&
        !data.every(r => {
            typeof r.total !== "undefined";
        });
    console.log("needsMigration?", data, ret);
    return ret;
}

function migrate(data) {
    console.log("migrate", dayRuns);
    console.log("migrate", data);
    return data.map(r => {
        // console.log(r);
        let tmp = summarise(dayRuns[r.title]);
        let res = {
            ...r,
            run: tmp.run,
            // here we add the 5 minutes of walking beforehand
            total: tmp.total + 5
        };
        // console.log("res", res);
        // calculate distance and total from that data and add 5 mins walking at beginning
        return res;
    });
}
