<script>
    import { onMount } from "svelte";
    import Button from "@smui/button";

    import { dayRuns, summarise } from "../js/dayRuns";
    import { pathDistance } from "../js/view-helpers";
    import { addLatestRun } from "../js/persistence";

    import Activity from "./Activity.svelte";

    export let state;
    export let onSaveDistance;

    let distance =
        state.waypoints && state.waypoints.length > 1
            ? pathDistance(state.waypoints)
            : 0;

    const saveDistance = () => {
        let runMeta = summarise(state.list);
        let run = {
            title: state.title,
            waypoints: state.waypoints,
            // binding distance to input turns it into a string
            distance: parseFloat(distance),
            start: state.start,
            end: state.end,
            ...runMeta
        };
        console.log("save distance", run);
        const history = addLatestRun(run);
        onSaveDistance();
    };
    onMount(() => {
        document.querySelector("#distance").focus();
    });
</script>

<style>
    .input-container {
        width: 80%;
    }
    input {
        max-width: 100%;
        font-size: 50px;
        padding-left: 20px;
    }
</style>

<div class="flex flex-col items-center">

    <h2 class="mt-3 mb-3">Well done! Completed {state.title}</h2>

    <div class="input-container mb-3">
        <input id="distance" type="number" bind:value={distance} />
    </div>

    <Button
        variant="raised"
        on:click={saveDistance}
        style="padding: 20px; min-width: 36px; height: auto">
        <span class="start-button">Record distance</span>
    </Button>

    <div class="mt-3">
        <span>{state.start.toLocaleDateString('en-GB')}</span>
        <span>
            {state.start.toLocaleTimeString('en-GB')} - {state.end.toLocaleTimeString('en-GB')}
        </span>
        <Activity section="-1" list={state.list} />
    </div>

</div>
<!-- {JSON.stringify(state)} -->
