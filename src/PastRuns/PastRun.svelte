<script>
    import { onMount } from "svelte";
    import { pathDistance } from "../js/view-helpers";

    export let run;

    let distance;
    if (run.distance) {
        distance = run.distance;
    } else if (run.waypoints && run.waypoints.length > 1) {
        distance = pathDistance(run.waypoints);
    } else {
        distance = "unknown";
    }
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
    td {
        padding: 2px 10px;
        text-align: left;
    }
</style>

<tr>
    <td>{run.start.toLocaleDateString('en-GB')}</td>
    <td>{run.start.toLocaleTimeString('en-GB')}</td>
    <td>
        {run.run}
        <small>({run.total})</small>
    </td>
    <td>{distance}</td>
</tr>
<!-- {JSON.stringify(run)} -->
