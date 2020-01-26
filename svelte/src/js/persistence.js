// Local storage
const key = "running-app";

export const getRunsData = () => {
    let tmp = JSON.parse(localStorage.getItem(key)) || [];
    tmp.map(run => {
        run.start = new Date(run.start);
        run.end = new Date(run.end);
        return run;
    });
    return tmp;
};

export const addLatestRun = run => {
    let runs = getRunsData();
    let newRuns = [run, ...runs];
    console.log("About to persist", newRuns);
    localStorage.setItem(key, JSON.stringify(newRuns));
    return newRuns;
};
