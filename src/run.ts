// All internal calculations use 0-based array indexes. Only the user see (idx + 1)

interface Run {
    title: number;          // starting from 0, matches in the index in dayRuns.json
    waypoints: WayPoint[];
    completed: boolean;
    distance: number;
    start: string;
    end: string;
    runMeta: RunMeta;
}

interface WayPoint {
    timestamp: number;
    coords: {
        latitude: number;
        longitude: number;
    }
}

interface PersistedWayPoint {
    timestamp: number;
    coords: number[];  // two elements
}

interface RunMeta {
    total: number;
    run: number;
}

interface DayRun {
    type: string;
    time: number;
    accTime: number;
}

interface RunSchedule {
    type: string;
    time: number;
}