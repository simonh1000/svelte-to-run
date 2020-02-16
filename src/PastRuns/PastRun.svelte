<script>
    import { onMount } from "svelte";
    import { pathDistance } from "../js/view-helpers";
    import { dateFormat } from "../js/date-format";

    export let run;

    let distance;
    if (run.distance) {
        distance = run.distance;
    } else if (run.waypoints && run.waypoints.length > 1) {
        distance = pathDistance(run.waypoints);
    } else {
        distance = "";
    }
    // onMount(() => {
    //     var mymap = L.map("mapid").setView([51.505, -0.09], 13);
    //     L.tileLayer("http://{s}.tile.osm.org/{z}/{x}/{y}.png", {
    //         attribution:
    //             '&copy; <a href="http://osm.org/copyright">OpenStreetMap</a> contributor'
    //         //other attributes.
    //     }).addTo(mymap);
    // });
    const pDate = d => {
        return dateFormat(d, "%m-%d %H:%M", false);
    };
</script>

<style>
    td {
        padding: 2px 10px;
        text-align: left;
    }
</style>

<tr>
    <td class={run.completed ? 'text-green-600' : 'text-red-600'}>
        {run.title + 1}
    </td>
    <td>{pDate(run.start)}</td>
    <td>
        <div class="flex flex-row justify-between pl-1 pr-6">
            {run.run}
            <small>({run.total})</small>
        </div>
    </td>
    <td>{distance}</td>
</tr>
