export function expand(run) {
    let go = (acc, item) => {
        let type = item[0] == "w" ? "walk" : "run";
        return [...acc, { type, time: parseInt(item.slice(1)) }];
    };
    return { title: run[0], list: run[1].reduce(go, []) };
}

export function getNextRun(history, dayRuns) {
    console.log(history, dayRuns);
    if (history.length) {
        let lastRun = history[0].title;
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

// dayRun2Run({
//     title: "simon",
//     list: [
//         { type: "run", time: 1 },
//         { type: "walk", time: 1 },
//         { type: "run", time: 1 }
//     ]
// });
