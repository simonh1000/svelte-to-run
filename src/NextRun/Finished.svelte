<script>
    import { onMount } from "svelte";
    import Button from "@smui/button";

    import { dayRuns, summarise } from "../js/dayRuns";
    import { pathDistance } from "../js/view-helpers";

    import Activity from "./Activity.svelte";

    export let state;
    export let onRunCompleted;

    let distance =
        state.waypoints && state.waypoints.length > 1
            ? pathDistance(state.waypoints)
            : 0;

    const saveDistance = () => {
        let run = {
            title: state.title,
            waypoints: state.waypoints,
            completed: state.completed,
            total: state.total,
            run: state.run,
            start: state.start,
            end: state.end,
            // binding distance to input turns it into a string
            distance: parseFloat(distance)
        };
        console.log("save distance", run);
        // save and returns with new full list of runs
        // which we want to pass to pastRuns
        onRunCompleted(run);
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

<div class="flex flex-col items-center pt-6">

    {#if state.completed}
        <h2 class="mb-3 text-xl">Well done! Completed {state.title}</h2>
    {/if}

    <div class="input-container mb-6 border-2 border-gray-300 border-solid">
        <input id="distance" type="number" bind:value={distance} />
    </div>

    <Button
        variant="raised"
        on:click={saveDistance}
        style="padding: 20px; min-width: 36px; height: auto">
        <span class="start-button">Record distance</span>
    </Button>

    <div class="mt-6">
        <span>{state.start.toLocaleDateString('en-GB')}</span>
        <span>
            {state.start.toLocaleTimeString('en-GB')} - {state.end.toLocaleTimeString('en-GB')}
        </span>
        <Activity section="-1" list={state.list} />
    </div>

</div>
