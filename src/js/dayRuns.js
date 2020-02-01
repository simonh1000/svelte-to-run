// Helpers

export function expand(run) {
    let go = (acc, item) => {
        let type = item[0] == "w" ? "walk" : "run";
        return [...acc, { type, time: parseInt(item.slice(1)) }];
    };
    return run.reduce(go, []);
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

export function getNextRun(history) {
    // console.log(history, dayRuns);
    if (history[0]) {
        const lastRun = history[0].title;
        return lastRun && lastRun < dayRuns.length ? lastRun + 1 : 0;
    }
    return 0;
}

const rawData = require("../dayRuns.json");
export const dayRuns = rawData.map(expand);
// console.log("dayRuns", dayRuns);
