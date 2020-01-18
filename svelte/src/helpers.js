export function expand(run) {
    let go = (acc, item) => {
        let type = item[0] == "w" ? "walk" : "run";
        return [...acc, { type, time: parseInt(item.slice(1)) }];
    };
    return { title: run[0], list: run[1].reduce(go, []) };
}

// {title, list:[{type,time}]} -> {title, list:[{type, time, accTime}]}
let min = 10; // should be 60;

export function dayRun2Run(dayRun) {
    let convertedData = dayRun.list.reduce(
        ({ accTime, accItems }, item) => {
            let tmp = accTime + item.time * min;
            return {
                accTime: tmp,
                accItems: [...accItems, { ...item, accTime: accTime }]
            };
        },
        { accTime: 0, accItems: [] }
    );
    return { title: dayRun.title, list: convertedData.accItems };
}

// dayRun2Run({
//     title: "simon",
//     list: [
//         { type: "run", time: 1 },
//         { type: "walk", time: 1 },
//         { type: "run", time: 1 }
//     ]
// });
