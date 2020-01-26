<script>
    import { onMount } from "svelte";

    import { dayRuns } from "../js/dayRuns";
    import RunSummary from "./PastRun";
    export let state;

    // const tmp = dayRuns.reduce((acc, dayRun) => {
    //     acc[dayRun.title] = dayRun.list;
    //     return acc;
    // }, {});
    // onMount(() => {
    //     var mymap = L.map("mapid").setView([51.505, -0.09], 13);
    //     L.tileLayer("http://{s}.tile.osm.org/{z}/{x}/{y}.png", {
    //         attribution:
    //             '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributor'
    //         //other attributes.
    //     }).addTo(mymap);
    // });
</script>

<style>
    table {
        width: 100%;
    }
    th {
        padding: 2px 10px;
        text-align: left;
    }
</style>

<h2>Past Runs</h2>

<table>
    <thead>
        <th>Date</th>
        <th>Time</th>
        <th>Running (mins)</th>
        <th>Distance (km)</th>
    </thead>
    {#each state.history as run}
        <RunSummary {run} dayRun={dayRuns[run.title]} />
    {/each}
</table>
