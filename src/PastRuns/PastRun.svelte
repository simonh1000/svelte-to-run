<script>
    import { onMount } from "svelte";
    import { pathDistance } from "../js/view-helpers";

    export let run;
    export let dayRun;

    const minsRunning = dayRun.reduce(
        (acc, item) => (item.type == "run" ? acc + item.time : acc),
        0
    );

    let distance;
    if (run.distance) {
        distance = run.distance;
    } else if (run.waypoints && run.waypoints.length > 1) {
        distance = pathDistance(run.waypoints);
    } else {
        distance = "unknown";
    }
</script>

<style>
    td {
        padding: 2px 10px;
        text-align: left;
    }
</style>

<tr>
    <td>{run.start.toLocaleDateString('en-GB')}</td>
    <td>{run.start.toLocaleTimeString('en-GB')}</td>
    <td>{minsRunning}</td>
    <td>{distance}</td>
</tr>
<!-- {JSON.stringify(run)} -->
