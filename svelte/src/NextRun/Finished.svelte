<script>
    import Button from "@smui/button";

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
        let run = {
            title: state.title,
            waypoints: state.waypoints,
            distance,
            start: state.start,
            end: state.end
        };
        console.log("save distance", run);
        const history = addLatestRun(run);
        onSaveDistance();
    };
</script>

<style>
    .input-container {
        width: 100%;
    }
    input {
        max-width: 100%;
        font-size: 42px;
        padding-left: 20px;
    }
</style>

<div class="flex-col flex-center">

    <h2>Well done! Completed {state.title}</h2>

    <div class="input-container">
        <input type="number" bind:value={distance} />
    </div>

    <Button
        variant="raised"
        on:click={saveDistance}
        style="padding: 20px; min-width: 36px; height: auto">
        <span class="start-button">Record distance</span>
    </Button>

    <div>
        <span>{state.start.toLocaleDateString('en-GB')}</span>
        <span>
            {state.start.toLocaleTimeString('en-GB')} - {state.end.toLocaleTimeString('en-GB')}
        </span>
        <Activity section="-1" list={state.list} />
    </div>

</div>
<!-- {JSON.stringify(state)} -->
