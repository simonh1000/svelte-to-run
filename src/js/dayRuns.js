// Helpers

const RUN = "run";
const WALK = "walk";

export function expand(run) {
    let go = (acc, item) => {
        let type = item[0] == "w" ? WALK : RUN;
        return [...acc, { type, time: parseInt(item.slice(1)) }];
    };
    return run.reduce(go, []);
}

// [{type,time}] -> [{type, time, accTime}]
// time is in mins
// accTime in seconds
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

// prepares final totals for persistence
export function summarise(list) {
    let tmp = list.reduce(
        ({ total, run }, { type, time }) => {
            return {
                total: total + time,
                run: type == RUN ? run + time : run
            };
        },
        { total: 0, run: 0 }
    );
    return {
        total: tmp.total,
        run: tmp.run
    };
}

// gets last completed run
export function getLastRun(history) {
    let tmp = history.reduce((acc, run) => {
        // if we already have the latest run then keep returning that
        if (acc) return acc;
        // otherwise if we completed a run then
        if (run.completed && typeof run.title === "number") return run.title;
        return acc;
    }, 0);
    // console.log("last run ", tmp);
    return tmp;
}

let fileContent;
try {
    fileContent = require("../dayRuns.json");
} catch (e) {
    fileContent = [];
}
let rawData =
    window.location.pathname == "/debug"
        ? [["r2", "w1", "r1"], ...fileContent]
        : fileContent;
export const dayRuns = rawData.map(expand);
