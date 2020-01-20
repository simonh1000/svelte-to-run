import { writable } from "svelte/store";

import { runs } from "./js/dayRuns";

export const READY = "READY";
export const ACTIVE = "ACTIVE";
export const FINISHED = "FINISHED";
export const PAST_RUNS = "PAST_RUNS";

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
let dayRuns = runs.map(expand);

export const mkReadyModel = runsData => {
    const nextRun = getNextRun(runsData, dayRuns);

    const initialModel = {
        ...readyModel,
        title: nextRun.title,
        list: dayRun2Run(nextRun.list)
    };
    state.set(initialModel);
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
export const active2Finished = function(evt) {
    state.update(s => {
        let tmp = {
            state: FINISHED,
            runs: evt.detail.runs,
            ended: new Date()
        };
        console.log("active2Finished", tmp);
        return tmp;
    });
};

// PAST_RUNS
// state = {state, history}
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

// Helpers

export function expand(run) {
    let go = (acc, item) => {
        let type = item[0] == "w" ? "walk" : "run";
        return [...acc, { type, time: parseInt(item.slice(1)) }];
    };
    return { title: run[0], list: run[1].reduce(go, []) };
}

export function getNextRun(runsData, dayRuns) {
    console.log(runsData, dayRuns);
    if (runsData.length) {
        let lastRun = runsData[0].title;
        let nextRun = dayRuns.reduce(
            (acc, r) => {
                if (acc.prev == lastRun) {
                    return { run: r, prev: r.title };
                } else {
                    return { ...acc, prev: r.title };
                }
            },
            { prev: null }
        );
        return nextRun.run || dayRuns[0];
    } else {
        return dayRuns[0];
    }
}

// [{type,time}] -> [{type, time, accTime}]
export function dayRun2Run(list, min) {
    let convertedData = list.reduce(
        ({ accTime, accItems }, item) => {
            let tmp = accTime + item.time * min;
            return {
                accTime: tmp,
                accItems: [...accItems, { ...item, accTime: tmp }]
            };
        },
        { accTime: 0, accItems: [] }
    );
    return convertedData.accItems;
}
