// Helpers
import { dataRunsRaw } from "../data/dayRuns";

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
    return tmp;
}

export function summariseUpto(list, elapsed) {
    let tmp = list.reduce(
        ({ total, run }, { type, time }) => {
            let newTotal = total + time;
            if (elapsed > newTotal) {
                // we have completed this part of the run
                return {
                    total: newTotal,
                    run: type == RUN ? run + time : run
                };
            } else if (elapsed > total) {
                // we are midway through this run
                let partCompleted = elapsed - total;
                return {
                    total: total + partCompleted,
                    run: type == RUN ? run + partCompleted : run
                };
            } else {
                // we have not reached this part yet
                return { total, run };
            }
        },
        { total: 0, run: 0 }
    );
    return {
        total: Math.round(tmp.total),
        run: Math.round(tmp.run)
    };
}

export function getDayRuns(debug) {
    let rawData = debug ? ["r2", "w1", "r1"] : dataRunsRaw;
    return rawData.map(expand);
}
