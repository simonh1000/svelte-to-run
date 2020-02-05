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
export function getNextRun(history) {
    // console.log(history, dayRuns);
    if (history[0]) {
        const lastRun = history[0].title;
        return typeof lastRun !== "undefined" && lastRun < dayRuns.length
            ? lastRun + 1
            : 0;
    }
    return 0;
}

let rawData = require("../dayRuns.json");
rawData = [["r2", "w1", "r1"], ...rawData];
export const dayRuns = rawData.map(expand);
// console.log("dayRuns", dayRuns);
