<script>
    import { onMount } from "svelte";
    import { pathDistance } from "../js/view-helpers";

    export let run;
    export let dayRun;

    const minsRunning = dayRun.reduce(
        (acc, item) => (item.type == "run" ? acc + item.time : acc),
        0
    );

    let dst;
    if (run.distance) {
        dst = run.distance;
    } else if (run.waypoints && run.waypoints.length > 1) {
        dst = pathDistance(run.waypoints);
    } else {
        dst = "unknown";
    }
</script>

<style>
    td {
        padding: 2px 10px;
        text-align: left;
    }
</style>

<tr>
    <td>{run.title}</td>
    <td>{minsRunning}</td>
    <td>{dst}</td>
</tr>
<!-- {JSON.stringify(run)} -->
