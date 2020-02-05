import { writable } from "svelte/store";

import { dayRuns, getNextRun, dayRun2Run, summarise } from "./js/dayRuns";

export const SPLASH = "SPLASH";
export const READY = "READY";
export const ACTIVE = "ACTIVE";
export const FINISHED = "FINISHED";
export const PAST_RUNS = "PAST_RUNS";

export var state = writable({ state: SPLASH });

// Ready
//   state: String
//   title,
//   list:[{type, time}]
//   location
export const mkReadyModel = history => {
    const nextRun = getNextRun(history);

    const initialModel = {
        title: "",
        state: READY,
        location: {},
        title: nextRun,
        list: dayRuns[nextRun]
    };
    state.set(initialModel);
};

/*
Active:
  state: String
  title: String
  list:[{type, time, accTime}]
  state: Date
  start: Date
  wakeLock: Bool
  waypoints
*/
export const ready2Active = function(evt) {
    state.update(s => {
        const list = evt.detail.warmUp
            ? [{ type: "walk", time: 5 }, ...s.list]
            : s.list;

        let newState = {
            title: s.title,
            list: dayRun2Run(list, evt.detail.minute),
            state: ACTIVE,
            start: new Date(),
            wakeLock: false,
            waypoints: s.location.hasOwnProperty("coords") ? [s.location] : []
        };
        console.log("ready2Active", newState);
        return newState;
    });
};

// Finished
//   state
//   title,
//   list:[{type, time, accTime}]
//   start
//   end
//   waypoints
// }
export const active2Finished = function(evt) {
    state.update(s => {
        let tmp = {
            ...s,
            state: FINISHED,
            waypoints: evt.detail.waypoints,
            end: new Date()
        };
        console.log("active2Finished", tmp);
        return tmp;
    });
};

// PAST_RUNS
// state = {state, history}
// history = [{title, start, end, waypoints, running:Int, total: Int}]
export const mkPastRunsModel = history => {
    state.update(s => {
        let tmp = {
            state: PAST_RUNS,
            history
        };
        console.log("active2Finished", tmp);
        return tmp;
    });
};

// Call backs that change state

export const geoCb = res => {
    if (res.tag == "error") return;

    state.update(s => {
        console.log("geoCb", res);
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

// helps keep track that the wake lock is working
export const wakelockCb = res => {
    if (res.tag == "error") {
        console.log("wakeLock", res.payload);
        return;
    }

    state.update(s => {
        if (s.state == ACTIVE) {
            return {
                ...s,
                wakeLock: res.payload
            };
        }
        return s;
    });
};
