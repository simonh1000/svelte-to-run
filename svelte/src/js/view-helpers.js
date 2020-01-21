export const ppTime = time => {
    let min = Math.floor(time / 60);
    let secs = (time % 60).toString();
    return min + ":" + secs.padStart(2, "0");
};
