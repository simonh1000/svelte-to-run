<script>
    import { onMount, createEventDispatcher } from "svelte";
    import Activity from "../Components/Activity.svelte";

    export let state;

    const dispatch = createEventDispatcher();
    function start() {
        dispatch("start");
    }
</script>

<h2>Ready to start</h2>

<Activity run={state.run} />

<button id="start-button" on:click={start}>Start</button>

<div>{JSON.stringify(state.location)}</div>
