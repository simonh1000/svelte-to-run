export const runs = [
    ["day 0", ["r2", "w1", "r1"]],
    ["day 1", ["r1", "w1", "r1", "w1", "r2", "w2", "r2", "w2", "r3"]],
    ["day 2", ["r1", "w1", "r1", "w1", "r2", "w2", "r3", "w3", "r3"]],
    ["day 3", ["r1", "w1", "r2", "w2", "r2", "w2", "r3", "w3", "r3"]],
    ["day 4", ["r1", "w1", "r2", "w2", "r2", "w2", "r3", "w3", "r3"]],
    ["day 5", ["r2", "w2", "r3", "w3", "r3", "w3", "r3"]],
    ["day 6", ["r1", "w1", "r2", "w2", "r3", "w3", "r3", "w3", "r3"]],
    ["day 7", ["r1", "w1", "r2", "w2", "r3", "w3", "r3", "w3", "r3"]],
    [
        "day 8",
        [
            "r2",
            "w2",
            "r2",
            "w1",
            "r2",
            "w1",
            "r2",
            "w1",
            "r2",
            "w1",
            "r2",
            "w1",
            "r2",
            "w1",
            "r2"
        ]
    ],
    ["day 9", ["r1", "w1", "r2", "w2", "r4", "w3", "r4", "w3", "r5"]],
    ["day 10", ["r2", "w2", "r3", "w2", "r5", "w3", "r5", "w3", "r5"]],
    ["day 11", ["r2", "w1", "r3", "w2", "r6", "w2", "r6", "w2", "r7"]],
    ["day 12", ["r2", "w2", "r4", "w2", "r5", "w2", "r6", "w2", "r7"]]
];

// Helpers

export function expand(run) {
    let go = (acc, item) => {
        let type = item[0] == "w" ? "walk" : "run";
        return [...acc, { type, time: parseInt(item.slice(1)) }];
    };
    return { title: run[0], list: run[1].reduce(go, []) };
}

export function getNextRun(runsData, dayRuns) {
    // console.log(runsData, dayRuns);
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
