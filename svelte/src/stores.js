import { writable } from "svelte/store";

import { startGeolocation, runs } from "../../elm/src/lib.js";
import { expand, dayRun2Run, getNextRun } from "./helpers.js";
import { getRunsData } from "./effects";

export const CHOOSING = "CHOOSING";
export const READY = "READY";
export const ACTIVE = "ACTIVE";
export const FINISHED = "FINISHED";

export var state = writable({});

// Choosing -> Ready
// { title,
//   list:[{type, time, accTime}]
//   state
//   location
// }
const readyModel = {
    title: "",
    list: [],
    state: READY,
    location: {}
};
export const choosing2Ready = function(evt) {
    let readyModel = { ...readyModel, ...evt.detail.dayRun };
    console.log("choosing2Ready", readyModel);
    state.set(readyModel);
    startGeolocation(geoCb);
};

// Ready --> Active
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
    state.update(s => {
        let tmp = {
            ...s,
            state: FINISHED,
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

let dayRuns = runs.map(expand);
let history = getRunsData();
const nextRun = getNextRun(history, dayRuns);

const initialModel = {
    ...readyModel,
    title: nextRun.title,
    list: dayRun2Run(nextRun.list)
};
state.set(initialModel);
// const initialModel = {
// state: CHOOSING
// };
