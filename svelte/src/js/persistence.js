// Local storage
const key = "running-app";

export const getRunsData = () => {
    return JSON.parse(localStorage.getItem(key)) || [];
};

export const addLatestRun = run => {
    let runs = getRunsData();
    let newRuns = [run, ...runs];
    console.log("About to persist", newRuns);
    localStorage.setItem(key, JSON.stringify(newRuns));
    return newRuns;
};
