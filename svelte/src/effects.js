const key = "running-app";

export const getRunsData = () => {
    return JSON.parse(localStorage.getItem(key)) || [];
};

export const setRunsData = lst => {
    return localStorage.setItem(key, JSON.stringify(lst));
};
