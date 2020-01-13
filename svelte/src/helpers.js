export function expand(run) {
  let go = (acc, item) => {
    let type = item[0] == "w" ? "walk" : "run";
    return [...acc, { type, time: parseInt(item.slice(1)) }];
  };
  return { title: run[0], list: run[1].reduce(go, []) };
}
