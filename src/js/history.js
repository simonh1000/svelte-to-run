// gets last completed run from history
// TODO move to persistence?
export function getLastRun(history) {
    // console.log("getLastRun", history);
    let tmp = history.reduce((acc, run) => {
        // if we already have the latest run then keep returning that
        if (acc > -1) return acc;
        // otherwise if we completed a run then
        if (run.completed && typeof run.title === "number") return run.title;
        return acc;
    }, -1);
    // console.log("last run ", tmp);
    return tmp;
}
