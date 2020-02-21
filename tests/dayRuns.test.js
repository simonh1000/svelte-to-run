import { dayRuns, summariseUpto } from "../src/js/dayRuns";

test("summariseUpto 0", () => {
    expect(summariseUpto(dayRuns[0], 0).toBe({ total: 0 }));
});
