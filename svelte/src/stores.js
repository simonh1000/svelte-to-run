import { writable } from "svelte/store";

import { runs, releaseWakeLock, getRunsData, addLatestRun } from "./lib.js";
import { expand, dayRun2Run, getNextRun } from "./helpers.js";
import { startGeolocation } from "./js/geolocation";

export const CHOOSING = "CHOOSING";
export const READY = "READY";
export const ACTIVE = "ACTIVE";
export const FINISHED = "FINISHED";

export var state = writable({});

// Ready
// { title,
//   list:[{type, time}]
//   state
//   location
// }
const readyModel = {
    title: "",
    list: [],
    state: READY,
    location: {}
};

// PURE
export const mkReadyModel = history => {
    let dayRuns = runs.map(expand);
    const nextRun = getNextRun(history, dayRuns);

    const initialModel = {
        ...readyModel,
        title: nextRun.title,
        list: dayRun2Run(nextRun.list)
    };
    return initialModel;
};

// IMPURE
export const switch2Ready = function(readyModel) {
    console.log("Ready", readyModel);
    state.set(readyModel);
    startGeolocation(geoCb);
};

// Active
// { title,
//   list:[{type, time, accTime}]
//   state
//   start
//   waypoints
// }
export const ready2Active = function(evt) {
    state.update(s => {
        const list = evt.detail.warmUp
            ? [{ type: "walk", time: 5 }, ...s.list]
            : s.list;

        let newState = {
            ...s,
            list: dayRun2Run(list, evt.detail.minute),
            state: ACTIVE,
            start: new Date(),
            waypoints: [s.location]
        };
        console.log("ready2Active", newState);
        return newState;
    });
};

// Active --> Finished
export const active2Finished = function() {
    releaseWakeLock();
    state.update(s => {
        let runs = addLatestRun({ title: s.title, waypoints: s.waypoints });
        let tmp = {
            state: FINISHED,
            runs,
            ended: new Date()
        };
        console.log("active2Finished", tmp);
        return tmp;
    });
};

const geoCb = res => {
    state.update(s => {
        console.log("geoCb", res, s);
        if (s.state == READY) {
            return { ...s, location: res.payload };
        }
        if (s.state == ACTIVE) {
            return {
                ...s,
                waypoints: [...s.waypoints, res.payload]
            };
        }
        return s;
    });
};

// Start
