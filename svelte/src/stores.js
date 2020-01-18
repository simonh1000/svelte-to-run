import { writable } from "svelte/store";

import { startGeolocation } from "../../elm/src/lib.js";
import { dayRun2Run } from "./helpers.js";

export const CHOOSING = "CHOOSING";
export const READY = "READY";
export const ACTIVE = "ACTIVE";
export const FINISHED = "FINISHED";

export var state = writable({
    state: CHOOSING
});

// Choosing -> Ready
// { title,
//   list:[{type, time, accTime}]
//   state
//   location
// }
export const choosing2Ready = function(evt) {
    let base = dayRun2Run(evt.detail.dayRun);
    let readyModel = Object.assign(base, {
        state: READY,
        location: {}
    });
    console.log("ready model", readyModel);
    state.set(readyModel);
    startGeolocation(geoCb);
};

// Ready --> Active
export const ready2Active = function(r) {
    state.update(s => {
        console.log("ready2Active", s);
        return {
            ...s,
            state: ACTIVE,
            start: new Date(),
            waypoints: [s.location]
        };
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
