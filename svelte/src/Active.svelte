<script>
    import { createEventDispatcher } from "svelte";
    import Activity from "./Components/Activity.svelte";

    export let state;

    const dispatch = createEventDispatcher();
    function selectRun() {
        dispatch("start");
    }
</script>

<h2>Active</h2>

<Activity run={state.run} />

<button disabled>Pause</button>
<button disabled>Stop</button>

<div>{JSON.stringify(state.waypoints)}</div>
